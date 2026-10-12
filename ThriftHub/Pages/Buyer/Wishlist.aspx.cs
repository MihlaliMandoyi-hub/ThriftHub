using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Buyer
{
    public partial class Wishlist : Page
    {
        public string ToastMessage = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Buyer");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
                LoadWishlist();
        }

        private void LoadWishlist()
        {
            int buyerID = NavHelper.GetUserID();

            string sql = @"
                SELECT w.DateAdded, l.ListingID, l.Title, l.Brand,
                       l.Size, l.Condition, l.Price,
                       ISNULL(c.Name, 'Uncategorised') AS CategoryName
                FROM Wishlists w
                JOIN Listings l ON w.ListingID = l.ListingID
                LEFT JOIN Categories c ON l.CategoryID = c.CategoryID
                WHERE w.BuyerID = @BID AND l.Status = 'Approved'
                ORDER BY w.DateAdded DESC";

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@BID", buyerID);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    litCount.Text = dt.Rows.Count.ToString();

                    if (dt.Rows.Count == 0)
                    {
                        pnlEmpty.Visible = true;
                        rptWishlist.Visible = false;
                    }
                    else
                    {
                        pnlEmpty.Visible = false;
                        rptWishlist.Visible = true;
                        rptWishlist.DataSource = dt;
                        rptWishlist.DataBind();
                    }
                }
            }
        }

        protected void rptWishlist_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int listingID = Convert.ToInt32(e.CommandArgument);
            int buyerID = NavHelper.GetUserID();

            if (e.CommandName == "RemoveWishlist")
            {
                RemoveFromWishlist(listingID, buyerID);
            }
            else if (e.CommandName == "AddToBasket")
            {
                AddToBasket(listingID, buyerID);
            }

            LoadWishlist();
        }

        private void RemoveFromWishlist(int listingID, int buyerID)
        {
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    string sql = "DELETE FROM Wishlists WHERE BuyerID=@BID AND ListingID=@LID";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        cmd.ExecuteNonQuery();
                    }
                }
                ToastMessage = "💔 Removed from wishlist.";
            }
            catch
            {
                litMessage.Text = "<div class='server-message error'>❌ Could not remove item. Please try again.</div>";
            }
        }

        private void AddToBasket(int listingID, int buyerID)
        {
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();

                    // Check already in basket
                    string checkSql = "SELECT COUNT(*) FROM Basket WHERE BuyerID=@BID AND ListingID=@LID";
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        if ((int)cmd.ExecuteScalar() > 0)
                        {
                            ToastMessage = "⚠️ Already in your basket!";
                            return;
                        }
                    }

                    // Check still available
                    string checkStatus = "SELECT COUNT(*) FROM Listings WHERE ListingID=@LID AND Status='Approved'";
                    using (SqlCommand cmd = new SqlCommand(checkStatus, conn))
                    {
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        if ((int)cmd.ExecuteScalar() == 0)
                        {
                            litMessage.Text = "<div class='server-message error'>❌ This item is no longer available.</div>";
                            return;
                        }
                    }

                    // Add to basket
                    string insertSql = "INSERT INTO Basket (BuyerID, ListingID, DateAdded) VALUES (@BID, @LID, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.Parameters.AddWithValue("@LID", listingID);
                        cmd.ExecuteNonQuery();
                    }
                }
                ToastMessage = "✅ Added to basket!";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Wishlist AddToBasket Error: " + ex.Message);
                litMessage.Text = "<div class='server-message error'>❌ Could not add to basket. Please try again.</div>";
            }
        }

        // Called from Repeater — must be protected
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
    }
}
