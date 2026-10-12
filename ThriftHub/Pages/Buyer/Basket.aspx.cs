using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub.Pages.Buyer
{
    public partial class Basket : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Buyer");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
                LoadBasket();
        }

        private void LoadBasket()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT b.ListingID, l.Title, l.Brand, l.Size, l.Condition, l.Price
                    FROM Basket b
                    JOIN Listings l ON b.ListingID = l.ListingID
                    WHERE b.BuyerID = @BID AND l.Status = 'Approved'
                    ORDER BY b.DateAdded DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@BID", NavHelper.GetUserID());
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlBasket.Visible = false;
                        pnlEmpty.Visible = true;
                        return;
                    }

                    rptBasket.DataSource = dt;
                    rptBasket.DataBind();

                    decimal subtotal = 0;
                    foreach (DataRow row in dt.Rows)
                        subtotal += Convert.ToDecimal(row["Price"]);

                    decimal discount = Session["VoucherDiscount"] != null
                        ? Convert.ToDecimal(Session["VoucherDiscount"]) : 0;
                    decimal total = subtotal - discount;
                    if (total < 0) total = 0;

                    litItemCount.Text = dt.Rows.Count.ToString();
                    litSubtotal.Text = subtotal.ToString("F2");
                    litTotal.Text = total.ToString("F2");

                    if (discount > 0)
                    {
                        litDiscount.Text = discount.ToString("F2");
                        discountRow.Visible = true;
                        litVoucherMsg.Text = $"<div class='voucher-msg ok'>✅ Voucher applied: -R{discount:F2}</div>";
                    }

                    Session["BasketTotal"] = total;
                    Session["BasketSubtotal"] = subtotal;
                }
            }
        }

        // ✅ protected so Repeater can call it
        protected string GetItemImage(object listingID)
        {
            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();
                    string sql = "SELECT TOP 1 ImagePath FROM ListingImages WHERE ListingID=@ID AND IsPrimary=1";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", listingID);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            return $"<img src='{ResolveUrl(result.ToString())}' alt='item'/>";
                    }
                }
            }
            catch { }
            return "👗";
        }

        protected void rptBasket_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Remove") return;

            int listingID = Convert.ToInt32(e.CommandArgument);
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "DELETE FROM Basket WHERE BuyerID=@BID AND ListingID=@LID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@BID", NavHelper.GetUserID());
                    cmd.Parameters.AddWithValue("@LID", listingID);
                    cmd.ExecuteNonQuery();
                }
            }
            LoadBasket();
        }

        protected void BtnApplyVoucher_Click(object sender, EventArgs e)
        {
            string code = txtVoucher.Text.Trim().ToUpper();
            if (string.IsNullOrEmpty(code)) return;

            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT VoucherID, DiscountType, DiscountValue, MinOrderValue, MaxUses, TimesUsed, ExpiryDate
                    FROM Vouchers
                    WHERE Code=@Code AND IsActive=1";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Code", code);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            litVoucherMsg.Text = "<div class='voucher-msg err'>❌ Invalid voucher code.</div>";
                            return;
                        }

                        if (r["ExpiryDate"] != DBNull.Value && Convert.ToDateTime(r["ExpiryDate"]) < DateTime.Now)
                        {
                            litVoucherMsg.Text = "<div class='voucher-msg err'>❌ This voucher has expired.</div>";
                            return;
                        }

                        if (Convert.ToInt32(r["TimesUsed"]) >= Convert.ToInt32(r["MaxUses"]))
                        {
                            litVoucherMsg.Text = "<div class='voucher-msg err'>❌ This voucher has been fully used.</div>";
                            return;
                        }

                        decimal subtotal = Session["BasketSubtotal"] != null ? Convert.ToDecimal(Session["BasketSubtotal"]) : 0;
                        decimal minOrder = Convert.ToDecimal(r["MinOrderValue"]);

                        if (subtotal < minOrder)
                        {
                            litVoucherMsg.Text = $"<div class='voucher-msg err'>❌ Minimum order of R{minOrder:F2} required.</div>";
                            return;
                        }

                        decimal discount = 0;
                        string discountType = r["DiscountType"].ToString();
                        decimal discountVal = Convert.ToDecimal(r["DiscountValue"]);

                        discount = discountType == "Percentage" ? subtotal * (discountVal / 100) : discountVal;

                        Session["VoucherDiscount"] = discount;
                        Session["VoucherID"] = Convert.ToInt32(r["VoucherID"]);
                        Session["VoucherCode"] = code;
                    }
                }
            }
            LoadBasket();
        }
        public string BuyerNotificationMessage { get; set; } = "";
        public string BuyerNotificationType { get; set; } = "info";

        protected void NotifyBuyerOrderStatus(string orderStatus, int orderId)
        {
            switch (orderStatus)
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
        protected void BtnCheckout_Click(object sender, EventArgs e)
        {
            Response.Redirect("Checkout.aspx");
        }
    }
}