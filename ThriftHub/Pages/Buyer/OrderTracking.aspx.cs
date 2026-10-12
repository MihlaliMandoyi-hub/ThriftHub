using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace ThriftHub.Pages.Buyer
{
    public partial class OrderTracking : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Buyer");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
            {
                if (Request.QueryString["success"] == "1")
                    pnlSuccess.Visible = true;

                LoadOrders();
                CheckOrderStatusNotifications(); // ✅ add this line
            }
        }

        private void LoadOrders()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT OrderID, OrderDate, TotalAmount, DiscountAmount,
                           FinalAmount, PaymentMethod, PaymentStatus, OrderStatus, ShippingAddress
                    FROM Orders
                    WHERE BuyerID = @BID
                    ORDER BY OrderDate DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@BID", NavHelper.GetUserID());
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlEmpty.Visible = true;
                        rptOrders.Visible = false;
                        return;
                    }

                    rptOrders.DataSource = dt;
                    rptOrders.DataBind();
                }
            }
        }

        // ✅ All protected so Repeater can call them
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

        protected string GetTracking(object orderID)
        {
            StringBuilder sb = new StringBuilder();
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    string sql = @"
                        SELECT Status, Notes, Timestamp
                        FROM DeliveryTracking
                        WHERE OrderID=@OID
                        ORDER BY Timestamp ASC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@OID", orderID);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            bool hasRows = false;
                            while (r.Read())
                            {
                                hasRows = true;
                                string notes = r["Notes"] != DBNull.Value ? r["Notes"].ToString() : "";
                                string css = string.IsNullOrEmpty(notes) ? "done" : "current";
                                string noteHtml = !string.IsNullOrEmpty(notes)
                                    ? $"<div class='timeline-note'>{notes}</div>" : "";
                                sb.Append($@"
                                    <div class='timeline-item {css}'>
                                        <div class='timeline-status'>{r["Status"]}</div>
                                        <div class='timeline-time'>{Convert.ToDateTime(r["Timestamp"]).ToString("dd MMM yyyy HH:mm")}</div>
                                        {noteHtml}
                                    </div>");
                            }
                            if (!hasRows)
                                sb.Append("<div style='color:#7A7A6E;font-size:0.88rem'>No tracking updates yet.</div>");
                        }
                    }
                }
            }
            catch { sb.Append("<div style='color:#7A7A6E;font-size:0.88rem'>Could not load tracking.</div>"); }
            return sb.ToString();
        }
        public string BuyerNotificationMessage { get; set; } = string.Empty;
        public string BuyerNotificationType { get; set; } = "info";

        private void CheckOrderStatusNotifications()
        {
            string query = @"
        SELECT TOP 1 OrderID, OrderStatus 
        FROM Orders 
        WHERE BuyerID = @uid 
        ORDER BY OrderDate DESC";

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", NavHelper.GetUserID());
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int orderId = (int)reader["OrderID"];
                            string status = reader["OrderStatus"].ToString();
                            string seenKey = $"notif_seen_{orderId}_{status}";

                            if (Session[seenKey] == null)
                            {
                                Session[seenKey] = true;

                                switch (status)
                                {
                                    case "Confirmed":
                                        BuyerNotificationType = "confirmed";
                                        BuyerNotificationMessage = $"Your order #{orderId} has been confirmed! 🎉";
                                        break;
                                    case "Shipped":
                                        BuyerNotificationType = "shipped";
                                        BuyerNotificationMessage = $"Your order #{orderId} is on its way! 🚚";
                                        break;
                                    case "Delivered":
                                        BuyerNotificationType = "delivered";
                                        BuyerNotificationMessage = $"Your order #{orderId} has been delivered! 📦";
                                        break;
                                }
                            }
                        }
                    }
                }
            }
        }
        protected string GetOrderItems(object orderID)
        {
            StringBuilder sb = new StringBuilder();
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
            SELECT oi.OrderItemID, l.Title, oi.PriceAtPurchase,
                   o.OrderStatus,
                   (SELECT COUNT(*) FROM Reviews r WHERE r.OrderItemID = oi.OrderItemID
                    AND r.ReviewerID = @BID) AS HasReview
            FROM OrderItems oi
            JOIN Listings l ON oi.ListingID = l.ListingID
            JOIN Orders o   ON oi.OrderID   = o.OrderID
            WHERE oi.OrderID = @OID";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@OID", orderID);
                    cmd.Parameters.AddWithValue("@BID", NavHelper.GetUserID());
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string reviewBtn = "";
                            bool isDelivered = r["OrderStatus"].ToString() == "Delivered";
                            bool hasReview = Convert.ToInt32(r["HasReview"]) > 0;

                            if (isDelivered && !hasReview)
                                reviewBtn = $"<a href='ReviewOrder.aspx?orderItemID={r["OrderItemID"]}' style='background:#D4A853;color:#1A1A1A;padding:5px 14px;border-radius:7px;font-size:0.78rem;font-weight:600;text-decoration:none;white-space:nowrap'>⭐ Review</a>";
                            else if (hasReview)
                                reviewBtn = "<span style='color:#27AE60;font-size:0.78rem;white-space:nowrap'>✅ Reviewed</span>";

                            sb.Append($@"
                        <div class='oi-row'>
                            <span>{r["Title"]}</span>
                            <div style='display:flex;align-items:center;gap:12px'>
                                <span>R {Convert.ToDecimal(r["PriceAtPurchase"]):F2}</span>
                                {reviewBtn}
                            </div>
                        </div>");
                        }
                    }
                }
            }
            return sb.ToString();
        }
    }
}