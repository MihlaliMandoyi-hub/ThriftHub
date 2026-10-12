using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Admin
{
    public partial class UserManagement : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Admin");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
            {
                LoadStats();
                LoadUsers();
            }
        }

        // =============================================
        // Stats
        // =============================================
        private void LoadStats()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                litTotalUsers.Text = Scalar(conn, "SELECT COUNT(*) FROM Users WHERE Role <> 'Admin'").ToString();
                litTotalBuyers.Text = Scalar(conn, "SELECT COUNT(*) FROM Users WHERE Role = 'Buyer'").ToString();
                litTotalSellers.Text = Scalar(conn, "SELECT COUNT(*) FROM Users WHERE Role = 'Seller'").ToString();
                litActiveUsers.Text = Scalar(conn, "SELECT COUNT(*) FROM Users WHERE ISNULL(AccountStatus,'Active') = 'Active' AND Role <> 'Admin'").ToString();
                litBannedUsers.Text = Scalar(conn, "SELECT COUNT(*) FROM Users WHERE ISNULL(AccountStatus,'Active') IN ('Banned','Suspended') AND Role <> 'Admin'").ToString();
            }
        }

        private int Scalar(SqlConnection conn, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
                return (int)cmd.ExecuteScalar();
        }

        // =============================================
        // Load users table
        // =============================================
        private void LoadUsers()
        {
            string search = txtSearch.Text.Trim();
            string role = ddlRole.SelectedValue;
            string status = ddlStatus.SelectedValue;

            string sql = @"
                SELECT
                    u.UserID, u.FullName, u.Email, u.Role,
                    ISNULL(u.AccountStatus, 'Active') AS AccountStatus,
                    u.DateJoined,
                    (SELECT COUNT(*) FROM Orders   WHERE BuyerID  = u.UserID) AS OrderCount,
                    (SELECT COUNT(*) FROM Listings WHERE SellerID = u.UserID) AS ListingCount
                FROM Users u
                WHERE (@Search = '' OR u.FullName LIKE '%'+@Search+'%' OR u.Email LIKE '%'+@Search+'%')
                  AND (@Role   = '' OR u.Role = @Role)
                  AND (@Status = '' OR ISNULL(u.AccountStatus,'Active') = @Status)
                ORDER BY u.DateJoined DESC";

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Search", search);
                    cmd.Parameters.AddWithValue("@Role", role);
                    cmd.Parameters.AddWithValue("@Status", status);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    litCount.Text = dt.Rows.Count.ToString();

                    if (dt.Rows.Count == 0)
                    {
                        pnlEmpty.Visible = true;
                        pnlTable.Visible = false;
                    }
                    else
                    {
                        pnlEmpty.Visible = false;
                        pnlTable.Visible = true;
                        rptUsers.DataSource = dt;
                        rptUsers.DataBind();
                    }
                }
            }
        }

        // =============================================
        // BtnConfirmAction_Click — the REAL handler
        // Called when JS sets hidden fields and clicks
        // the hidden button
        // =============================================
        protected void BtnConfirmAction_Click(object sender, EventArgs e)
        {
            string rawID = hdnTargetUserID.Value;
            string action = hdnAction.Value.Trim().ToLower();
            string reason = hdnReason.Value.Trim();

            // Validate
            if (!int.TryParse(rawID, out int userID) || userID == 0 || string.IsNullOrEmpty(action))
            {
                litMessage.Text = "<div class='server-message error'>❌ Invalid request. Please try again.</div>";
                LoadStats(); LoadUsers(); return;
            }

            // Prevent acting on yourself
            if (userID == NavHelper.GetUserID())
            {
                litMessage.Text = "<div class='server-message error'>❌ You cannot modify your own account.</div>";
                LoadStats(); LoadUsers(); return;
            }

            string newStatus;
            switch (action)
            {
                case "suspend": newStatus = "Suspended"; break;
                case "ban": newStatus = "Banned"; break;
                case "restore": newStatus = "Active"; break;
                default:
                    litMessage.Text = "<div class='server-message error'>❌ Unknown action.</div>";
                    LoadStats(); LoadUsers(); return;
            }

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();

                    // Guard — never ban/suspend another admin
                    string roleCheck = "SELECT ISNULL(Role,'') FROM Users WHERE UserID=@UID";
                    string targetRole;
                    using (SqlCommand cmd = new SqlCommand(roleCheck, conn))
                    {
                        cmd.Parameters.AddWithValue("@UID", userID);
                        targetRole = cmd.ExecuteScalar()?.ToString() ?? "";
                    }

                    if (targetRole == "Admin" && action != "restore")
                    {
                        litMessage.Text = "<div class='server-message error'>❌ Cannot suspend or ban another admin.</div>";
                        LoadStats(); LoadUsers(); return;
                    }

                    // ✅ Update AccountStatus
                    string updateSql = "UPDATE Users SET AccountStatus = @Status WHERE UserID = @UID";
                    using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Status", newStatus);
                        cmd.Parameters.AddWithValue("@UID", userID);
                        int rows = cmd.ExecuteNonQuery();

                        if (rows == 0)
                        {
                            litMessage.Text = "<div class='server-message error'>❌ User not found.</div>";
                            LoadStats(); LoadUsers(); return;
                        }
                    }

                    // ✅ Log to AdminActions (optional table)
                    try
                    {
                        string logSql = @"
                            INSERT INTO AdminActions (AdminID, TargetUserID, Action, Reason, ActionDate)
                            VALUES (@AdminID, @TargetID, @Action, @Reason, GETDATE())";
                        using (SqlCommand cmd = new SqlCommand(logSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@AdminID", NavHelper.GetUserID());
                            cmd.Parameters.AddWithValue("@TargetID", userID);
                            cmd.Parameters.AddWithValue("@Action", newStatus);
                            cmd.Parameters.AddWithValue("@Reason", string.IsNullOrEmpty(reason) ? (object)DBNull.Value : reason);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    catch { /* AdminActions table is optional */ }
                }

                string icon = action == "restore" ? "✅" : action == "ban" ? "🚫" : "⏸️";
                litMessage.Text = $"<div class='server-message success'>{icon} User successfully {newStatus.ToLower()}.</div>";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("UserManagement Error: " + ex.Message);
                litMessage.Text = "<div class='server-message error'>❌ Action failed: " + ex.Message + "</div>";
            }

            // Reset hidden fields
            hdnTargetUserID.Value = "0";
            hdnAction.Value = "";
            hdnReason.Value = "";

            LoadStats();
            LoadUsers();
        }

        protected void BtnSearch_Click(object sender, EventArgs e) { LoadUsers(); }

        protected void BtnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlRole.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            LoadUsers();
        }

        // =============================================
        // Badge helpers — called from Repeater
        // =============================================
        protected string GetRoleBadge(string role)
        {
            switch (role)
            {
                case "Buyer": return "<span class='badge badge-buyer'>🛍️ Buyer</span>";
                case "Seller": return "<span class='badge badge-seller'>🏪 Seller</span>";
                case "Admin": return "<span class='badge badge-admin'>🛡️ Admin</span>";
                default: return $"<span class='badge'>{role}</span>";
            }
        }

        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Suspended": return "<span class='status-suspended'>⏸️ Suspended</span>";
                case "Banned": return "<span class='status-banned'>🚫 Banned</span>";
                default: return "<span class='status-active'>✅ Active</span>";
            }
        }

        // =============================================
        // Renders action buttons as plain HTML —
        // avoids Repeater LinkButton visibility issues
        // =============================================
        protected string GetActionButtons(object userID, string name, string status, string role)
        {
            if (role == "Admin") return "<span style='color:var(--muted);font-size:0.78rem'>Protected</span>";

            // Escape name for JS string
            string safeName = name.Replace("'", "\\'").Replace("\"", "&quot;");
            string uid = userID.ToString();

            if (status == "Active")
                return $@"
                    <button type='button' class='btn-action btn-suspend'
                        onclick=""openModal({uid}, '{safeName}', 'suspend')"">⏸️ Suspend</button>
                    <button type='button' class='btn-action btn-ban'
                        onclick=""openModal({uid}, '{safeName}', 'ban')"">🚫 Ban</button>";

            return $@"
                <button type='button' class='btn-action btn-restore'
                    onclick=""openModal({uid}, '{safeName}', 'restore')"">✅ Restore</button>";
        }
    }
}
