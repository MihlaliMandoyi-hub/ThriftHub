using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Admin
{
    public partial class Reports : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Admin");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
            {
                txtDateFrom.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
                txtDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
                GenerateReport("overview");
                LoadHistory();
            }
        }

        // ─── GENERATE BUTTON ─────────────────────────────────────────────────────
        protected void BtnGenerate_Click(object sender, EventArgs e)
        {
            GenerateReport(ddlReportType.SelectedValue);
            LoadHistory();
        }

        // ─── MAIN GENERATE ───────────────────────────────────────────────────────
        private void GenerateReport(string type)
        {
            DateTime from = string.IsNullOrEmpty(txtDateFrom.Text)
                ? DateTime.Now.AddDays(-30) : Convert.ToDateTime(txtDateFrom.Text);
            DateTime to = string.IsNullOrEmpty(txtDateTo.Text)
                ? DateTime.Now.AddDays(1) : Convert.ToDateTime(txtDateTo.Text).AddDays(1);

            // Show period banner
            pnlPeriod.Visible = true;
            litPeriodLabel.Text = "📅 <strong>" + from.ToString("dd MMM yyyy")
                + " – " + to.AddDays(-1).ToString("dd MMM yyyy") + "</strong>"
                + " &nbsp;·&nbsp; " + ddlReportType.SelectedItem.Text;

            // Hide all report panels
            HideAllPanels();

            switch (type)
            {
                case "orders": ShowOrders(from, to); break;
                case "revenue": ShowRevenue(from, to); break;
                case "sellers": ShowSellers(from, to); break;
                case "listings": ShowListings(from, to); break;
                case "buyers": ShowBuyers(from, to); break;
                case "reviews": ShowReviews(from, to); break;
                default: ShowOverview(from, to); break;
            }

            // Save record to GeneratedReports table
            SaveReportRecord(type, from, to.AddDays(-1));
        }

        private void HideAllPanels()
        {
            pnlStats.Visible = false;
            pnlOrders.Visible = false;
            pnlRevenue.Visible = false;
            pnlSellers.Visible = false;
            pnlListings.Visible = false;
            pnlBuyers.Visible = false;
            pnlReviews.Visible = false;
        }

        // ─── OVERVIEW ────────────────────────────────────────────────────────────
        private void ShowOverview(DateTime from, DateTime to)
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                int orders = ScalarDate<int>(conn, "SELECT COUNT(*) FROM Orders WHERE OrderDate BETWEEN @F AND @T", from, to);
                decimal revenue = ScalarDate<decimal>(conn, "SELECT ISNULL(SUM(FinalAmount),0) FROM Orders WHERE OrderDate BETWEEN @F AND @T", from, to);
                int users = ScalarDate<int>(conn, "SELECT COUNT(*) FROM Users WHERE DateJoined BETWEEN @F AND @T", from, to);
                int listings = ScalarDate<int>(conn, "SELECT COUNT(*) FROM Listings WHERE DateListed BETWEEN @F AND @T", from, to);
                decimal rating = ScalarDate<decimal>(conn, "SELECT ISNULL(AVG(CAST(Rating AS DECIMAL)),0) FROM Reviews WHERE DatePosted BETWEEN @F AND @T", from, to);

                litStatOrders.Text = orders.ToString();
                litStatRevenue.Text = revenue.ToString("N2");
                litStatComm.Text = (revenue * 0.05m).ToString("N2");
                litStatUsers.Text = users.ToString();
                litStatListings.Text = listings.ToString();
                litStatRating.Text = rating > 0 ? rating.ToString("F1") + " / 5" : "—";
            }
            pnlStats.Visible = true;
            ShowOrders(from, to);
        }

        // ─── ORDERS ──────────────────────────────────────────────────────────────
        private void ShowOrders(DateTime from, DateTime to)
        {
            DataTable dt = GetTableDate(@"
                SELECT o.OrderID, u.FullName AS BuyerName,
                       o.OrderDate, o.OrderStatus,
                       o.PaymentMethod, o.FinalAmount
                FROM Orders o
                JOIN Users u ON o.BuyerID = u.UserID
                WHERE o.OrderDate BETWEEN @F AND @T
                ORDER BY o.OrderDate DESC", from, to);

            Session["rpt_orders"] = dt;
            litOrdersCount.Text = dt.Rows.Count + " records";
            gvOrders.DataSource = dt;
            gvOrders.DataBind();
            pnlOrders.Visible = true;
        }

        // ─── REVENUE ─────────────────────────────────────────────────────────────
        private void ShowRevenue(DateTime from, DateTime to)
        {
            DataTable dt = GetTableDate(@"
                SELECT CAST(OrderDate AS DATE) AS Day,
                       COUNT(*)            AS OrderCount,
                       SUM(FinalAmount)    AS Revenue,
                       SUM(FinalAmount)*0.05 AS Commission
                FROM Orders
                WHERE OrderDate BETWEEN @F AND @T
                GROUP BY CAST(OrderDate AS DATE)
                ORDER BY Day DESC", from, to);

            // Add % column for bar chart
            decimal maxRev = 0;
            foreach (DataRow r in dt.Rows)
            {
                decimal v = Convert.ToDecimal(r["Revenue"]);
                if (v > maxRev) maxRev = v;
            }
            dt.Columns.Add("Pct", typeof(int));
            foreach (DataRow r in dt.Rows)
                r["Pct"] = maxRev > 0 ? (int)((Convert.ToDecimal(r["Revenue"]) / maxRev) * 100) : 0;

            Session["rpt_revenue"] = dt;
            litRevenueCount.Text = dt.Rows.Count + " days";
            gvRevenue.DataSource = dt;
            gvRevenue.DataBind();
            pnlRevenue.Visible = true;
        }

        // ─── TOP SELLERS ─────────────────────────────────────────────────────────
        private void ShowSellers(DateTime from, DateTime to)
        {
            DataTable dt = GetTableDate(@"
                SELECT u.FullName, u.Email,
                       COUNT(DISTINCT l.ListingID)      AS TotalListings,
                       COUNT(DISTINCT oi.OrderItemID)   AS ItemsSold,
                       ISNULL(SUM(oi.PriceAtPurchase),0) AS TotalSales,
                       ISNULL(AVG(CAST(r.Rating AS DECIMAL)),0) AS AvgRating
                FROM Users u
                LEFT JOIN Listings l    ON l.SellerID  = u.UserID
                LEFT JOIN OrderItems oi ON oi.SellerID = u.UserID
                LEFT JOIN Orders o      ON oi.OrderID  = o.OrderID
                    AND o.OrderDate BETWEEN @F AND @T
                LEFT JOIN Reviews r     ON r.SellerID  = u.UserID
                WHERE u.Role = 'Seller'
                GROUP BY u.UserID, u.FullName, u.Email
                ORDER BY TotalSales DESC", from, to);

            Session["rpt_sellers"] = dt;
            litSellersCount.Text = dt.Rows.Count + " sellers";
            gvSellers.DataSource = dt;
            gvSellers.DataBind();
            pnlSellers.Visible = true;
        }

        // ─── LISTINGS ────────────────────────────────────────────────────────────
        private void ShowListings(DateTime from, DateTime to)
        {
            DataTable dt = GetTableDate(@"
                SELECT l.Title,
                       u.FullName                          AS Seller,
                       ISNULL(c.Name,'Uncategorised')      AS Category,
                       l.Condition, l.Status, l.DateListed, l.Price
                FROM Listings l
                JOIN  Users u      ON l.SellerID   = u.UserID
                LEFT JOIN Categories c ON l.CategoryID = c.CategoryID
                WHERE l.DateListed BETWEEN @F AND @T
                ORDER BY l.DateListed DESC", from, to);

            Session["rpt_listings"] = dt;
            litListingsCount.Text = dt.Rows.Count + " listings";
            gvListings.DataSource = dt;
            gvListings.DataBind();
            pnlListings.Visible = true;
        }

        // ─── BUYERS ──────────────────────────────────────────────────────────────
        private void ShowBuyers(DateTime from, DateTime to)
        {
            DataTable dt = GetTableDate(@"
                SELECT u.FullName, u.Email, u.DateJoined,
                       COUNT(DISTINCT o.OrderID)       AS TotalOrders,
                       ISNULL(SUM(o.FinalAmount), 0)   AS TotalSpent
                FROM Users u
                LEFT JOIN Orders o ON o.BuyerID = u.UserID
                    AND o.OrderDate BETWEEN @F AND @T
                WHERE u.Role = 'Buyer'
                GROUP BY u.UserID, u.FullName, u.Email, u.DateJoined
                ORDER BY TotalSpent DESC", from, to);

            Session["rpt_buyers"] = dt;
            litBuyersCount.Text = dt.Rows.Count + " buyers";
            gvBuyers.DataSource = dt;
            gvBuyers.DataBind();
            pnlBuyers.Visible = true;
        }

        // ─── REVIEWS ─────────────────────────────────────────────────────────────
        private void ShowReviews(DateTime from, DateTime to)
        {
            DataTable dt = GetTableDate(@"
                SELECT buyer.FullName  AS Buyer,
                       seller.FullName AS Seller,
                       l.Title         AS Item,
                       r.Rating,
                       ISNULL(r.Comment, '—') AS Comment,
                       r.DatePosted
                FROM Reviews r
                JOIN Users buyer   ON r.ReviewerID   = buyer.UserID
                JOIN Users seller  ON r.SellerID     = seller.UserID
                JOIN OrderItems oi ON r.OrderItemID  = oi.OrderItemID
                JOIN Listings l    ON oi.ListingID   = l.ListingID
                WHERE r.DatePosted BETWEEN @F AND @T
                ORDER BY r.DatePosted DESC", from, to);

            Session["rpt_reviews"] = dt;
            litReviewsCount.Text = dt.Rows.Count + " reviews";
            gvReviews.DataSource = dt;
            gvReviews.DataBind();
            pnlReviews.Visible = true;
        }

        // ─── REPORT HISTORY ──────────────────────────────────────────────────────
        private void LoadHistory()
        {
            DataTable dt = GetTable(@"
                SELECT r.ReportID, r.ReportType, r.DateFrom, r.DateTo,
                       u.FullName        AS GeneratedByName,
                       r.GeneratedAt,
                       r.TotalOrders,
                       r.TotalRevenue,
                       r.TotalCommission
                FROM GeneratedReports r
                JOIN Users u ON r.GeneratedBy = u.UserID
                ORDER BY r.GeneratedAt DESC");

            Session["rpt_history"] = dt;
            gvHistory.DataSource = dt;
            gvHistory.DataBind();
        }

        // ─── SAVE REPORT RECORD ──────────────────────────────────────────────────
        private void SaveReportRecord(string type, DateTime from, DateTime to)
        {
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    decimal revenue = ScalarDate<decimal>(conn, "SELECT ISNULL(SUM(FinalAmount),0) FROM Orders WHERE OrderDate BETWEEN @F AND @T", from, to.AddDays(1));
                    int orders = ScalarDate<int>(conn, "SELECT COUNT(*) FROM Orders WHERE OrderDate BETWEEN @F AND @T", from, to.AddDays(1));
                    int users = ScalarDate<int>(conn, "SELECT COUNT(*) FROM Users WHERE DateJoined BETWEEN @F AND @T", from, to.AddDays(1));
                    int listings = ScalarDate<int>(conn, "SELECT COUNT(*) FROM Listings WHERE DateListed BETWEEN @F AND @T", from, to.AddDays(1));
                    decimal rating = ScalarDate<decimal>(conn, "SELECT ISNULL(AVG(CAST(Rating AS DECIMAL)),0) FROM Reviews WHERE DatePosted BETWEEN @F AND @T", from, to.AddDays(1));

                    string sql = @"
                        INSERT INTO GeneratedReports
                            (ReportType, DateFrom, DateTo, GeneratedBy, GeneratedAt,
                             TotalOrders, TotalRevenue, TotalCommission, NewUsers, NewListings, AvgRating)
                        VALUES
                            (@Type, @From, @To, @By, GETDATE(),
                             @Orders, @Revenue, @Commission, @Users, @Listings, @Rating)";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Type", type);
                        cmd.Parameters.AddWithValue("@From", from);
                        cmd.Parameters.AddWithValue("@To", to);
                        cmd.Parameters.AddWithValue("@By", NavHelper.GetUserID());
                        cmd.Parameters.AddWithValue("@Orders", orders);
                        cmd.Parameters.AddWithValue("@Revenue", revenue);
                        cmd.Parameters.AddWithValue("@Commission", revenue * 0.05m);
                        cmd.Parameters.AddWithValue("@Users", users);
                        cmd.Parameters.AddWithValue("@Listings", listings);
                        cmd.Parameters.AddWithValue("@Rating", rating > 0 ? (object)rating : DBNull.Value);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SaveReport Error: " + ex.Message);
            }
        }

        // ─── PAGING EVENTS ───────────────────────────────────────────────────────
        protected void gvOrders_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvOrders.PageIndex = e.NewPageIndex;
            gvOrders.DataSource = Session["rpt_orders"] as DataTable;
            gvOrders.DataBind();
            pnlOrders.Visible = true;
        }
        protected void gvRevenue_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvRevenue.PageIndex = e.NewPageIndex;
            gvRevenue.DataSource = Session["rpt_revenue"] as DataTable;
            gvRevenue.DataBind();
            pnlRevenue.Visible = true;
        }
        protected void gvSellers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvSellers.PageIndex = e.NewPageIndex;
            gvSellers.DataSource = Session["rpt_sellers"] as DataTable;
            gvSellers.DataBind();
            pnlSellers.Visible = true;
        }
        protected void gvListings_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvListings.PageIndex = e.NewPageIndex;
            gvListings.DataSource = Session["rpt_listings"] as DataTable;
            gvListings.DataBind();
            pnlListings.Visible = true;
        }
        protected void gvBuyers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvBuyers.PageIndex = e.NewPageIndex;
            gvBuyers.DataSource = Session["rpt_buyers"] as DataTable;
            gvBuyers.DataBind();
            pnlBuyers.Visible = true;
        }
        protected void gvReviews_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvReviews.PageIndex = e.NewPageIndex;
            gvReviews.DataSource = Session["rpt_reviews"] as DataTable;
            gvReviews.DataBind();
            pnlReviews.Visible = true;
        }
        protected void gvHistory_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvHistory.PageIndex = e.NewPageIndex;
            gvHistory.DataSource = Session["rpt_history"] as DataTable;
            gvHistory.DataBind();
        }

        // ─── BADGE HELPERS (must be protected for GridView TemplateFields) ───────
        protected string StatusBadge(string status)
        {
            switch (status)
            {
                case "Delivered": return "<span class='badge b-green'>📦 Delivered</span>";
                case "Shipped": return "<span class='badge b-purple'>🚚 Shipped</span>";
                case "Confirmed": return "<span class='badge b-blue'>✅ Confirmed</span>";
                case "Cancelled": return "<span class='badge b-red'>❌ Cancelled</span>";
                default: return "<span class='badge b-orange'>⏳ Processing</span>";
            }
        }
        protected string ListingBadge(string status)
        {
            switch (status)
            {
                case "Approved": return "<span class='badge b-green'>✅ Approved</span>";
                case "Rejected": return "<span class='badge b-red'>❌ Rejected</span>";
                case "Sold": return "<span class='badge b-blue'>🛒 Sold</span>";
                default: return "<span class='badge b-orange'>⏳ Pending</span>";
            }
        }

        // ─── CSV EXPORT ──────────────────────────────────────────────────────────
        protected void BtnExportCSV_Click(object sender, EventArgs e)
        {
            DateTime from = string.IsNullOrEmpty(txtDateFrom.Text)
                ? DateTime.Now.AddDays(-30) : Convert.ToDateTime(txtDateFrom.Text);
            DateTime to = string.IsNullOrEmpty(txtDateTo.Text)
                ? DateTime.Now.AddDays(1) : Convert.ToDateTime(txtDateTo.Text).AddDays(1);

            string type = ddlReportType.SelectedValue;
            string filename = "ThriftHub_" + type + "_" + DateTime.Now.ToString("yyyyMMdd") + ".csv";

            DataTable dt;
            string[] headers;
            string[] cols;

            switch (type)
            {
                case "revenue":
                    headers = new[] { "Date", "Orders", "Revenue (R)", "Commission (R)" };
                    cols = new[] { "Day", "OrderCount", "Revenue", "Commission" };
                    dt = GetTableDate(@"
                        SELECT CAST(OrderDate AS DATE) AS Day, COUNT(*) AS OrderCount,
                               SUM(FinalAmount) AS Revenue, SUM(FinalAmount)*0.05 AS Commission
                        FROM Orders WHERE OrderDate BETWEEN @F AND @T
                        GROUP BY CAST(OrderDate AS DATE) ORDER BY Day DESC", from, to);
                    break;
                case "sellers":
                    headers = new[] { "Seller", "Email", "Listings", "Items Sold", "Total Sales (R)", "Avg Rating" };
                    cols = new[] { "FullName", "Email", "TotalListings", "ItemsSold", "TotalSales", "AvgRating" };
                    dt = GetTableDate(@"
                        SELECT u.FullName, u.Email,
                               COUNT(DISTINCT l.ListingID) AS TotalListings,
                               COUNT(DISTINCT oi.OrderItemID) AS ItemsSold,
                               ISNULL(SUM(oi.PriceAtPurchase),0) AS TotalSales,
                               ISNULL(AVG(CAST(r.Rating AS DECIMAL)),0) AS AvgRating
                        FROM Users u
                        LEFT JOIN Listings l ON l.SellerID=u.UserID
                        LEFT JOIN OrderItems oi ON oi.SellerID=u.UserID
                        LEFT JOIN Orders o ON oi.OrderID=o.OrderID AND o.OrderDate BETWEEN @F AND @T
                        LEFT JOIN Reviews r ON r.SellerID=u.UserID
                        WHERE u.Role='Seller'
                        GROUP BY u.UserID,u.FullName,u.Email ORDER BY TotalSales DESC", from, to);
                    break;
                case "reviews":
                    headers = new[] { "Buyer", "Seller", "Item", "Rating", "Comment", "Date" };
                    cols = new[] { "Buyer", "Seller", "Item", "Rating", "Comment", "DatePosted" };
                    dt = GetTableDate(@"
                        SELECT buyer.FullName AS Buyer, seller.FullName AS Seller,
                               l.Title AS Item, r.Rating, ISNULL(r.Comment,'') AS Comment, r.DatePosted
                        FROM Reviews r
                        JOIN Users buyer ON r.ReviewerID=buyer.UserID
                        JOIN Users seller ON r.SellerID=seller.UserID
                        JOIN OrderItems oi ON r.OrderItemID=oi.OrderItemID
                        JOIN Listings l ON oi.ListingID=l.ListingID
                        WHERE r.DatePosted BETWEEN @F AND @T ORDER BY r.DatePosted DESC", from, to);
                    break;
                case "buyers":
                    headers = new[] { "Name", "Email", "Member Since", "Orders", "Total Spent (R)" };
                    cols = new[] { "FullName", "Email", "DateJoined", "TotalOrders", "TotalSpent" };
                    dt = GetTableDate(@"
                        SELECT u.FullName, u.Email, u.DateJoined,
                               COUNT(DISTINCT o.OrderID) AS TotalOrders,
                               ISNULL(SUM(o.FinalAmount),0) AS TotalSpent
                        FROM Users u
                        LEFT JOIN Orders o ON o.BuyerID=u.UserID AND o.OrderDate BETWEEN @F AND @T
                        WHERE u.Role='Buyer'
                        GROUP BY u.UserID,u.FullName,u.Email,u.DateJoined ORDER BY TotalSpent DESC", from, to);
                    break;
                default:
                    headers = new[] { "Order ID", "Buyer", "Date", "Status", "Payment", "Amount (R)" };
                    cols = new[] { "OrderID", "BuyerName", "OrderDate", "OrderStatus", "PaymentMethod", "FinalAmount" };
                    dt = GetTableDate(@"
                        SELECT o.OrderID, u.FullName AS BuyerName, o.OrderDate,
                               o.OrderStatus, o.PaymentMethod, o.FinalAmount
                        FROM Orders o JOIN Users u ON o.BuyerID=u.UserID
                        WHERE o.OrderDate BETWEEN @F AND @T ORDER BY o.OrderDate DESC", from, to);
                    break;
            }

            var sb = new StringBuilder();
            sb.AppendLine(string.Join(",", headers));
            foreach (DataRow row in dt.Rows)
            {
                var vals = new string[cols.Length];
                for (int i = 0; i < cols.Length; i++)
                {
                    string v = row[cols[i]] == DBNull.Value ? "" : row[cols[i]].ToString();
                    vals[i] = "\"" + v.Replace("\"", "\"\"") + "\"";
                }
                sb.AppendLine(string.Join(",", vals));
            }

            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("Content-Disposition", "attachment; filename=" + filename);
            Response.Write(sb.ToString());
            Response.End();
        }

        // ─── HELPERS ─────────────────────────────────────────────────────────────

        // With date params
        private DataTable GetTableDate(string sql, DateTime from, DateTime to)
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@F", from);
                    cmd.Parameters.AddWithValue("@T", to);
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }

        // Without date params (for history query)
        private DataTable GetTable(string sql)
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }

        // Scalar with date params
        private T ScalarDate<T>(SqlConnection conn, string sql, DateTime from, DateTime to)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@F", from);
                cmd.Parameters.AddWithValue("@T", to);
                object result = cmd.ExecuteScalar();
                if (result == null || result == DBNull.Value) return default(T);
                return (T)Convert.ChangeType(result, typeof(T));
            }
        }
    }
}