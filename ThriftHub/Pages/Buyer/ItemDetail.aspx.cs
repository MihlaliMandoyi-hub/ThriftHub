using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace ThriftHub.Pages.Buyer
{
    public partial class ItemDetail : Page
    {
        public string ToastMessage = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireLogin();
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
                LoadItem();
        }

        private void LoadItem()
        {
            if (Request.QueryString["id"] == null) { ShowNotFound(); return; }

            int listingID = Convert.ToInt32(Request.QueryString["id"]);
            int categoryID = 0;
            string size = "";
            string gender = "";

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();

                string sql = @"
                    SELECT l.*, ISNULL(c.Name,'Uncategorised') AS CategoryName,
                           u.FullName AS SellerName
                    FROM Listings l
                    LEFT JOIN Categories c ON l.CategoryID = c.CategoryID
                    LEFT JOIN Users u ON l.SellerID = u.UserID
                    WHERE l.ListingID = @ID AND l.Status = 'Approved'";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", listingID);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) { ShowNotFound(); return; }

                        litTitle.Text = r["Title"].ToString();
                        litPrice.Text = string.Format("{0:F2}", r["Price"]);
                        litCategory.Text = r["CategoryName"].ToString();
                        litSize.Text = r["Size"].ToString();
                        litCondition.Text = r["Condition"].ToString();
                        litGender.Text = r["Gender"].ToString();
                        litDescription.Text = r["Description"].ToString();
                        litSeller.Text = r["SellerName"].ToString();

                        if (r["CategoryID"] != DBNull.Value)
                            categoryID = Convert.ToInt32(r["CategoryID"]);
                        size = r["Size"].ToString();
                        gender = r["Gender"].ToString();

                        if (r["Brand"] != DBNull.Value && !string.IsNullOrEmpty(r["Brand"].ToString()))
                            litBrand.Text = r["Brand"].ToString();
                        else
                            pnlBrand.Visible = false;

                        if (r["Colour"] != DBNull.Value && !string.IsNullOrEmpty(r["Colour"].ToString()))
                            litColour.Text = r["Colour"].ToString();
                        else
                            pnlColour.Visible = false;

                        UpdateViewCount(listingID, conn);
                    }
                }

                LoadImages(conn, listingID);

                if (NavHelper.GetRole() == "Buyer")
                {
                    int buyerID = NavHelper.GetUserID();

                    string checkBasket = "SELECT COUNT(*) FROM Basket WHERE BuyerID=@BID AND ListingID=@LID";
                    using (SqlCommand cmd = new SqlCommand(checkBasket, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        if ((int)cmd.ExecuteScalar() > 0)
                        {
                            btnAddToCart.Text = "✅ Already in Basket";
                            btnAddToCart.Enabled = false;
                        }
                    }

                    string checkWish = "SELECT COUNT(*) FROM Wishlists WHERE BuyerID=@BID AND ListingID=@LID";
                    using (SqlCommand cmd = new SqlCommand(checkWish, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        bool wished = (int)cmd.ExecuteScalar() > 0;
                        btnWishlist.Text = wished ? "❤️ Wishlisted" : "🤍 Save to Wishlist";
                        btnWishlist.CssClass = wished ? "btn-wishlist-detail wished" : "btn-wishlist-detail";
                    }
                }
                else
                {
                    btnAddToCart.Visible = false;
                    btnWishlist.Visible = false;
                }
            }

            LoadSimilarItems(listingID, categoryID, size, gender);
        }

        // =============================================
        // Similar items: same category prioritised,
        // falls back to same size/gender. Max 4 cards.
        // =============================================
        private void LoadSimilarItems(int currentListingID, int categoryID, string size, string gender)
        {
            try
            {
                string sql = @"
                    SELECT TOP 4
                        l.ListingID, l.Title, l.Brand, l.Price, l.Size, l.Condition,
                        ISNULL(c.Name,'Uncategorised') AS CategoryName,
                        (SELECT TOP 1 ImagePath FROM ListingImages
                         WHERE ListingID = l.ListingID AND IsPrimary = 1) AS ImagePath
                    FROM Listings l
                    LEFT JOIN Categories c ON l.CategoryID = c.CategoryID
                    WHERE l.Status = 'Approved'
                      AND l.ListingID <> @CurrentID
                      AND (l.CategoryID = @CatID OR l.Size = @Size OR l.Gender = @Gender)
                    ORDER BY
                        CASE WHEN l.CategoryID = @CatID AND l.Size = @Size THEN 0
                             WHEN l.CategoryID = @CatID THEN 1
                             ELSE 2 END,
                        l.DateListed DESC";

                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@CurrentID", currentListingID);
                        cmd.Parameters.AddWithValue("@CatID", categoryID);
                        cmd.Parameters.AddWithValue("@Size", size);
                        cmd.Parameters.AddWithValue("@Gender", gender);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count == 0)
                            pnlSimilar.Visible = false;
                        else
                        {
                            pnlSimilar.Visible = true;
                            rptSimilar.DataSource = dt;
                            rptSimilar.DataBind();
                        }
                    }
                }
            }
            catch { pnlSimilar.Visible = false; }
        }

        // Called from rptSimilar ItemTemplate — must be protected
        protected string GetSimilarImage(object imagePath)
        {
            if (imagePath != DBNull.Value && !string.IsNullOrEmpty(imagePath.ToString()))
                return $"<img src='{ResolveUrl(imagePath.ToString())}' alt='item'/>";
            return "👗";
        }

        private void LoadImages(SqlConnection conn, int listingID)
        {
            string sql = "SELECT ImagePath, IsPrimary FROM ListingImages WHERE ListingID=@ID ORDER BY IsPrimary DESC";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ID", listingID);
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    bool first = true;
                    StringBuilder thumbs = new StringBuilder();
                    while (r.Read())
                    {
                        string path = ResolveUrl(r["ImagePath"].ToString());
                        if (first) { litMainImage.Text = $"<img src='{path}' alt='item'/>"; first = false; }
                        thumbs.Append($"<img src='{path}' class='thumb' onclick=\"switchImage('{path}')\" />");
                    }
                    litThumbs.Text = thumbs.ToString();
                }
            }
        }

        private void UpdateViewCount(int listingID, SqlConnection conn)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand("UPDATE Listings SET ViewCount = ViewCount + 1 WHERE ListingID=@ID", conn))
                { cmd.Parameters.AddWithValue("@ID", listingID); cmd.ExecuteNonQuery(); }
            }
            catch { }
        }

        protected void BtnAddToCart_Click(object sender, EventArgs e)
        {
            if (NavHelper.GetRole() != "Buyer")
            { litMessage.Text = "<div class='server-message error'>Only buyers can add to basket.</div>"; return; }

            int listingID = Convert.ToInt32(Request.QueryString["id"]);
            int buyerID = NavHelper.GetUserID();
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO Basket (BuyerID, ListingID, DateAdded) VALUES (@BID, @LID, GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        cmd.ExecuteNonQuery();
                    }
                }
                litMessage.Text = "<div class='server-message success'>✅ Added to basket! <a href='Basket.aspx'>View Basket →</a></div>";
                btnAddToCart.Text = "✅ Already in Basket";
                btnAddToCart.Enabled = false;
            }
            catch { litMessage.Text = "<div class='server-message error'>Could not add to basket. It may already be there.</div>"; }
        }

        protected void BtnWishlist_Click(object sender, EventArgs e)
        {
            if (NavHelper.GetRole() != "Buyer") return;
            int listingID = Convert.ToInt32(Request.QueryString["id"]);
            int buyerID = NavHelper.GetUserID();
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Wishlists WHERE BuyerID=@BID AND ListingID=@LID", conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        bool alreadySaved = (int)cmd.ExecuteScalar() > 0;

                        if (alreadySaved)
                        {
                            using (SqlCommand d = new SqlCommand("DELETE FROM Wishlists WHERE BuyerID=@BID AND ListingID=@LID", conn))
                            { d.Parameters.AddWithValue("@BID", buyerID); d.Parameters.AddWithValue("@LID", listingID); d.ExecuteNonQuery(); }
                            btnWishlist.Text = "🤍 Save to Wishlist"; btnWishlist.CssClass = "btn-wishlist-detail"; ToastMessage = "💔 Removed from wishlist.";
                        }
                        else
                        {
                            using (SqlCommand i = new SqlCommand("INSERT INTO Wishlists (BuyerID, ListingID, DateAdded) VALUES (@BID, @LID, GETDATE())", conn))
                            { i.Parameters.AddWithValue("@BID", buyerID); i.Parameters.AddWithValue("@LID", listingID); i.ExecuteNonQuery(); }
                            btnWishlist.Text = "❤️ Wishlisted"; btnWishlist.CssClass = "btn-wishlist-detail wished"; ToastMessage = "❤️ Saved to wishlist!";
                        }
                    }
                }
            }
            catch (Exception ex)
            { System.Diagnostics.Debug.WriteLine("Wishlist Error: " + ex.Message); ToastMessage = "❌ Could not update wishlist. Please try again."; }
        }

        private void ShowNotFound()
        { pnlDetail.Visible = false; pnlNotFound.Visible = true; }
    }
}
