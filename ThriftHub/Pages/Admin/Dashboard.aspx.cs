using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Admin
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Admin");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
            {
                LoadStats();
                LoadPending();
                LoadRecentOrders();
                LoadRecentUsers();
                CheckAdminNotifications();
            }
        }

        // ─── STATS ───────────────────────────────────────────────────────────────
        private void LoadStats()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                ExecStat(conn, "SELECT COUNT(*) FROM Users WHERE Role IN ('Buyer','Seller')", litTotalUsers);
                ExecStat(conn, "SELECT COUNT(*) FROM Listings",                              litTotalListings);
                ExecStat(conn, "SELECT COUNT(*) FROM Listings WHERE Status='Pending'",       litPending);
                ExecStat(conn, "SELECT COUNT(*) FROM Orders",                                litTotalOrders);

                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(SUM(FinalAmount),0) FROM Orders WHERE PaymentStatus='Paid'", conn))
                    litRevenue.Text = string.Format("{0:F2}", cmd.ExecuteScalar());

                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(SUM(CommissionAmount),0) FROM Orders WHERE PaymentStatus='Paid'", conn))
                    litCommission.Text = string.Format("{0:F2}", cmd.ExecuteScalar());
            }
        }

        private void ExecStat(SqlConnection conn, string sql, Literal lit)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
                lit.Text = cmd.ExecuteScalar().ToString();
        }

        // ─── PENDING LISTINGS ────────────────────────────────────────────────────
        private void LoadPending()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT l.ListingID, l.Title, l.Description, l.Brand,
                           l.Size, l.Condition, l.Gender, l.Price, l.DateListed,
                           ISNULL(c.Name,'Uncategorised') AS CategoryName,
                           u.FullName AS SellerName
                    FROM Listings l
                    LEFT JOIN Categories c ON l.CategoryID = c.CategoryID
                    LEFT JOIN Users u      ON l.SellerID   = u.UserID
                    WHERE l.Status = 'Pending'
                    ORDER BY l.DateListed ASC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlNoPending.Visible  = true;
                        rptPending.Visible    = false;
                        litPendingCount.Text  = "";
                    }
                    else
                    {
                        pnlNoPending.Visible  = false;
                        rptPending.Visible    = true;
                        litPendingCount.Text  = "<span class='badge-count'>" + dt.Rows.Count + "</span>";
                        rptPending.DataSource = dt;
                        rptPending.DataBind();
                    }
                }
            }
        }

        // ─── MODERATE (APPROVE / REJECT) ─────────────────────────────────────────
        protected void ModerateItem(object sender, CommandEventArgs e)
        {
            int    listingID = Convert.ToInt32(e.CommandArgument);
            string action    = e.CommandName;
            string note      = hdnNote.Value;
            int    adminID   = NavHelper.GetUserID();
            string newStatus = action == "Approve" ? "Approved" : "Rejected";

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();

                    string sql = @"
                        UPDATE Listings SET
                            Status          = @Status,
                            ModerationNotes = @Notes,
                            ModeratedBy     = @AdminID,
                            ModeratedDate   = GETDATE()
                        WHERE ListingID = @ID";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Status",  newStatus);
                        cmd.Parameters.AddWithValue("@Notes",   string.IsNullOrEmpty(note) ? (object)DBNull.Value : note);
                        cmd.Parameters.AddWithValue("@AdminID", adminID);
                        cmd.Parameters.AddWithValue("@ID",      listingID);
                        cmd.ExecuteNonQuery();
                    }

                    NotifySeller(conn, listingID, newStatus, note);
                }

                litMessage.Text = action == "Approve"
                    ? "<div class='server-message success'>✅ Listing approved and is now live.</div>"
                    : "<div class='server-message success'>❌ Listing rejected. Seller has been notified.</div>";

                hdnNote.Value      = "";
                hdnListingID.Value = "";

                LoadStats();
                LoadPending();
                LoadRecentOrders();
                LoadRecentUsers();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Moderate Error: " + ex.Message);
                litMessage.Text = "<div class='server-message error'>Something went wrong: " + ex.Message + "</div>";
            }
        }

        private void NotifySeller(SqlConnection conn, int listingID, string status, string note)
        {
            try
            {
                string title = "";
                int sellerID = 0;

                using (SqlCommand cmd = new SqlCommand("SELECT Title, SellerID FROM Listings WHERE ListingID=@ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", listingID);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read()) { title = r["Title"].ToString(); sellerID = Convert.ToInt32(r["SellerID"]); }
                    }
                }

                if (sellerID == 0) return;

                string msg = status == "Approved"
                    ? $"Your listing \"{title}\" has been approved and is now live!"
                    : $"Your listing \"{title}\" was rejected. {(string.IsNullOrEmpty(note) ? "" : "Note: " + note)}";

                string notifTitle = status == "Approved" ? "Listing Approved ✅" : "Listing Rejected ❌";

                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO Notifications (UserID, Title, Message, IsRead, CreatedAt)
                    VALUES (@UID, @Title, @Msg, 0, GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@UID",   sellerID);
                    cmd.Parameters.AddWithValue("@Title", notifTitle);
                    cmd.Parameters.AddWithValue("@Msg",   msg);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        // ─── RECENT ORDERS ───────────────────────────────────────────────────────
        private void LoadRecentOrders()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT TOP 10 o.OrderID, u.FullName AS BuyerName,
                           o.FinalAmount, o.PaymentMethod, o.OrderStatus, o.OrderDate
                    FROM Orders o JOIN Users u ON o.BuyerID = u.UserID
                    ORDER BY o.OrderDate DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptOrders.DataSource = dt;
                    rptOrders.DataBind();
                }
            }
        }

        // ─── RECENT USERS ────────────────────────────────────────────────────────
        private void LoadRecentUsers()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "SELECT TOP 10 FullName, Email, Role, DateJoined FROM Users WHERE Role IN ('Buyer','Seller') ORDER BY DateJoined DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptUsers.DataSource = dt;
                    rptUsers.DataBind();
                }
            }
        }

        // ─── HELPERS ─────────────────────────────────────────────────────────────
        protected string GetImage(object listingID)
        {
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 ImagePath FROM ListingImages WHERE ListingID=@ID AND IsPrimary=1", conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", listingID);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            return $"<img src='{ResolveUrl(result.ToString())}' alt='item'/>";
                    }
                }
            }
            catch { }
            return "👗";
        }
        public string AdminNotificationMessage { get; set; } = "";
        public string AdminNotificationType { get; set; } = "info";

        private void CheckAdminNotifications()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();

                // New pending listing notification
                string pendingQuery = @"
            SELECT TOP 1 l.ListingID, l.Title, u.FullName
            FROM Listings l
            JOIN Users u ON l.SellerID = u.UserID
            WHERE l.Status = 'Pending'
            ORDER BY l.DateListed DESC";

                using (SqlCommand cmd = new SqlCommand(pendingQuery, conn))
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        int listingId = (int)r["ListingID"];
                        string title = r["Title"].ToString();
                        string seller = r["FullName"].ToString();
                        string seenKey = $"admin_listing_notif_{listingId}";

                        if (Session[seenKey] == null)
                        {
                            Session[seenKey] = true;
                            AdminNotificationType = "new_listing";
                            AdminNotificationMessage = $"New listing pending review: \"{title}\" by {seller} 📋";
                        }
                    }
                }

                // New order notification
                if (string.IsNullOrEmpty(AdminNotificationMessage))
                {
                    string orderQuery = @"
                SELECT TOP 1 o.OrderID, u.FullName, o.FinalAmount
                FROM Orders o
                JOIN Users u ON o.BuyerID = u.UserID
                ORDER BY o.OrderDate DESC";

                    using (SqlCommand cmd = new SqlCommand(orderQuery, conn))
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            int orderId = (int)r["OrderID"];
                            string buyer = r["FullName"].ToString();
                            decimal amount = Convert.ToDecimal(r["FinalAmount"]);
                            string seenKey = $"admin_order_notif_{orderId}";

                            if (Session[seenKey] == null)
                            {
                                Session[seenKey] = true;
                                AdminNotificationType = "purchase";
                                AdminNotificationMessage = $"Order #{orderId} placed by {buyer} for R{amount:F2} 🛒";
                            }
                        }
                    }
                }
            }
        }

        protected string GetOrderBadge(string status)
        {
            switch (status)
            {
                case "Delivered": return "<span class='badge badge-delivered'>📦 Delivered</span>";
                case "Shipped":   return "<span class='badge badge-shipped'>🚚 Shipped</span>";
                case "Confirmed": return "<span class='badge' style='background:#EBF5FB;color:#2980B9'>✅ Confirmed</span>";
                case "Cancelled": return "<span class='badge' style='background:#FDECEA;color:#C0392B'>❌ Cancelled</span>";
                default:          return "<span class='badge badge-processing'>⏳ Processing</span>";
            }
        }

        protected string GetRoleBadge(string role)
        {
            switch (role)
            {
                case "Seller": return "<span class='badge badge-seller'>🏪 Seller</span>";
                case "Admin":  return "<span class='badge badge-admin'>🛡️ Admin</span>";
                default:       return "<span class='badge badge-buyer'>🛍️ Buyer</span>";
            }
        }
    }
}