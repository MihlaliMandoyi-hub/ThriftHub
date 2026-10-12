using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Seller
{
    public partial class ListItem : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Seller");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
            {
                LoadCategories();

                // Edit mode
                if (Request.QueryString["edit"] != null)
                {
                    litPageTitle.Text = "Edit Listing";
                    btnSubmit.Text = "Save Changes";
                    LoadListingForEdit(Convert.ToInt32(Request.QueryString["edit"]));
                }
            }
        }

        private void LoadCategories()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "SELECT CategoryID, Name FROM Categories ORDER BY Name";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            ddlCategory.Items.Add(new System.Web.UI.WebControls.ListItem(
                                r["Name"].ToString(), r["CategoryID"].ToString()));
                        }
                    }
                }
            }
        }

        private void LoadListingForEdit(int listingID)
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"SELECT * FROM Listings
                               WHERE ListingID=@ID AND SellerID=@SellerID AND Status != 'Sold'";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", listingID);
                    cmd.Parameters.AddWithValue("@SellerID", NavHelper.GetUserID());
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            txtTitle.Text = r["Title"].ToString();
                            txtDescription.Text = r["Description"].ToString();
                            txtBrand.Text = r["Brand"].ToString();
                            txtColour.Text = r["Colour"].ToString();
                            txtPrice.Text = r["Price"].ToString();
                            ddlSize.SelectedValue = r["Size"].ToString();
                            ddlCondition.SelectedValue = r["Condition"].ToString();
                            ddlGender.SelectedValue = r["Gender"].ToString();
                            if (r["CategoryID"] != DBNull.Value)
                                ddlCategory.SelectedValue = r["CategoryID"].ToString();
                        }
                        else
                        {
                            Response.Redirect("Dashboard.aspx");
                        }
                    }
                }
            }
        }

        protected void BtnSubmit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int sellerID = NavHelper.GetUserID();
            string title = txtTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            string brand = txtBrand.Text.Trim();
            string colour = txtColour.Text.Trim();
            decimal price = Convert.ToDecimal(txtPrice.Text.Trim());
            string size = ddlSize.SelectedValue;
            string condition = ddlCondition.SelectedValue;
            string gender = ddlGender.SelectedValue;
            int? categoryID = string.IsNullOrEmpty(ddlCategory.SelectedValue)
                                    ? (int?)null
                                    : Convert.ToInt32(ddlCategory.SelectedValue);

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    int listingID;

                    bool isEdit = Request.QueryString["edit"] != null;

                    if (isEdit)
                    {
                        listingID = Convert.ToInt32(Request.QueryString["edit"]);
                        string updateSql = @"
                            UPDATE Listings SET
                                Title=@Title, Description=@Description, Brand=@Brand,
                                Colour=@Colour, Price=@Price, Size=@Size,
                                Condition=@Condition, Gender=@Gender, CategoryID=@CatID,
                                Status='Pending', ModerationNotes=NULL, DateUpdated=GETDATE()
                            WHERE ListingID=@ID AND SellerID=@SellerID";
                        using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@Title", title);
                            cmd.Parameters.AddWithValue("@Description", description);
                            cmd.Parameters.AddWithValue("@Brand", string.IsNullOrEmpty(brand) ? (object)DBNull.Value : brand);
                            cmd.Parameters.AddWithValue("@Colour", string.IsNullOrEmpty(colour) ? (object)DBNull.Value : colour);
                            cmd.Parameters.AddWithValue("@Price", price);
                            cmd.Parameters.AddWithValue("@Size", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size);
                            cmd.Parameters.AddWithValue("@Condition", string.IsNullOrEmpty(condition) ? (object)DBNull.Value : condition);
                            cmd.Parameters.AddWithValue("@Gender", string.IsNullOrEmpty(gender) ? (object)DBNull.Value : gender);
                            cmd.Parameters.AddWithValue("@CatID", categoryID.HasValue ? (object)categoryID.Value : DBNull.Value);
                            cmd.Parameters.AddWithValue("@ID", listingID);
                            cmd.Parameters.AddWithValue("@SellerID", sellerID);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        string insertSql = @"
                            INSERT INTO Listings
                                (SellerID, CategoryID, Title, Description, Brand, Size,
                                 Condition, Colour, Gender, Price, Status, DateListed)
                            VALUES
                                (@SellerID, @CatID, @Title, @Description, @Brand, @Size,
                                 @Condition, @Colour, @Gender, @Price, 'Pending', GETDATE());
                            SELECT SCOPE_IDENTITY();";

                        using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@SellerID", sellerID);
                            cmd.Parameters.AddWithValue("@CatID", categoryID.HasValue ? (object)categoryID.Value : DBNull.Value);
                            cmd.Parameters.AddWithValue("@Title", title);
                            cmd.Parameters.AddWithValue("@Description", description);
                            cmd.Parameters.AddWithValue("@Brand", string.IsNullOrEmpty(brand) ? (object)DBNull.Value : brand);
                            cmd.Parameters.AddWithValue("@Size", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size);
                            cmd.Parameters.AddWithValue("@Condition", string.IsNullOrEmpty(condition) ? (object)DBNull.Value : condition);
                            cmd.Parameters.AddWithValue("@Colour", string.IsNullOrEmpty(colour) ? (object)DBNull.Value : colour);
                            cmd.Parameters.AddWithValue("@Gender", string.IsNullOrEmpty(gender) ? (object)DBNull.Value : gender);
                            cmd.Parameters.AddWithValue("@Price", price);
                            listingID = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                    }

                    // Save uploaded images
                    SaveImages(conn, listingID, sellerID);
                }

                Response.Redirect("Dashboard.aspx?listed=1");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ListItem Error: " + ex.Message);
                ShowMessage("Something went wrong: " + ex.Message, "error");
            }
        }

        private void SaveImages(SqlConnection conn, int listingID, int sellerID)
        {
            if (fuImages.HasFiles)
            {
                string uploadDir = Server.MapPath("~/Uploads/Listings/");
                if (!Directory.Exists(uploadDir))
                    Directory.CreateDirectory(uploadDir);

                bool first = true;
                int count = 0;

                foreach (System.Web.HttpPostedFile file in fuImages.PostedFiles)
                {
                    if (count >= 5) break;
                    if (file.ContentLength == 0) continue;

                    string ext = Path.GetExtension(file.FileName).ToLower();
                    if (ext != ".jpg" && ext != ".jpeg" && ext != ".png") continue;

                    string fileName = $"listing_{listingID}_{sellerID}_{DateTime.Now.Ticks}{ext}";
                    string filePath = Path.Combine(uploadDir, fileName);
                    file.SaveAs(filePath);

                    string sql = @"INSERT INTO ListingImages (ListingID, ImagePath, IsPrimary, UploadedAt)
                                   VALUES (@ListingID, @Path, @Primary, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ListingID", listingID);
                        cmd.Parameters.AddWithValue("@Path", "~/Uploads/Listings/" + fileName);
                        cmd.Parameters.AddWithValue("@Primary", first ? 1 : 0);
                        cmd.ExecuteNonQuery();
                    }

                    first = false;
                    count++;
                }
            }
        }

        private void ShowMessage(string message, string type)
        {
            litMessage.Text = $"<div class='server-message {type}'>{message}</div>";
        }
    }
}