using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace ThriftHub
{
    public partial class SetPassword : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void BtnSet_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                litMsg.Text = "<div class='msg err'>❌ Please enter both email and password.</div>";
                return;
            }

            // Generate SHA256 hash — same as Register and Login use
            string hash;
            using (var sha = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                hash = Convert.ToBase64String(bytes);
            }

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();

                    // Check user exists first
                    string checkSql = "SELECT COUNT(*) FROM Users WHERE Email = @Email";
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        int count = (int)cmd.ExecuteScalar();
                        if (count == 0)
                        {
                            litMsg.Text = "<div class='msg err'>❌ No account found with that email address.</div>";
                            return;
                        }
                    }

                    // Update the password
                    string updateSql = "UPDATE Users SET PasswordHash = @Hash WHERE Email = @Email";
                    using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Hash", hash);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.ExecuteNonQuery();
                    }

                    litMsg.Text = $@"
                        <div class='msg ok'>
                            ✅ Password updated successfully!<br/>
                            <strong>Email:</strong> {email}<br/>
                            <strong>Password:</strong> {password}<br/>
                            You can now <a href='Login.aspx' style='color:#27AE60;font-weight:600'>sign in</a>.
                        </div>";
                }
            }
            catch (Exception ex)
            {
                litMsg.Text = $"<div class='msg err'>❌ Error: {ex.Message}</div>";
            }
        }
    }
}
