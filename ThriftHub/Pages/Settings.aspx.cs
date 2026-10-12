using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace ThriftHub.Pages
{
    public partial class Settings : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireLogin();
            if (!IsPostBack)
                LoadProfile();
        }

        private void LoadProfile()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "SELECT FullName, Email, Role FROM Users WHERE UserID=@ID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", NavHelper.GetUserID());
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string name = r["FullName"].ToString();
                            string email = r["Email"].ToString();
                            string role = r["Role"].ToString();

                            litName.Text = name;
                            litProfileName.Text = name;
                            litProfileEmail.Text = email;
                            litAvatar.Text = name.Length > 0 ? name.Substring(0, 1).ToUpper() : "👤";

                            string colour = role == "Admin" ? "#C0392B"
                                          : role == "Moderator" ? "#8E44AD"
                                          : role == "Seller" ? "#27AE60"
                                          : "#2980B9";

                            litProfileRole.Text = $"<span class='role-badge' style='background:{colour}'>{role}</span>";
                        }
                    }
                }
            }
        }

        protected void BtnChangePass_Click(object sender, EventArgs e)
        {
            string current = txtCurrentPass.Text;
            string newPass = txtNewPass.Text;
            string confirm = txtConfirmPass.Text;

            if (string.IsNullOrEmpty(current) || string.IsNullOrEmpty(newPass))
            {
                litMessage.Text = "<div class='server-message error'>❌ Please fill in all password fields.</div>";
                return;
            }
            if (newPass != confirm)
            {
                litMessage.Text = "<div class='server-message error'>❌ New passwords do not match.</div>";
                return;
            }
            if (newPass.Length < 6)
            {
                litMessage.Text = "<div class='server-message error'>❌ Password must be at least 6 characters.</div>";
                return;
            }

            string currentHash = HashPassword(current);
            string newHash = HashPassword(newPass);

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();

                string verifySql = "SELECT COUNT(*) FROM Users WHERE UserID=@ID AND PasswordHash=@Hash";
                using (SqlCommand cmd = new SqlCommand(verifySql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", NavHelper.GetUserID());
                    cmd.Parameters.AddWithValue("@Hash", currentHash);
                    if ((int)cmd.ExecuteScalar() == 0)
                    {
                        litMessage.Text = "<div class='server-message error'>❌ Current password is incorrect.</div>";
                        return;
                    }
                }

                string updateSql = "UPDATE Users SET PasswordHash=@Hash WHERE UserID=@ID";
                using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                {
                    cmd.Parameters.AddWithValue("@Hash", newHash);
                    cmd.Parameters.AddWithValue("@ID", NavHelper.GetUserID());
                    cmd.ExecuteNonQuery();
                }
            }

            txtCurrentPass.Text = "";
            txtNewPass.Text = "";
            txtConfirmPass.Text = "";
            litMessage.Text = "<div class='server-message success'>✅ Password updated successfully!</div>";
        }

        protected void BtnClearBasket_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "DELETE FROM Basket WHERE BuyerID=@ID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", NavHelper.GetUserID());
                    cmd.ExecuteNonQuery();
                }
            }
            litMessage.Text = "<div class='server-message success'>✅ Basket cleared.</div>";
        }

        protected void BtnDeactivate_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "UPDATE Users SET IsActive=0 WHERE UserID=@ID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", NavHelper.GetUserID());
                    cmd.ExecuteNonQuery();
                }
            }
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Logout.aspx");
        }

        private string HashPassword(string password)
        {
            using (var sha = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(bytes);
            }
        }

    
    }
}