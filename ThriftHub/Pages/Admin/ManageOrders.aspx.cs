using System;
using System.Data;
using System.Data.SqlClient;
using System.EnterpriseServices;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Admin
{
    public partial class ManageOrders : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Admin");
            litName.Text = NavHelper.GetFullName();
            if (!IsPostBack)
                LoadOrders();
        }

        private void LoadOrders()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT o.OrderID, o.OrderDate, o.FinalAmount,
                           o.PaymentMethod, o.OrderStatus, o.ShippingAddress,
                           u.FullName AS BuyerName
                    FROM Orders o
                    JOIN Users u ON o.BuyerID = u.UserID
                    ORDER BY o.OrderDate DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlEmpty.Visible = true;
                        rptOrders.Visible = false;
                    }
                    else
                    {
                        pnlEmpty.Visible = false;
                        rptOrders.Visible = true;
                        rptOrders.DataSource = dt;
                        rptOrders.DataBind();
                    }
                }
            }
        }

        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Confirmed": return "<span class='badge badge-confirmed'>✅ Confirmed</span>";
                case "Shipped": return "<span class='badge badge-shipped'>🚚 Shipped</span>";
                case "Delivered": return "<span class='badge badge-delivered'>📦 Delivered</span>";
                case "Cancelled": return "<span class='badge badge-cancelled'>❌ Cancelled</span>";
                default: return "<span class='badge badge-processing'>⏳ Processing</span>";
            }
        }

        protected string GetOrderItems(object orderID)
        {
            var sb = new StringBuilder();
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    string sql = @"
                        SELECT l.Title, oi.PriceAtPurchase
                        FROM OrderItems oi
                        JOIN Listings l ON oi.ListingID = l.ListingID
                        WHERE oi.OrderID = @OID";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@OID", orderID);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                sb.Append("<div class='oi-row'>");
                                sb.Append("<span>" + r["Title"] + "</span>");
                                sb.Append("<span>R " + Convert.ToDecimal(r["PriceAtPurchase"]).ToString("F2") + "</span>");
                                sb.Append("</div>");
                            }
                        }
                    }
                }
            }
            catch { }
            return sb.ToString();
        }

        protected string GetTracking(object orderID)
        {
            var sb = new StringBuilder();
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    string sql = @"
                        SELECT Status, Notes, Timestamp
                        FROM DeliveryTracking
                        WHERE OrderID = @OID
                        ORDER BY Timestamp DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@OID", orderID);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            bool hasRows = false;
                            while (r.Read())
                            {
                                hasRows = true;
                                sb.Append("<div class='timeline-item'>");
                                sb.Append("<div class='timeline-status'>" + r["Status"] + "</div>");
                                sb.Append("<div class='timeline-time'>" + Convert.ToDateTime(r["Timestamp"]).ToString("dd MMM yyyy HH:mm") + "</div>");
                                if (r["Notes"] != DBNull.Value)
                                    sb.Append("<div class='timeline-time'>" + r["Notes"] + "</div>");
                                sb.Append("</div>");
                            }
                            if (!hasRows)
                                sb.Append("<div style='color:#7A7A6E;font-size:0.85rem'>No tracking updates yet.</div>");
                        }
                    }
                }
            }
            catch { }
            return sb.ToString();
        }

        protected void UpdateOrderStatus(object sender, CommandEventArgs e)
        {
            int orderID = Convert.ToInt32(hdnOrderID.Value);
            string status = hdnStatus.Value;
            string note = hdnNote.Value;
            string tracking = hdnTracking.Value;

            if (orderID == 0 || string.IsNullOrEmpty(status)) return;

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();

                    // Update order status
                    string updateSql = "UPDATE Orders SET OrderStatus=@Status WHERE OrderID=@OID";
                    using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Status", status);
                        cmd.Parameters.AddWithValue("@OID", orderID);
                        cmd.ExecuteNonQuery();
                    }

                    // Update tracking number if provided
                    if (!string.IsNullOrEmpty(tracking))
                    {
                        string tSql = "UPDATE Orders SET TrackingNumber=@TN WHERE OrderID=@OID";
                        using (SqlCommand cmd = new SqlCommand(tSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@TN", tracking);
                            cmd.Parameters.AddWithValue("@OID", orderID);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    // Build combined note
                    string fullNote = note;
                    if (!string.IsNullOrEmpty(tracking))
                        fullNote = (string.IsNullOrEmpty(fullNote) ? "" : fullNote + " | ")
                                 + "Tracking: " + tracking;

                    // Insert tracking history entry
                    string trackSql = @"
                        INSERT INTO DeliveryTracking
                            (OrderID, Status, Notes, UpdatedBy, Timestamp)
                        VALUES
                            (@OID, @Status, @Notes, @UID, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(trackSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@OID", orderID);
                        cmd.Parameters.AddWithValue("@Status", status);
                        cmd.Parameters.AddWithValue("@Notes", string.IsNullOrEmpty(fullNote)
                            ? (object)DBNull.Value : fullNote);
                        cmd.Parameters.AddWithValue("@UID", NavHelper.GetUserID());
                        cmd.ExecuteNonQuery();
                    }

                    // Notify buyer
                    NotifyBuyer(conn, orderID, status, note, tracking);
                }

                litMessage.Text = "<div class='server-message success'>✅ Order #" + orderID + " updated to <strong>" + status + "</strong>.</div>";
                hdnOrderID.Value = "";
                hdnStatus.Value = "";
                hdnNote.Value = "";
                hdnTracking.Value = "";
                LoadOrders();
            }
            catch (Exception ex)
            {
                litMessage.Text = "<div class='server-message error'>❌ Error: " + ex.Message + "</div>";
            }
        }

        private void NotifyBuyer(SqlConnection conn, int orderID,
            string status, string note, string tracking)
        {
            try
            {
                int buyerID = 0;
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT BuyerID FROM Orders WHERE OrderID=@OID", conn))
                {
                    cmd.Parameters.AddWithValue("@OID", orderID);
                    var res = cmd.ExecuteScalar();
                    if (res != null) buyerID = Convert.ToInt32(res);
                }
                if (buyerID == 0) return;

                string emoji = status == "Shipped" ? "🚚"
                             : status == "Delivered" ? "📦"
                             : status == "Confirmed" ? "✅"
                             : status == "Cancelled" ? "❌" : "⏳";

                string msg = "Your order #" + orderID + " is now: " + status + ".";
                if (!string.IsNullOrEmpty(tracking)) msg += " Tracking: " + tracking + ".";
                if (!string.IsNullOrEmpty(note)) msg += " " + note;

                string notifSql = @"
                    INSERT INTO Notifications (UserID, Title, Message, IsRead, CreatedAt)
                    VALUES (@UID, @Title, @Msg, 0, GETDATE())";

                using (SqlCommand cmd = new SqlCommand(notifSql, conn))
                {
                    cmd.Parameters.AddWithValue("@UID", buyerID);
                    cmd.Parameters.AddWithValue("@Title", emoji + " Order " + status);
                    cmd.Parameters.AddWithValue("@Msg", msg);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }
    }
}