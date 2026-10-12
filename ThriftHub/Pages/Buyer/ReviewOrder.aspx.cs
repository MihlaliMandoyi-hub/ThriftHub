using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace ThriftHub.Pages.Buyer
{
    public partial class ReviewOrder : Page
    {
        private int _orderItemID = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Buyer");
            litName.Text = NavHelper.GetFullName();

            if (Request.QueryString["orderItemID"] == null)
            {
                Response.Redirect("OrderTracking.aspx");
                return;
            }

            _orderItemID = Convert.ToInt32(Request.QueryString["orderItemID"]);

            if (!IsPostBack)
                LoadItem();
        }

        private void LoadItem()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();

                // Check already reviewed
                string checkSql = "SELECT COUNT(*) FROM Reviews WHERE OrderItemID=@OID AND ReviewerID=@UID";
                using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                {
                    cmd.Parameters.AddWithValue("@OID", _orderItemID);
                    cmd.Parameters.AddWithValue("@UID", NavHelper.GetUserID());
                    if ((int)cmd.ExecuteScalar() > 0)
                    {
                        pnlReview.Visible = false;
                        pnlAlreadyReviewed.Visible = true;
                        return;
                    }
                }

                // Load item details
                string sql = @"
                    SELECT oi.OrderID, l.Title, l.ListingID,
                           u.FullName AS SellerName, oi.SellerID
                    FROM OrderItems oi
                    JOIN Listings l ON oi.ListingID = l.ListingID
                    JOIN Users u    ON oi.SellerID  = u.UserID
                    WHERE oi.OrderItemID = @OID";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@OID", _orderItemID);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            Response.Redirect("OrderTracking.aspx");
                            return;
                        }

                        litItemTitle.Text = r["Title"].ToString();
                        litSellerName.Text = r["SellerName"].ToString();
                        litOrderID.Text = r["OrderID"].ToString();

                        // Load image
                        int listingID = Convert.ToInt32(r["ListingID"]);
                        r.Close();
                        LoadImage(conn, listingID);
                    }
                }
            }
        }

        private void LoadImage(SqlConnection conn, int listingID)
        {
            string sql = "SELECT TOP 1 ImagePath FROM ListingImages WHERE ListingID=@ID AND IsPrimary=1";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ID", listingID);
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                    litItemImage.Text = $"<img src='{ResolveUrl(result.ToString())}' alt='item'/>";
            }
        }

        protected void BtnSubmit_Click(object sender, EventArgs e)
        {
            int rating = Convert.ToInt32(hdnRating.Value);
            string comment = txtReview.Text.Trim();

            if (rating < 1 || rating > 5)
            {
                litMessage.Text = "<div class='server-message error'>❌ Please select a star rating.</div>";
                return;
            }

            _orderItemID = Convert.ToInt32(Request.QueryString["orderItemID"]);

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();

                    // Get seller ID
                    int sellerID = 0;
                    string getSellerSql = "SELECT SellerID FROM OrderItems WHERE OrderItemID=@OID";
                    using (SqlCommand cmd = new SqlCommand(getSellerSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@OID", _orderItemID);
                        var result = cmd.ExecuteScalar();
                        if (result != null) sellerID = Convert.ToInt32(result);
                    }

                    // Insert review
                    string insertSql = @"
                        INSERT INTO Reviews
                            (OrderItemID, ReviewerID, SellerID, Rating, Comment, DatePosted, IsVisible)
                        VALUES
                            (@OID, @UID, @SID, @Rating, @Comment, GETDATE(), 1)";

                    using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@OID", _orderItemID);
                        cmd.Parameters.AddWithValue("@UID", NavHelper.GetUserID());
                        cmd.Parameters.AddWithValue("@SID", sellerID);
                        cmd.Parameters.AddWithValue("@Rating", rating);
                        cmd.Parameters.AddWithValue("@Comment", string.IsNullOrEmpty(comment) ? (object)DBNull.Value : comment);
                        cmd.ExecuteNonQuery();
                    }

                    // Notify seller
                    if (sellerID > 0)
                    {
                        string stars = new string('⭐', rating);
                        string notifSql = @"
                            INSERT INTO Notifications (UserID, Title, Message, IsRead, CreatedAt)
                            VALUES (@UID, @Title, @Msg, 0, GETDATE())";
                        using (SqlCommand cmd = new SqlCommand(notifSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@UID", sellerID);
                            cmd.Parameters.AddWithValue("@Title", "New Review Received! " + stars);
                            cmd.Parameters.AddWithValue("@Msg", $"A buyer left a {rating}-star review. {comment}");
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                pnlReview.Visible = false;
                litMessage.Text = @"
                    <div class='server-message success' style='text-align:center;padding:40px'>
                        <div style='font-size:3rem;margin-bottom:12px'>🎉</div>
                        <h3 style='margin-bottom:8px'>Thank you for your review!</h3>
                        <p style='margin-bottom:20px'>Your feedback helps the ThriftHub community.</p>
                        <a href='OrderTracking.aspx' style='color:#2C4A3E;font-weight:600;text-decoration:none'>← Back to My Orders</a>
                    </div>";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Review Error: " + ex.Message);
                litMessage.Text = $"<div class='server-message error'>❌ Could not submit review: {ex.Message}</div>";
            }
        }
    }
}