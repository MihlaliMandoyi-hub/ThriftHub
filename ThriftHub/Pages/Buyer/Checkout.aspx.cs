using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace ThriftHub.Pages.Buyer
{
    public partial class Checkout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            NavHelper.RequireRole("Buyer");
            litName.Text = NavHelper.GetFullName();

            if (!IsPostBack)
            {
                PreFillAddress();
                LoadOrderSummary();
            }
        }

        private void PreFillAddress()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = "SELECT AddressLine1, City, Province, PostalCode FROM Users WHERE UserID=@ID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", NavHelper.GetUserID());
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            txtAddress.Text = r["AddressLine1"].ToString();
                            txtCity.Text = r["City"].ToString();
                            txtPostal.Text = r["PostalCode"].ToString();
                            ddlProvince.SelectedValue = r["Province"].ToString();
                        }
                    }
                }
            }
        }

        private void LoadOrderSummary()
        {
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT l.Title, l.Price
                    FROM Basket b
                    JOIN Listings l ON b.ListingID = l.ListingID
                    WHERE b.BuyerID=@BID AND l.Status='Approved'";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@BID", NavHelper.GetUserID());
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0) { Response.Redirect("Basket.aspx"); return; }

                    decimal subtotal = 0;
                    StringBuilder sb = new StringBuilder();
                    foreach (DataRow row in dt.Rows)
                    {
                        decimal price = Convert.ToDecimal(row["Price"]);
                        subtotal += price;
                        sb.Append($"<div class='order-item'><strong>{row["Title"]}</strong><span>R {price:F2}</span></div>");
                    }

                    litOrderItems.Text = sb.ToString();
                    litSubtotal.Text = subtotal.ToString("F2");

                    decimal discount = Session["VoucherDiscount"] != null
                        ? Convert.ToDecimal(Session["VoucherDiscount"]) : 0;
                    decimal total = subtotal - discount;
                    if (total < 0) total = 0;

                    litTotal.Text = total.ToString("F2");

                    if (discount > 0)
                    {
                        litDiscount.Text = discount.ToString("F2");
                        pnlDiscount.Visible = true;
                    }
                }
            }
        }

        protected void BtnPlaceOrder_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int buyerID = NavHelper.GetUserID();
            string address = $"{txtAddress.Text.Trim()}, {txtCity.Text.Trim()}, {ddlProvince.SelectedValue}, {txtPostal.Text.Trim()}";
            string notes = txtNotes.Text.Trim();
            decimal discount = Session["VoucherDiscount"] != null ? Convert.ToDecimal(Session["VoucherDiscount"]) : 0;
            int? voucherID = Session["VoucherID"] != null ? (int?)Convert.ToInt32(Session["VoucherID"]) : null;
            string voucherCode = Session["VoucherCode"]?.ToString();

            string payMethod = "Credit Card (Simulated)";
            if (rbEFT.Checked) payMethod = "EFT";
            if (rbPayFast.Checked) payMethod = "PayFast (Simulated)";
            if (rbOzow.Checked) payMethod = "Ozow (Simulated)";
            if (rbSnapScan.Checked) payMethod = "SnapScan (Simulated)";
            if (rbVoucher.Checked) payMethod = "Voucher";

            // ✅ Declare orderID here at method scope so redirect can use it
            int orderID = 0;

            try
            {
                using (SqlConnection conn = DBHelper.GetConnection())
                {
                    conn.Open();

                    string basketSql = @"
                        SELECT b.ListingID, l.Price, l.SellerID
                        FROM Basket b JOIN Listings l ON b.ListingID=l.ListingID
                        WHERE b.BuyerID=@BID AND l.Status='Approved'";

                    DataTable basketDt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(basketSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        new SqlDataAdapter(cmd).Fill(basketDt);
                    }

                    if (basketDt.Rows.Count == 0) { Response.Redirect("Basket.aspx"); return; }

                    decimal subtotal = 0;
                    foreach (DataRow row in basketDt.Rows)
                        subtotal += Convert.ToDecimal(row["Price"]);

                    decimal total = subtotal - discount;
                    if (total < 0) total = 0;
                    decimal commission = total * 0.05m;

                    string orderSql = @"
                        INSERT INTO Orders
                            (BuyerID, OrderDate, TotalAmount, DiscountAmount, CommissionAmount,
                             FinalAmount, PaymentMethod, PaymentStatus, VoucherID, VoucherCode,
                             OrderStatus, ShippingAddress, Notes)
                        VALUES
                            (@BuyerID, GETDATE(), @Total, @Discount, @Commission,
                             @Final, @PayMethod, 'Paid', @VoucherID, @VoucherCode,
                             'Processing', @Address, @Notes);
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(orderSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@BuyerID", buyerID);
                        cmd.Parameters.AddWithValue("@Total", subtotal);
                        cmd.Parameters.AddWithValue("@Discount", discount);
                        cmd.Parameters.AddWithValue("@Commission", commission);
                        cmd.Parameters.AddWithValue("@Final", total);
                        cmd.Parameters.AddWithValue("@PayMethod", payMethod);
                        cmd.Parameters.AddWithValue("@VoucherID", voucherID.HasValue ? (object)voucherID.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@VoucherCode", string.IsNullOrEmpty(voucherCode) ? (object)DBNull.Value : voucherCode);
                        cmd.Parameters.AddWithValue("@Address", address);
                        cmd.Parameters.AddWithValue("@Notes", string.IsNullOrEmpty(notes) ? (object)DBNull.Value : notes);
                        orderID = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    foreach (DataRow row in basketDt.Rows)
                    {
                        int listingID = Convert.ToInt32(row["ListingID"]);
                        int sellerID = Convert.ToInt32(row["SellerID"]);
                        decimal price = Convert.ToDecimal(row["Price"]);
                        decimal commFee = price * 0.05m;
                        decimal payout = price - commFee;

                        string itemSql = @"
                            INSERT INTO OrderItems (OrderID, ListingID, SellerID, PriceAtPurchase, CommissionFee, SellerPayout)
                            VALUES (@OrderID, @ListingID, @SellerID, @Price, @CommFee, @Payout)";
                        using (SqlCommand cmd = new SqlCommand(itemSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@OrderID", orderID);
                            cmd.Parameters.AddWithValue("@ListingID", listingID);
                            cmd.Parameters.AddWithValue("@SellerID", sellerID);
                            cmd.Parameters.AddWithValue("@Price", price);
                            cmd.Parameters.AddWithValue("@CommFee", commFee);
                            cmd.Parameters.AddWithValue("@Payout", payout);
                            cmd.ExecuteNonQuery();
                        }

                        string soldSql = "UPDATE Listings SET Status='Sold' WHERE ListingID=@ID";
                        using (SqlCommand cmd = new SqlCommand(soldSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@ID", listingID);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    string trackSql = @"
                        INSERT INTO DeliveryTracking (OrderID, Status, Notes, Timestamp)
                        VALUES (@OID, 'Order Received', 'Your order has been placed successfully.', GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(trackSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@OID", orderID);
                        cmd.ExecuteNonQuery();
                    }

                    string clearSql = "DELETE FROM Basket WHERE BuyerID=@BID";
                    using (SqlCommand cmd = new SqlCommand(clearSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@BID", buyerID);
                        cmd.ExecuteNonQuery();
                    }

                    if (voucherID.HasValue)
                    {
                        string vSql = "UPDATE Vouchers SET TimesUsed = TimesUsed + 1 WHERE VoucherID=@VID";
                        using (SqlCommand cmd = new SqlCommand(vSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@VID", voucherID.Value);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    Session.Remove("VoucherDiscount");
                    Session.Remove("VoucherID");
                    Session.Remove("VoucherCode");

                    string notifSql = @"INSERT INTO Notifications (UserID, Title, Message, IsRead, CreatedAt)
                        VALUES (@UID, 'Order Confirmed ✅', @Msg, 0, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(notifSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@UID", buyerID);
                        cmd.Parameters.AddWithValue("@Msg", $"Your order #{orderID} has been placed. Total: R{total:F2}");
                        cmd.ExecuteNonQuery();
                    }
                }

                // ✅ orderID is now accessible here
                Response.Redirect($"OrderTracking.aspx?orderID={orderID}&success=1");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Checkout Error: " + ex.Message);
                litMessage.Text = $"<div class='server-message error'>Something went wrong: {ex.Message}</div>";
            }
        }
    }
}