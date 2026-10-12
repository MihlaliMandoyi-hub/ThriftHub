using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Data.SqlClient;

namespace ThriftHub
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Show success message if coming from registration
                if (Request.QueryString["registered"] == "1")
                    ShowMessage("🎉 Account created successfully! Please sign in.", "success");
            }

            // If already logged in, go home
            if (Session["UserID"] != null)
                Response.Redirect("Default.aspx");
        }

        protected void BtnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();

                    // ✅ Now also fetches AccountStatus
                    string sql = @"SELECT UserID, FullName, PasswordHash, Role, IsActive,
                                          ISNULL(AccountStatus, 'Active') AS AccountStatus
                                   FROM Users WHERE Email = @Email";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                ShowMessage("❌ No account found with that email address.", "error");
                                return;
                            }

                            bool isActive = Convert.ToBoolean(reader["IsActive"]);
                            string storedHash = reader["PasswordHash"].ToString();
                            string role = reader["Role"].ToString();
                            int userID = Convert.ToInt32(reader["UserID"]);
                            string fullName = reader["FullName"].ToString();
                            string acctStatus = reader["AccountStatus"].ToString();

                            // ── Deactivated (original IsActive check) ──
                            if (!isActive)
                            {
                                ShowMessage("❌ Your account has been deactivated. Please contact support.", "error");
                                return;
                            }

                            // ── Suspended ──────────────────────────────
                            if (acctStatus == "Suspended")
                            {
                                ShowMessage("⏸️ Your account has been <strong>suspended</strong>. " +
                                            "Please contact support at support@thrifthub.co.za.", "error");
                                return;
                            }

                            // ── Banned ─────────────────────────────────
                            if (acctStatus == "Banned")
                            {
                                ShowMessage("🚫 Your account has been <strong>banned</strong> from ThriftHub. " +
                                            "If you believe this is a mistake, contact support@thrifthub.co.za.", "error");
                                return;
                            }

                            // ── Verify password ────────────────────────
                            string inputHash = HashPassword(password);
                            if (inputHash != storedHash)
                            {
                                ShowMessage("❌ Incorrect password. Please try again.", "error");
                                return;
                            }

                            // ✅ Success — set session
                            Session["UserID"] = userID;
                            Session["UserRole"] = role;
                            Session["FullName"] = fullName;
                        }
                    }

                    // Update last login
                    UpdateLastLogin((int)Session["UserID"], conn);
                }

                // Redirect based on role
                RedirectByRole((string)Session["UserRole"]);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Login Error: " + ex.Message);
                ShowMessage("Something went wrong: " + ex.Message, "error");
            }
        }

        private void UpdateLastLogin(int userID, SqlConnection conn)
        {
            try
            {
                string sql = "UPDATE Users SET LastLogin = GETDATE() WHERE UserID = @UserID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Non-critical */ }
        }

        private string HashPassword(string password)
        {
            using (var sha = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(bytes);
            }
        }

        private void RedirectByRole(string role)
        {
            switch (role)
            {
                case "Admin":
                    Response.Redirect("~/Pages/Admin/Dashboard.aspx");
                    break;
                case "Moderator":
                    Response.Redirect("~/Pages/Moderator/PendingListings.aspx");
                    break;
                case "Seller":
                    Response.Redirect("~/Pages/Seller/Dashboard.aspx");
                    break;
                default:
                    Response.Redirect("~/Pages/Buyer/Catalogue.aspx");
                    break;
            }
        }

        private void ShowMessage(string message, string type)
        {
            litMessage.Text = $"<div class='server-message {type}'>{message}</div>";
        }
    }
}
