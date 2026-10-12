using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Moderator
{
    public partial class PendingListings : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Moderator");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
                LoadPending();
        }

        private void LoadPending()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT l.ListingID, l.Title, l.Description, l.Brand,
                           l.Size, l.Condition, l.Gender, l.Price, l.DateListed,
                           ISNULL(c.Name, 'Uncategorised') AS CategoryName,
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
                        pnlEmpty.Visible = true;
                        rptPending.Visible = false;
                        litCount.Text = "";
                    }
                    else
                    {
                        pnlEmpty.Visible = false;
                        rptPending.Visible = true;
                        litCount.Text = $"<span class='badge-count'>{dt.Rows.Count}</span>";
                        rptPending.DataSource = dt;
                        rptPending.DataBind();
                    }
                }
            }
        }

        // Must be protected so Repeater can call it
        protected string GetImage(object listingID)
        {
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    string sql = @"SELECT TOP 1 ImagePath
                                   FROM ListingImages
                                   WHERE ListingID = @ID AND IsPrimary = 1";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", listingID);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            return $"<img src='{ResolveUrl(result.ToString())}' alt='Item'/>";
                    }
                }
            }
            catch { }
            return "👗";
        }

        protected void ModerateItem(object sender, CommandEventArgs e)
        {
            int listingID = Convert.ToInt32(e.CommandArgument);
            string action = e.CommandName;
            string note = hdnNote.Value;
            int modID = NavHelper.GetUserID();
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
                            ModeratedBy     = @ModID,
                            ModeratedDate   = GETDATE()
                        WHERE ListingID = @ID";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Status", newStatus);
                        cmd.Parameters.AddWithValue("@Notes", string.IsNullOrEmpty(note) ? (object)DBNull.Value : note);
                        cmd.Parameters.AddWithValue("@ModID", modID);
                        cmd.Parameters.AddWithValue("@ID", listingID);
                        cmd.ExecuteNonQuery();
                    }

                    NotifySeller(conn, listingID, newStatus, note);
                }

                string msg = action == "Approve"
                    ? "✅ Listing approved and is now live in the catalogue."
                    : "❌ Listing rejected. Seller has been notified.";

                litMessage.Text = $"<div class='server-message success'>{msg}</div>";
                hdnNote.Value = "";
                hdnListingID.Value = "";

                LoadPending();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Moderation Error: " + ex.Message);
                litMessage.Text = $"<div class='server-message error'>Something went wrong: {ex.Message}</div>";
            }
        }

        private void NotifySeller(SqlConnection conn, int listingID, string status, string note)
        {
            try
            {
                string itemTitle = "";
                int sellerID = 0;

                string titleSql = "SELECT Title, SellerID FROM Listings WHERE ListingID=@ID";
                using (SqlCommand cmd = new SqlCommand(titleSql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", listingID);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            itemTitle = r["Title"].ToString();
                            sellerID = Convert.ToInt32(r["SellerID"]);
                        }
                    }
                }

                if (sellerID == 0) return;

                string msg = status == "Approved"
                    ? $"Your listing \"{itemTitle}\" has been approved and is now live!"
                    : $"Your listing \"{itemTitle}\" was rejected. {(string.IsNullOrEmpty(note) ? "" : "Note: " + note)}";

                string notifTitle = status == "Approved" ? "Listing Approved ✅" : "Listing Rejected ❌";

                string notifSql = @"
                    INSERT INTO Notifications (UserID, Title, Message, IsRead, CreatedAt)
                    VALUES (@UID, @Title, @Msg, 0, GETDATE())";

                using (SqlCommand cmd = new SqlCommand(notifSql, conn))
                {
                    cmd.Parameters.AddWithValue("@UID", sellerID);
                    cmd.Parameters.AddWithValue("@Title", notifTitle);
                    cmd.Parameters.AddWithValue("@Msg", msg);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }
    }
}