using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Seller
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Seller");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
            {
                LoadStats();
                LoadListings();
                CheckSellerNotifications();
            }

            // Show success message if redirected after listing
            if (!IsPostBack && Request.QueryString["listed"] == "1")
                litMessage.Text = "<div class='server-message success'>✅ Your item has been listed and is pending moderation.</div>";
        }
        public string SellerNotificationMessage { get; set; } = "";
        public string SellerNotificationType { get; set; } = "info";
        protected void NotifySellerOfSale(string itemTitle, decimal salePrice, int orderId)
        {
            SellerNotificationType = "sale";
            SellerNotificationMessage = $"Your item \"{itemTitle}\" was purchased for R{salePrice:F2}! 🛒";
        }


        // =============================================
        // Load seller stats
        // =============================================
        private void LoadStats()
        {
            int sellerID = NavHelper.GetUserID();

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();

                // Total listings
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Listings WHERE SellerID=@ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", sellerID);
                    litTotal.Text = cmd.ExecuteScalar().ToString();
                }

                // Pending
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Listings WHERE SellerID=@ID AND Status='Pending'", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", sellerID);
                    litPending.Text = cmd.ExecuteScalar().ToString();
                }

                // Approved
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Listings WHERE SellerID=@ID AND Status='Approved'", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", sellerID);
                    litApproved.Text = cmd.ExecuteScalar().ToString();
                }

                // Sold
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Listings WHERE SellerID=@ID AND Status='Sold'", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", sellerID);
                    litSold.Text = cmd.ExecuteScalar().ToString();
                }

                // Earnings (seller payout from completed orders)
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ISNULL(SUM(oi.SellerPayout),0) FROM OrderItems oi WHERE oi.SellerID=@ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", sellerID);
                    litEarnings.Text = string.Format("{0:F2}", cmd.ExecuteScalar());
                }
            }
        }
        private void CheckSellerNotifications()
        {
            int sellerID = NavHelper.GetUserID();

            // Check for a new sale (item just became Sold)
            string saleQuery = @"
        SELECT TOP 1 l.Title, oi.SellerPayout, oi.OrderID
        FROM OrderItems oi
        JOIN Listings l ON oi.ListingID = l.ListingID
        WHERE oi.SellerID = @sid
        ORDER BY oi.OrderItemID DESC";

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();

                // --- Sale notification ---
                using (SqlCommand cmd = new SqlCommand(saleQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", sellerID);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            int orderId = (int)r["OrderID"];
                            string title = r["Title"].ToString();
                            decimal payout = Convert.ToDecimal(r["SellerPayout"]);
                            string seenKey = $"seller_sale_notif_{orderId}";

                            if (Session[seenKey] == null)
                            {
                                Session[seenKey] = true;
                                NotifySellerOfSale(title, payout, orderId);
                            }
                        }
                    }
                }

                // --- Approval/Rejection notification ---
                // Only fire if we haven't already set a sale notification
                if (string.IsNullOrEmpty(SellerNotificationMessage))
                {
                    string approvalQuery = @"
                SELECT TOP 1 ListingID, Title, Status
                FROM Listings
                WHERE SellerID = @sid
                AND Status IN ('Approved', 'Rejected')
                ORDER BY DateListed DESC";

                    using (SqlCommand cmd = new SqlCommand(approvalQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerID);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                int listingId = (int)r["ListingID"];
                                string title = r["Title"].ToString();
                                string status = r["Status"].ToString();
                                string seenKey = $"seller_approval_notif_{listingId}_{status}";

                                if (Session[seenKey] == null)
                                {
                                    Session[seenKey] = true;
                                    NotifySellerOfApproval(title, status == "Approved");
                                }
                            }
                        }
                    }
                }
            }
        }

        protected void NotifySellerOfApproval(string itemTitle, bool approved)
        {
            if (approved)
            {
                SellerNotificationType = "approved";
                SellerNotificationMessage = $"Your listing \"{itemTitle}\" has been approved and is now live! ✅";
            }
            else
            {
                SellerNotificationType = "rejected";
                SellerNotificationMessage = $"Your listing \"{itemTitle}\" was rejected. Check admin notes. ❌";
            }
        }


        // =============================================
        // Load listings table
        // =============================================
        private void LoadListings()
        {
            int sellerID = NavHelper.GetUserID();

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT l.ListingID, l.Title, l.Brand, l.Size,
                           l.Price, l.Status, l.DateListed,
                           ISNULL(c.Name, 'Uncategorised') AS CategoryName
                    FROM Listings l
                    LEFT JOIN Categories c ON l.CategoryID = c.CategoryID
                    WHERE l.SellerID = @ID
                    ORDER BY l.DateListed DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", sellerID);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlTable.Visible = false;
                        pnlEmpty.Visible = true;
                    }
                    else
                    {
                        pnlTable.Visible = true;
                        pnlEmpty.Visible = false;
                        rptListings.DataSource = dt;
                        rptListings.DataBind();
                    }
                }
            }
        }

        // =============================================
        // Status badge — must be protected for Repeater
        // =============================================
        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Approved": return "<span class='badge badge-approved'>✅ Approved</span>";
                case "Rejected": return "<span class='badge badge-rejected'>❌ Rejected</span>";
                case "Sold": return "<span class='badge badge-sold'>🛒 Sold</span>";
                default: return "<span class='badge badge-pending'>⏳ Pending</span>";
            }
        }

        // =============================================
        // Edit / Remove button handler
        // =============================================
        protected void rptListings_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int listingID = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Edit")
            {
                Response.Redirect($"ListItem.aspx?edit={listingID}");
                return;
            }

            if (e.CommandName == "Remove")
            {
                try
                {
                    using (SqlConnection conn = DBHelper.GetConnection())
                    {
                        conn.Open();

                        // Delete images first
                        string delImages = "DELETE FROM ListingImages WHERE ListingID=@ID";
                        using (SqlCommand cmd = new SqlCommand(delImages, conn))
                        {
                            cmd.Parameters.AddWithValue("@ID", listingID);
                            cmd.ExecuteNonQuery();
                        }

                        // Delete listing
                        string delListing = "DELETE FROM Listings WHERE ListingID=@ID AND SellerID=@SID";
                        using (SqlCommand cmd = new SqlCommand(delListing, conn))
                        {
                            cmd.Parameters.AddWithValue("@ID", listingID);
                            cmd.Parameters.AddWithValue("@SID", NavHelper.GetUserID());
                            cmd.ExecuteNonQuery();
                        }
                    }

                    litMessage.Text = "<div class='server-message success'>✅ Listing removed successfully.</div>";
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Remove Error: " + ex.Message);
                    litMessage.Text = "<div class='server-message error'>❌ Could not remove listing. Please try again.</div>";
                }

                LoadStats();
                LoadListings();
            }
        }
    }
}