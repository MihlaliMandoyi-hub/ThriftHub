using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ThriftHub
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] != null)
                Response.Redirect("Default.aspx");
        }

        protected void BtnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            // ===== SERVER-SIDE TERMS CHECK =====
            // This runs even if someone bypasses the JS client-side check
            if (!chkTerms.Checked)
            {
                ShowMessage("❌ You must agree to the Terms &amp; Conditions before registering.", "error");
                return;
            }
            // ====================================

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string phone = txtPhone.Text.Trim();
            string password = txtPassword.Text;
            string address1 = txtAddress1.Text.Trim();
            string city = txtCity.Text.Trim();
            string province = ddlProvince.SelectedValue;
            string postal = txtPostal.Text.Trim();
            string role = rbSeller.Checked ? "Seller" : "Buyer";

            string passwordHash = HashPassword(password);

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();

                    // Check if email already exists
                    string checkSql = "SELECT COUNT(1) FROM Users WHERE Email = @Email";
                    using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@Email", email);
                        int count = (int)checkCmd.ExecuteScalar();
                        if (count > 0)
                        {
                            ShowMessage("An account with this email already exists. <a href='Login.aspx'>Sign in instead?</a>", "error");
                            return;
                        }
                    }

                    // Insert new user
                    string insertSql = @"
                        INSERT INTO Users
                            (FullName, Email, PasswordHash, PhoneNumber, Role,
                             AddressLine1, City, Province, PostalCode, Country,
                             IsActive, DateJoined)
                        VALUES
                            (@FullName, @Email, @PasswordHash, @Phone, @Role,
                             @Address1, @City, @Province, @Postal, 'South Africa',
                             1, GETDATE());
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand insertCmd = new SqlCommand(insertSql, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@FullName", fullName);
                        insertCmd.Parameters.AddWithValue("@Email", email);
                        insertCmd.Parameters.AddWithValue("@PasswordHash", passwordHash);
                        insertCmd.Parameters.AddWithValue("@Phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                        insertCmd.Parameters.AddWithValue("@Role", role);
                        insertCmd.Parameters.AddWithValue("@Address1", string.IsNullOrEmpty(address1) ? (object)DBNull.Value : address1);
                        insertCmd.Parameters.AddWithValue("@City", string.IsNullOrEmpty(city) ? (object)DBNull.Value : city);
                        insertCmd.Parameters.AddWithValue("@Province", string.IsNullOrEmpty(province) ? (object)DBNull.Value : province);
                        insertCmd.Parameters.AddWithValue("@Postal", string.IsNullOrEmpty(postal) ? (object)DBNull.Value : postal);

                        int newUserID = Convert.ToInt32(insertCmd.ExecuteScalar());

                        Session["UserID"] = newUserID;
                        Session["UserRole"] = role;
                        Session["FullName"] = fullName;

                        CreateWelcomeNotification(conn, newUserID, fullName, role);
                    }
                }

                Response.Redirect("Login.aspx?registered=1");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Register Error: " + ex.Message);
                ShowMessage("Something went wrong: " + ex.Message, "error");
            }
        }

        private string HashPassword(string password)
        {
            using (var sha = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(bytes);
            }
        }

        private void CreateWelcomeNotification(SqlConnection conn, int userID, string fullName, string role)
        {
            try
            {
                string msg = role == "Seller"
                    ? $"Welcome to ThriftHub, {fullName}! Start by listing your first item."
                    : $"Welcome to ThriftHub, {fullName}! Browse our catalogue and find amazing deals.";

                string sql = @"INSERT INTO Notifications (UserID, Title, Message, IsRead, CreatedAt)
                               VALUES (@UserID, 'Welcome to ThriftHub!', @Message, 0, GETDATE())";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userID);
                    cmd.Parameters.AddWithValue("@Message", msg);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Non-critical */ }
        }

        private void ShowMessage(string message, string type)
        {
            litMessage.Text = $"<div class='server-message {type}'>{message}</div>";
        }
    }
}
