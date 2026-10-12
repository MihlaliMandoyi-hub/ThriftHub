using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Buyer
{
    public partial class Catalogue : Page
    {
        public string ToastMessage = "";
        public string BuyerNotificationMessage { get; set; } = string.Empty;
        public string BuyerNotificationType { get; set; } = "info";

        // Stores wishlisted listing IDs for this buyer — loaded once per request
        private HashSet<int> _wishlistIDs = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Buyer");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
            {
                LoadCategories();
                LoadItems();
                CheckOrderStatusNotifications();
            }
        }

        // =============================================
        // Loads wishlisted IDs into a HashSet (fast lookup)
        // =============================================
        private HashSet<int> GetWishlistIDs()
        {
            if (_wishlistIDs != null) return _wishlistIDs;

            _wishlistIDs = new HashSet<int>();
            int buyerID = NavHelper.GetUserID();

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "SELECT ListingID FROM Wishlists WHERE BuyerID = @BID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@BID", buyerID);
                    using (SqlDataReader r = cmd.ExecuteReader())
                        while (r.Read())
                            _wishlistIDs.Add((int)r["ListingID"]);
                }
            }
            return _wishlistIDs;
        }

        // Called from Repeater in .aspx — must be protected
        protected bool IsWishlisted(object listingID)
        {
            return GetWishlistIDs().Contains(Convert.ToInt32(listingID));
        }

        // =============================================
        // Fills the Category dropdown from the database
        // =============================================
        private void LoadCategories()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "SELECT CategoryID, Name FROM Categories ORDER BY Name";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                        ddlCategory.Items.Add(new ListItem(r["Name"].ToString(), r["CategoryID"].ToString()));
                }
            }
        }

        // =============================================
        // Loads items from DB based on search/filters
        // =============================================
        private void LoadItems()
        {
            string search = txtSearch.Text.Trim();
            string category = ddlCategory.SelectedValue;
            string size = ddlSize.SelectedValue;
            string gender = ddlGender.SelectedValue;
            string maxPrice = txtMaxPrice.Text.Trim();

            string sql = @"
                SELECT l.ListingID, l.Title, l.Brand, l.Size, l.Condition,
                       l.Price, l.Gender,
                       ISNULL(c.Name, 'Uncategorised') AS CategoryName
                FROM Listings l
                LEFT JOIN Categories c ON l.CategoryID = c.CategoryID
                WHERE l.Status = 'Approved'
                AND (@Search = '' OR l.Title LIKE '%' + @Search + '%'
                     OR l.Brand LIKE '%' + @Search + '%'
                     OR l.Description LIKE '%' + @Search + '%')
                AND (@Category = '' OR CAST(l.CategoryID AS NVARCHAR) = @Category)
                AND (@Size = '' OR l.Size = @Size)
                AND (@Gender = '' OR l.Gender = @Gender)
                ORDER BY l.DateListed DESC";

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Search", search);
                    cmd.Parameters.AddWithValue("@Category", category);
                    cmd.Parameters.AddWithValue("@Size", size);
                    cmd.Parameters.AddWithValue("@Gender", gender);

                    if (!string.IsNullOrEmpty(maxPrice) && decimal.TryParse(maxPrice, out decimal maxPriceValue))
                    {
                        cmd.CommandText += " AND l.Price <= @MaxPrice";
                        cmd.Parameters.AddWithValue("@MaxPrice", maxPriceValue);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    litCount.Text = dt.Rows.Count.ToString();

                    if (dt.Rows.Count == 0)
                    {
                        rptItems.Visible = false;
                        pnlEmpty.Visible = true;
                    }
                    else
                    {
                        rptItems.Visible = true;
                        pnlEmpty.Visible = false;
                        rptItems.DataSource = dt;
                        rptItems.DataBind();
                    }
                }
            }
        }

        // =============================================
        // Basket count in nav
        // =============================================
        private void LoadBasketCount()
        {
            if (NavHelper.GetRole() != "Buyer") return;
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "SELECT COUNT(*) FROM Basket WHERE BuyerID = @ID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", NavHelper.GetUserID());
                    int count = (int)cmd.ExecuteScalar();
                    litBasketCount.Text = count > 0 ? $"({count})" : "";
                }
            }
        }

        // =============================================
        // Image helper — called from Repeater
        // =============================================
        protected string GetItemImage(object listingID)
        {
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    string sql = "SELECT TOP 1 ImagePath FROM ListingImages WHERE ListingID=@ID AND IsPrimary=1";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", listingID);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            return $"<img src='{ResolveUrl(result.ToString())}' alt='Item photo'/>";
                    }
                }
            }
            catch { }
            return "👗";
        }

        // =============================================
        // Repeater button handler
        // =============================================
        protected void rptItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int listingID = Convert.ToInt32(e.CommandArgument);
            int buyerID = NavHelper.GetUserID();

            if (e.CommandName == "ToggleWishlist")
            {
                ToggleWishlist(listingID, buyerID);
            }
            else if (e.CommandName == "AddToBasket")
            {
                AddToBasket(listingID, buyerID);
            }

            // Reset wishlist cache after toggle so heart re-renders correctly
            _wishlistIDs = null;
            LoadItems();
            LoadBasketCount();
        }

        // =============================================
        // Toggle wishlist (add or remove)
        // =============================================
        private void ToggleWishlist(int listingID, int buyerID)
        {
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    string checkSql = "SELECT COUNT(*) FROM Wishlists WHERE BuyerID=@BID AND ListingID=@LID";
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        bool alreadySaved = (int)cmd.ExecuteScalar() > 0;

                        if (alreadySaved)
                        {
                            // Remove from wishlist
                            string deleteSql = "DELETE FROM Wishlists WHERE BuyerID=@BID AND ListingID=@LID";
                            using (SqlCommand delCmd = new SqlCommand(deleteSql, conn))
                            {
                                delCmd.Parameters.AddWithValue("@BID", buyerID);
                                delCmd.Parameters.AddWithValue("@LID", listingID);
                                delCmd.ExecuteNonQuery();
                            }
                            ToastMessage = "💔 Removed from wishlist.";
                        }
                        else
                        {
                            // Add to wishlist
                            string insertSql = "INSERT INTO Wishlists (BuyerID, ListingID, DateAdded) VALUES (@BID, @LID, GETDATE())";
                            using (SqlCommand insCmd = new SqlCommand(insertSql, conn))
                            {
                                insCmd.Parameters.AddWithValue("@BID", buyerID);
                                insCmd.Parameters.AddWithValue("@LID", listingID);
                                insCmd.ExecuteNonQuery();
                            }
                            ToastMessage = "❤️ Saved to wishlist!";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Wishlist Toggle Error: " + ex.Message);
                ToastMessage = "❌ Could not update wishlist. Please try again.";
            }
        }

        // =============================================
        // Add to basket
        // =============================================
        private void AddToBasket(int listingID, int buyerID)
        {
            if (NavHelper.GetRole() != "Buyer")
            {
                litMessage.Text = "<div class='server-message error'>Only buyers can add items to basket.</div>";
                return;
            }

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    string checkSql = "SELECT COUNT(*) FROM Basket WHERE BuyerID=@BID AND ListingID=@LID";
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        if ((int)cmd.ExecuteScalar() > 0) { ToastMessage = "⚠️ Already in your basket!"; return; }
                    }

                    string checkStatus = "SELECT COUNT(*) FROM Listings WHERE ListingID=@LID AND Status='Approved'";
                    using (SqlCommand cmd = new SqlCommand(checkStatus, conn))
                    {
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        if ((int)cmd.ExecuteScalar() == 0)
                        {
                            litMessage.Text = "<div class='server-message error'>Sorry, this item is no longer available.</div>";
                            return;
                        }
                    }

                    string insertSql = "INSERT INTO Basket (BuyerID, ListingID, DateAdded) VALUES (@BID, @LID, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        cmd.ExecuteNonQuery();
                    }
                }
                ToastMessage = "✅ Item added to basket!";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Add to Basket Error: " + ex.Message);
                litMessage.Text = "<div class='server-message error'>Could not add item. Please try again.</div>";
            }
        }

        // =============================================
        // Order status notifications
        // =============================================
        private void CheckOrderStatusNotifications()
        {
            string query = @"SELECT TOP 1 OrderID, OrderStatus FROM Orders WHERE BuyerID=@uid ORDER BY OrderDate DESC";
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", NavHelper.GetUserID());
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int orderId = (int)reader["OrderID"];
                            string status = reader["OrderStatus"].ToString();
                            string seenKey = $"notif_seen_{orderId}_{status}";
                            if (Session[seenKey] == null)
                            {
                                Session[seenKey] = true;
                                switch (status)
                                {
                                    case "Confirmed": BuyerNotificationType = "confirmed"; BuyerNotificationMessage = $"Your order #{orderId} has been confirmed! 🎉"; break;
                                    case "Shipped": BuyerNotificationType = "shipped"; BuyerNotificationMessage = $"Your order #{orderId} is on its way! 🚚"; break;
                                    case "Delivered": BuyerNotificationType = "delivered"; BuyerNotificationMessage = $"Your order #{orderId} has been delivered! 📦"; break;
                                }
                            }
                        }
                    }
                }
            }
        }

        protected void BtnSearch_Click(object sender, EventArgs e) { LoadItems(); }

        protected void BtnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = ""; txtMaxPrice.Text = "";
            ddlCategory.SelectedIndex = 0; ddlSize.SelectedIndex = 0; ddlGender.SelectedIndex = 0;
            LoadItems();
        }
    }
}

