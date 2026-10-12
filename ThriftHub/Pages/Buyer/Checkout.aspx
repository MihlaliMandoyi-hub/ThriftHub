<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Checkout.aspx.cs" Inherits="ThriftHub.Pages.Buyer.Checkout" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Checkout – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;--charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;--border:#DDD8CE;--error:#C0392B;--success:#27AE60}
        body{font-family:'DM Sans',sans-serif;background:var(--cream);min-height:100vh}
        nav{background:var(--forest);padding:0 40px;display:flex;align-items:center;justify-content:space-between;height:64px;position:sticky;top:0;z-index:100}
        .nav-brand{font-family:'Playfair Display',serif;font-size:1.5rem;color:var(--white);text-decoration:none}
        .nav-brand span{color:var(--gold)}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:1000px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:28px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .checkout-grid{display:grid;grid-template-columns:1fr 340px;gap:24px;align-items:start}
        .form-card{background:var(--white);border-radius:16px;border:1px solid var(--border);padding:28px;margin-bottom:20px}
        .section-heading{font-size:0.78rem;font-weight:600;text-transform:uppercase;letter-spacing:1px;color:var(--muted);margin-bottom:18px;padding-bottom:10px;border-bottom:1px solid var(--border)}
        .form-row{display:flex;gap:14px;margin-bottom:16px}
        .form-group{flex:1;display:flex;flex-direction:column;margin-bottom:16px}
        .form-row .form-group{margin-bottom:0}
        label{font-size:0.82rem;font-weight:500;color:var(--charcoal);margin-bottom:6px}
        input[type=text],input[type=email],select,textarea{width:100%;padding:11px 14px;border:1.5px solid var(--border);border-radius:9px;font-family:'DM Sans',sans-serif;font-size:0.9rem;color:var(--charcoal);appearance:none}
        input:focus,select:focus,textarea:focus{outline:none;border-color:var(--forest);box-shadow:0 0 0 3px rgba(44,74,62,0.08)}
        /* Payment methods */
        .payment-options{display:flex;flex-direction:column;gap:10px}
        .payment-option{border:2px solid var(--border);border-radius:12px;padding:14px 18px;cursor:pointer;transition:all 0.2s;display:flex;align-items:center;gap:14px}
        .payment-option:has(input:checked){border-color:var(--forest);background:#EFF5F3}
        .payment-option input[type=radio]{width:18px;height:18px;accent-color:var(--forest)}
        .payment-option .pm-icon{font-size:1.4rem}
        .payment-option .pm-label{font-weight:500;font-size:0.92rem;color:var(--charcoal)}
        .payment-option .pm-desc{font-size:0.78rem;color:var(--muted)}
        /* Payment panels */
        .payment-panel{display:none;margin-top:16px;padding:16px;background:#F8F5EF;border-radius:10px;font-size:0.88rem}
        .payment-panel.active{display:block}
        .payment-panel .eft-details{line-height:2;color:var(--charcoal)}
        .payment-panel .eft-details strong{color:var(--forest)}
        .fake-card{display:grid;gap:12px}
        .fake-card input{background:var(--white)}
        /* Summary */
        .summary-card{background:var(--white);border-radius:16px;border:1px solid var(--border);padding:24px;position:sticky;top:80px}
        .summary-title{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--charcoal);margin-bottom:20px}
        .order-items{margin-bottom:16px}
        .order-item{display:flex;justify-content:space-between;font-size:0.85rem;color:var(--muted);margin-bottom:8px}
        .order-item strong{color:var(--charcoal)}
        .summary-row{display:flex;justify-content:space-between;font-size:0.9rem;color:var(--muted);margin-bottom:8px}
        .summary-row.total{border-top:1px solid var(--border);padding-top:14px;margin-top:8px;font-size:1rem;color:var(--charcoal);font-weight:600}
        .summary-row.total .amount{font-family:'Playfair Display',serif;font-size:1.3rem;color:var(--forest)}
        .btn-place-order{width:100%;padding:15px;background:var(--forest);color:var(--white);border:none;border-radius:12px;font-family:'DM Sans',sans-serif;font-size:1rem;font-weight:500;cursor:pointer;margin-top:16px;transition:background 0.2s}
        .btn-place-order:hover{background:#1E3329}
        .field-error{color:var(--error);font-size:0.78rem;margin-top:4px}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}
        @media(max-width:768px){.checkout-grid{grid-template-columns:1fr}}
            /* ===== FOOTER ===== */
    footer {
        background: var(--forest);
        color: rgba(255,255,255,0.75);
        padding: 40px 0 0 0;
        margin-top: auto;
    }

    .footer-top {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 24px 32px 24px;
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 32px;
    }

    .footer-brand {
        font-family: 'Playfair Display', serif;
        font-size: 1.4rem;
        color: var(--white);
        margin-bottom: 8px;
    }

    .footer-brand span { color: var(--gold); }

    .footer-tagline {
        font-size: 0.83rem;
        color: rgba(255,255,255,0.55);
        line-height: 1.6;
    }

    .footer-heading {
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: var(--gold);
        margin-bottom: 12px;
    }

    .footer-links { list-style: none; padding: 0; }
    .footer-links li { margin-bottom: 6px; }
    .footer-links a {
        color: rgba(255,255,255,0.6);
        text-decoration: none;
        font-size: 0.85rem;
        transition: color 0.2s;
    }
    .footer-links a:hover { color: var(--white); }

    /* ===== BRAND TICKER ===== */
    .brand-ticker {
        background: var(--charcoal);
        padding: 10px 0;
        overflow: hidden;
        border-top: 1px solid rgba(255,255,255,0.05);
    }

    .ticker-track {
        display: flex;
        animation: tickerScroll 28s linear infinite;
        white-space: nowrap;
    }

    .ticker-track:hover { animation-play-state: paused; }

    .ticker-item {
        color: rgba(255,255,255,0.35);
        font-size: 0.72rem;
        font-weight: 700;
        letter-spacing: 2px;
        text-transform: uppercase;
        padding: 0 28px;
    }

    .ticker-dot { color: var(--gold); opacity: 0.6; }

    @keyframes tickerScroll {
        0%   { transform: translateX(0); }
        100% { transform: translateX(-50%); }
    }

    /* ===== FOOTER BOTTOM ===== */
    .footer-bottom {
        background: rgba(0,0,0,0.2);
        padding: 14px 24px;
        text-align: center;
        font-size: 0.8rem;
        color: rgba(255,255,255,0.45);
        border-top: 1px solid rgba(255,255,255,0.08);
    }

    .footer-bottom strong { color: rgba(255,255,255,0.7); }

    /* ===== SHARED UTILITIES ===== */
    .page-wrap { max-width: 1200px; margin: 0 auto; padding: 40px 24px; }

    .server-message { padding: 12px 16px; border-radius: 10px; font-size: 0.88rem; margin-bottom: 16px; }
    .server-message.success { background: #E9F7EF; color: var(--success); border: 1px solid #A9DFBF; }
    .server-message.error   { background: #FDECEA; color: var(--error);   border: 1px solid #F5C6C2; }
</style>
    </style>
</head>
<body>

<nav>
    <a href="~/Default.aspx" class="nav-brand">Thrift<span>Hub</span></a>
    <div class="nav-user">
        <span>👋 <asp:Literal ID="litName" runat="server"/></span>
         <a href="Catalogue.aspx" class="active">Catalogue</a>
 <a href="Basket.aspx">🛒 Basket <asp:Literal ID="litBasketCount" runat="server"></asp:Literal></a>
 <a href="Wishlist.aspx">❤️ Wishlist</a>
 <a href="OrderTracking.aspx">📦 My Orders</a>
 <a href="../Settings.aspx">⚙️ Settings</a>
    </div>
</nav>

<div class="page-wrap">
    <div class="page-header">
        <h1>Checkout</h1>
    </div>

    <form id="checkoutForm" runat="server">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>

        <div class="checkout-grid">
            <div>
                <!-- Shipping Address -->
                <div class="form-card">
                    <div class="section-heading">Delivery Address</div>
                    <div class="form-group">
                        <label>Street Address *</label>
                        <asp:TextBox ID="txtAddress" runat="server" placeholder="e.g. 12 Main Street, Apt 3"/>
                        <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ControlToValidate="txtAddress" ErrorMessage="Address is required." CssClass="field-error" Display="Dynamic"/>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>City *</label>
                            <asp:TextBox ID="txtCity" runat="server" placeholder="e.g. Cape Town"/>
                            <asp:RequiredFieldValidator ID="rfvCity" runat="server" ControlToValidate="txtCity" ErrorMessage="City required." CssClass="field-error" Display="Dynamic"/>
                        </div>
                        <div class="form-group">
                            <label>Province</label>
                            <asp:DropDownList ID="ddlProvince" runat="server">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem>Eastern Cape</asp:ListItem>
                                <asp:ListItem>Free State</asp:ListItem>
                                <asp:ListItem>Gauteng</asp:ListItem>
                                <asp:ListItem>KwaZulu-Natal</asp:ListItem>
                                <asp:ListItem>Limpopo</asp:ListItem>
                                <asp:ListItem>Mpumalanga</asp:ListItem>
                                <asp:ListItem>North West</asp:ListItem>
                                <asp:ListItem>Northern Cape</asp:ListItem>
                                <asp:ListItem>Western Cape</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-group">
                            <label>Postal Code</label>
                            <asp:TextBox ID="txtPostal" runat="server" placeholder="e.g. 8001"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Order Notes (optional)</label>
                        <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" placeholder="Any special instructions..." style="height:70px"/>
                    </div>
                </div>

                <!-- Payment Method -->
                <div class="form-card">
                    <div class="section-heading">Payment Method</div>
                    <div class="payment-options">

                        <label class="payment-option">
                            <asp:RadioButton ID="rbCard" runat="server" GroupName="Payment" Checked="true"/>
                            <span class="pm-icon">💳</span>
                            <div><div class="pm-label">Credit / Debit Card</div><div class="pm-desc">Simulated card payment</div></div>
                        </label>

                        <label class="payment-option">
                            <asp:RadioButton ID="rbEFT" runat="server" GroupName="Payment"/>
                            <span class="pm-icon">🏦</span>
                            <div><div class="pm-label">EFT (Bank Transfer)</div><div class="pm-desc">Pay directly from your bank</div></div>
                        </label>

                        <label class="payment-option">
                            <asp:RadioButton ID="rbPayFast" runat="server" GroupName="Payment"/>
                            <span class="pm-icon">⚡</span>
                            <div><div class="pm-label">PayFast</div><div class="pm-desc">Simulated instant payment</div></div>
                        </label>

                        <label class="payment-option">
                            <asp:RadioButton ID="rbOzow" runat="server" GroupName="Payment"/>
                            <span class="pm-icon">🔗</span>
                            <div><div class="pm-label">Ozow</div><div class="pm-desc">Simulated instant EFT</div></div>
                        </label>

                        <label class="payment-option">
                            <asp:RadioButton ID="rbSnapScan" runat="server" GroupName="Payment"/>
                            <span class="pm-icon">📱</span>
                            <div><div class="pm-label">SnapScan</div><div class="pm-desc">Scan to pay</div></div>
                        </label>

                        <label class="payment-option">
                            <asp:RadioButton ID="rbVoucher" runat="server" GroupName="Payment"/>
                            <span class="pm-icon">🎟️</span>
                            <div><div class="pm-label">Voucher Only</div><div class="pm-desc">Pay entirely with voucher</div></div>
                        </label>

                    </div>

                    <!-- Card panel -->
                    <div class="payment-options">

    <div class="payment-option" onclick="selectPayment('<%= rbCard.ClientID %>')">
        <asp:RadioButton ID="RadioButton1" runat="server" GroupName="Payment" Checked="true"/>
        <span class="pm-icon">💳</span>
        <div><div class="pm-label">Credit / Debit Card</div><div class="pm-desc">Simulated card payment</div></div>
    </div>

    <div class="payment-option" onclick="selectPayment('<%= rbEFT.ClientID %>')">
        <asp:RadioButton ID="RadioButton2" runat="server" GroupName="Payment"/>
        <span class="pm-icon">🏦</span>
        <div><div class="pm-label">EFT (Bank Transfer)</div><div class="pm-desc">Pay directly from your bank</div></div>
    </div>

    <div class="payment-option" onclick="selectPayment('<%= rbPayFast.ClientID %>')">
        <asp:RadioButton ID="RadioButton3" runat="server" GroupName="Payment"/>
        <span class="pm-icon">⚡</span>
        <div><div class="pm-label">PayFast</div><div class="pm-desc">Simulated instant payment</div></div>
    </div>

    <div class="payment-option" onclick="selectPayment('<%= rbOzow.ClientID %>')">
        <asp:RadioButton ID="RadioButton4" runat="server" GroupName="Payment"/>
        <span class="pm-icon">🔗</span>
        <div><div class="pm-label">Ozow</div><div class="pm-desc">Simulated instant EFT</div></div>
    </div>

    <div class="payment-option" onclick="selectPayment('<%= rbSnapScan.ClientID %>')">
        <asp:RadioButton ID="RadioButton5" runat="server" GroupName="Payment"/>
        <span class="pm-icon">📱</span>
        <div><div class="pm-label">SnapScan</div><div class="pm-desc">Scan to pay</div></div>
    </div>

    <div class="payment-option" onclick="selectPayment('<%= rbVoucher.ClientID %>')">
        <asp:RadioButton ID="RadioButton6" runat="server" GroupName="Payment"/>
        <span class="pm-icon">🎟️</span>
        <div><div class="pm-label">Voucher Only</div><div class="pm-desc">Pay entirely with voucher</div></div>
    </div>

</div>

            <!-- Order Summary -->
            <div class="summary-card">
                <div class="summary-title">Order Summary</div>
                <div class="order-items">
                    <asp:Literal ID="litOrderItems" runat="server"></asp:Literal>
                </div>
                <div class="summary-row">
                    <span>Subtotal</span>
                    <span>R <asp:Literal ID="litSubtotal" runat="server"/></span>
                </div>
                <asp:Panel ID="pnlDiscount" runat="server" Visible="false">
                    <div class="summary-row">
                        <span>Voucher Discount</span>
                        <span style="color:#27AE60">- R <asp:Literal ID="litDiscount" runat="server"/></span>
                    </div>
                </asp:Panel>
                <div class="summary-row total">
                    <span>Total</span>
                    <span class="amount">R <asp:Literal ID="litTotal" runat="server"/></span>
                </div>
                <asp:Button ID="btnPlaceOrder" runat="server" Text="Place Order →"
                    CssClass="btn-place-order" OnClick="BtnPlaceOrder_Click"/>
            </div>
        </div>
    </form>
</div>

<script>
    // Show correct payment panel
    var radios = document.querySelectorAll('input[type=radio][name*=Payment]');
    var panels = {
        '<%= rbCard.ClientID %>': 'panelCard',
        '<%= rbEFT.ClientID %>': 'panelEFT',
        '<%= rbPayFast.ClientID %>': 'panelPayFast',
        '<%= rbOzow.ClientID %>': 'panelOzow',
        '<%= rbSnapScan.ClientID %>': 'panelSnap',
        '<%= rbVoucher.ClientID %>': 'panelVoucher'
    };
    function showPanel() {
        Object.values(panels).forEach(function (id) { document.getElementById(id).classList.remove('active'); });
        for (var id in panels) {
            var el = document.getElementById(id);
            if (el && el.checked) { document.getElementById(panels[id]).classList.add('active'); break; }
        }
    }
    radios.forEach(function (r) { r.addEventListener('change', showPanel); });

    function formatCard(input) {
        var v = input.value.replace(/\D/g, '').substring(0, 16);
        input.value = v.replace(/(.{4})/g, '$1 ').trim();
    }
</script>
</body>
<%-- ===== FOOTER ===== --%>
<footer>
    <div class="footer-top">
        <div>
            <div class="footer-brand">Thrift<span>Hub</span></div>
            <p class="footer-tagline">
                Pre-Loved Fashion. New Possibilities.<br/>
                South Africa's trusted second-hand clothing marketplace.
            </p>
        </div>
        <div>
            <div class="footer-heading">Quick Links</div>
            <ul class="footer-links">
                <li><a href="Catalogue.aspx"               runat="server">Home</a></li>
                <li><a href="Basket.aspx" runat="server">Basket</a></li>
                <li><a href="ItemDetail.aspx"              runat="server">Create Account</a></li>
                <li><a href="../../Logout.aspx"                 runat="server">Logout</a></li>
            </ul>
        </div>
        <div>
            <div class="footer-heading">Contact</div>
            <ul class="footer-links">
                <li><a href="#">support@thrifthub.co.za</a></li>
                <li><a href="#">+27 21 000 0000</a></li>
                <li><a href="#">South Africa</a></li>
            </ul>
        </div>
    </div>

    <%-- Brand Ticker --%>
    <div class="brand-ticker">
        <div class="ticker-track">
            <span class="ticker-item">NIKE</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">ADIDAS</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">PUMA</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">H&amp;M</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">ZARA</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">LEVI'S</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">GUESS</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">TOMMY HILFIGER</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">CALVIN KLEIN</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">REEBOK</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">NEW BALANCE</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">FOREVER 21</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">REDBAT</span><span class="ticker-dot">✦</span>
            <%-- Duplicate for seamless loop --%>
            <span class="ticker-item">NIKE</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">ADIDAS</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">PUMA</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">H&amp;M</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">ZARA</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">LEVI'S</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">GUESS</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">TOMMY HILFIGER</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">CALVIN KLEIN</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">REEBOK</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">NEW BALANCE</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">FOREVER 21</span><span class="ticker-dot">✦</span>
            <span class="ticker-item">REDBAT</span><span class="ticker-dot">✦</span>
        </div>
    </div>

    <div class="footer-bottom">
        <strong>Group 6</strong> &nbsp;|&nbsp;
        ThriftHub &nbsp;|&nbsp;
        &copy; <%= DateTime.Now.Year %> ThriftHub. All rights reserved.
    </div>
</footer>

<%-- Bootstrap 5 JS --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
