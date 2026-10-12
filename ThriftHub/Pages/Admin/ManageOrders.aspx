<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageOrders.aspx.cs" Inherits="ThriftHub.Pages.Admin.ManageOrders" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Manage Orders – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;--charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;--border:#DDD8CE;--error:#C0392B;--success:#27AE60}
        body{font-family:'DM Sans',sans-serif;background:var(--cream);min-height:100vh}
        nav{background:var(--charcoal);padding:0 40px;display:flex;align-items:center;justify-content:space-between;height:64px;position:sticky;top:0;z-index:100}
        .nav-brand{font-family:'Playfair Display',serif;font-size:1.5rem;color:var(--white);text-decoration:none}
        .nav-brand span{color:var(--gold)}
        .nav-links{display:flex;gap:8px}
        .nav-links a{color:rgba(255,255,255,0.75);text-decoration:none;padding:8px 16px;border-radius:8px;font-size:0.88rem}
        .nav-links a:hover,.nav-links a.active{background:rgba(255,255,255,0.12);color:var(--white)}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:1100px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:28px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .page-header p{color:var(--muted);font-size:0.9rem;margin-top:4px}
        .order-card{background:var(--white);border-radius:16px;border:1px solid var(--border);margin-bottom:16px;overflow:hidden}
        .order-header{padding:20px 24px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;border-bottom:1px solid var(--border);cursor:pointer;transition:background 0.2s}
        .order-header:hover{background:#FAFAF8}
        .order-id{font-weight:600;color:var(--charcoal)}
        .order-meta{font-size:0.82rem;color:var(--muted);margin-top:2px}
        .order-total{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--forest)}
        .badge{display:inline-block;padding:5px 14px;border-radius:50px;font-size:0.75rem;font-weight:500}
        .badge-processing{background:#FEF3E2;color:#E67E22}
        .badge-confirmed{background:#EBF5FB;color:#2980B9}
        .badge-shipped{background:#F4ECF7;color:#8E44AD}
        .badge-delivered{background:#E9F7EF;color:var(--success)}
        .badge-cancelled{background:#FDECEA;color:var(--error)}
        .order-body{display:none;padding:24px;border-top:1px solid var(--border)}
        .order-body.open{display:block}
        .update-section{background:#F8F5EF;border-radius:12px;padding:20px;margin-bottom:20px}
        .update-section h3{font-size:0.88rem;font-weight:600;color:var(--charcoal);margin-bottom:14px;text-transform:uppercase;letter-spacing:0.5px}
        .update-row{display:flex;gap:12px;flex-wrap:wrap;align-items:flex-end}
        .form-group{display:flex;flex-direction:column;gap:6px;flex:1;min-width:160px}
        .form-group label{font-size:0.78rem;font-weight:500;color:var(--muted)}
        .form-group select,.form-group input{padding:10px 14px;border:1.5px solid var(--border);border-radius:9px;font-family:'DM Sans',sans-serif;font-size:0.88rem;color:var(--charcoal);background:var(--white)}
        .form-group select:focus,.form-group input:focus{outline:none;border-color:var(--forest)}
        .btn-update{padding:10px 24px;background:var(--forest);color:var(--white);border:none;border-radius:9px;font-family:'DM Sans',sans-serif;font-weight:500;cursor:pointer;white-space:nowrap;font-size:0.88rem}
        .btn-update:hover{background:#1E3329}
        .order-items-list h4{font-size:0.78rem;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;color:var(--muted);margin-bottom:10px}
        .oi-row{display:flex;justify-content:space-between;font-size:0.88rem;padding:8px 0;border-bottom:1px solid var(--border);color:var(--charcoal)}
        .oi-row:last-child{border-bottom:none}
        .timeline{position:relative;padding-left:28px;margin-top:16px}
        .timeline::before{content:'';position:absolute;left:8px;top:0;bottom:0;width:2px;background:var(--border)}
        .timeline-item{position:relative;margin-bottom:16px}
        .timeline-item::before{content:'';position:absolute;left:-24px;top:4px;width:12px;height:12px;border-radius:50%;background:var(--success);border:2px solid var(--white)}
        .timeline-status{font-weight:500;font-size:0.88rem;color:var(--charcoal)}
        .timeline-time{font-size:0.75rem;color:var(--muted)}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}
        .empty-state{text-align:center;padding:60px;color:var(--muted)}
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
    <a href="Dashboard.aspx" class="nav-brand">Thrift<span>Hub</span></a>
    <div class="nav-links">
        <a href="Dashboard.aspx">Dashboard</a>
        <a href="ManageOrders.aspx" class="active">📦 Orders</a>
        <a href="../Moderator/PendingListings.aspx">Pending Listings</a>
        <a href="../Settings.aspx">⚙️ Settings</a>
    </div>
    <div class="nav-user">
        <span>🛡️ <asp:Literal ID="litName" runat="server"/></span>
        <a href="../../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<form id="mainForm" runat="server">

    <asp:HiddenField ID="hdnOrderID"  runat="server"/>
    <asp:HiddenField ID="hdnStatus"   runat="server"/>
    <asp:HiddenField ID="hdnNote"     runat="server"/>
    <asp:HiddenField ID="hdnTracking" runat="server"/>

    <div class="page-wrap">

        <div class="page-header">
            <h1>Manage Orders</h1>
            <p>Update delivery status for buyer orders</p>
        </div>

        <asp:Literal ID="litMessage" runat="server"></asp:Literal>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <div style="font-size:3rem;margin-bottom:12px">📭</div>
                <p>No orders yet.</p>
            </div>
        </asp:Panel>

        <asp:Repeater ID="rptOrders" runat="server">
            <ItemTemplate>

                <div class="order-card">
                    <div class="order-header" onclick="toggleOrder('ord<%# Eval("OrderID") %>')">
                        <div>
                            <div class="order-id">Order #<%# Eval("OrderID") %></div>
                            <div class="order-meta">
                                👤 <%# Eval("BuyerName") %> &middot;
                                <%# Convert.ToDateTime(Eval("OrderDate")).ToString("dd MMM yyyy") %> &middot;
                                <%# Eval("PaymentMethod") %>
                            </div>
                        </div>
                        <div style="display:flex;align-items:center;gap:12px">
                            <%# GetStatusBadge(Eval("OrderStatus").ToString()) %>
                            <div class="order-total">R <%# string.Format("{0:F2}", Eval("FinalAmount")) %></div>
                            <span style="color:#7A7A6E">▼</span>
                        </div>
                    </div>

                    <div class="order-body" id="ord<%# Eval("OrderID") %>">

                        <div class="update-section">
                            <h3>Update Delivery Status</h3>
                            <div class="update-row">
                                <div class="form-group">
                                    <label>New Status</label>
                                    <select id='<%# "sel_" + Eval("OrderID") %>'>
                                        <option value="Processing">⏳ Processing</option>
                                        <option value="Confirmed">✅ Confirmed</option>
                                        <option value="Shipped">🚚 Shipped</option>
                                        <option value="Delivered">📦 Delivered</option>
                                        <option value="Cancelled">❌ Cancelled</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Tracking Number (optional)</label>
                                    <input type="text"
                                           id='<%# "trk_" + Eval("OrderID") %>'
                                           placeholder="e.g. SA123456789"/>
                                </div>
                                <div class="form-group">
                                    <label>Note to Buyer (optional)</label>
                                    <input type="text"
                                           id='<%# "nte_" + Eval("OrderID") %>'
                                           placeholder="e.g. Out for delivery today"/>
                                </div>
                                <asp:LinkButton
                                    runat="server"
                                    CommandName="UpdateStatus"
                                    CommandArgument='<%# Eval("OrderID") %>'
                                    CssClass="btn-update"
                                    OnCommand="UpdateOrderStatus"
                                    OnClientClick='<%# "return captureUpdate(" + Eval("OrderID") + ");" %>'>
                                    Update →
                                </asp:LinkButton>
                            </div>
                        </div>

                        <div class="order-items-list">
                            <h4>Items in this order</h4>
                            <%# GetOrderItems(Eval("OrderID")) %>
                        </div>

                        <div style="margin-top:20px">
                            <h4 style="font-size:0.78rem;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;color:#7A7A6E;margin-bottom:10px">
                                Tracking History
                            </h4>
                            <div class="timeline">
                                <%# GetTracking(Eval("OrderID")) %>
                            </div>
                        </div>

                        <div style="margin-top:16px;font-size:0.82rem;color:#7A7A6E;background:#F8F5EF;padding:12px 16px;border-radius:8px">
                            <strong>📍 Ship to:</strong> <%# Eval("ShippingAddress") %>
                        </div>

                    </div>
                </div>

            </ItemTemplate>
        </asp:Repeater>

    </div>
</form>

<script type="text/javascript">
    function toggleOrder(id) {
        var el = document.getElementById(id);
        if (el) el.classList.toggle('open');
    }

    function captureUpdate(orderID) {
        var sel = document.getElementById('sel_' + orderID);
        var trk = document.getElementById('trk_' + orderID);
        var nte = document.getElementById('nte_' + orderID);

        document.getElementById('<%= hdnOrderID.ClientID %>').value  = orderID;
        document.getElementById('<%= hdnStatus.ClientID %>').value   = sel ? sel.value : '';
        document.getElementById('<%= hdnTracking.ClientID %>').value = trk ? trk.value : '';
        document.getElementById('<%= hdnNote.ClientID %>').value     = nte ? nte.value : '';
        return true;
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
                <li><a href="~/Dashboard.aspx"               runat="server">Home</a></li>
                <li><a href="PendingList.aspx" runat="server">Pending List</a></li>
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