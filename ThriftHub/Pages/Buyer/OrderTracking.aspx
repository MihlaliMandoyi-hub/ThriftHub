<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrderTracking.aspx.cs" Inherits="ThriftHub.Pages.Buyer.OrderTracking" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>My Orders – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;--charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;--border:#DDD8CE;--error:#C0392B;--success:#27AE60}
        body{font-family:'DM Sans',sans-serif;background:var(--cream);min-height:100vh}
        nav{background:var(--forest);padding:0 40px;display:flex;align-items:center;justify-content:space-between;height:64px;position:sticky;top:0;z-index:100}
        .nav-brand{font-family:'Playfair Display',serif;font-size:1.5rem;color:var(--white);text-decoration:none}
        .nav-brand span{color:var(--gold)}
        .nav-links{display:flex;gap:8px;align-items:center}
        .nav-links a{color:rgba(255,255,255,0.75);text-decoration:none;padding:8px 16px;border-radius:8px;font-size:0.88rem;transition:all 0.2s}
        .nav-links a:hover,.nav-links a.active{background:rgba(255,255,255,0.12);color:var(--white)}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:900px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:28px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .success-banner{background:#E9F7EF;border:1px solid #A9DFBF;border-radius:14px;padding:20px 24px;margin-bottom:28px;display:flex;align-items:center;gap:16px}
        .success-banner .icon{font-size:2rem}
        .success-banner h3{color:var(--success);font-size:1rem;margin-bottom:4px}
        .success-banner p{color:var(--muted);font-size:0.88rem}
        .order-card{background:var(--white);border-radius:16px;border:1px solid var(--border);margin-bottom:20px;overflow:hidden}
        .order-header{padding:20px 24px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;border-bottom:1px solid var(--border);cursor:pointer;transition:background 0.2s}
        .order-header:hover{background:#FAFAF8}
        .order-id{font-weight:600;color:var(--charcoal);font-size:0.95rem}
        .order-date{color:var(--muted);font-size:0.82rem;margin-top:2px}
        .order-total{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--forest)}
        .badge{display:inline-block;padding:5px 14px;border-radius:50px;font-size:0.75rem;font-weight:500}
        .badge-processing{background:#FEF3E2;color:#E67E22}
        .badge-confirmed{background:#EBF5FB;color:#2980B9}
        .badge-shipped{background:#F4ECF7;color:#8E44AD}
        .badge-delivered{background:#E9F7EF;color:var(--success)}
        .badge-cancelled{background:#FDECEA;color:var(--error)}
        .order-body{padding:24px;display:none}
        .order-body.open{display:block}
        .timeline{position:relative;padding-left:28px;margin-bottom:24px}
        .timeline::before{content:'';position:absolute;left:8px;top:0;bottom:0;width:2px;background:var(--border)}
        .timeline-item{position:relative;margin-bottom:20px}
        .timeline-item::before{content:'';position:absolute;left:-24px;top:4px;width:12px;height:12px;border-radius:50%;background:var(--border);border:2px solid var(--white)}
        .timeline-item.done::before{background:var(--success)}
        .timeline-item.current::before{background:var(--forest)}
        .timeline-status{font-weight:500;font-size:0.9rem;color:var(--charcoal)}
        .timeline-time{font-size:0.78rem;color:var(--muted);margin-top:2px}
        .timeline-note{font-size:0.82rem;color:var(--muted);margin-top:4px}
        .order-items-list{border-top:1px solid var(--border);padding-top:16px;margin-top:16px}
        .order-items-list h4{font-size:0.78rem;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;color:var(--muted);margin-bottom:12px}
        .oi-row{display:flex;justify-content:space-between;font-size:0.88rem;color:var(--charcoal);padding:8px 0;border-bottom:1px solid var(--border)}
        .oi-row:last-child{border-bottom:none}
        .empty-state{text-align:center;padding:80px 20px;color:var(--muted)}
        .empty-state .icon{font-size:4rem;margin-bottom:16px}
        .empty-state a{color:var(--forest);font-weight:500;text-decoration:none}

        /* ===== NOTIFICATION STYLES ===== */
        .notif-wrapper{position:relative}
        .notif-btn{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);width:40px;height:40px;border-radius:10px;cursor:pointer;font-size:1.1rem;display:flex;align-items:center;justify-content:center;position:relative;transition:background 0.2s}
        .notif-btn:hover{background:rgba(255,255,255,0.2)}
        .notif-badge{position:absolute;top:-6px;right:-6px;background:#E74C3C;color:var(--white);font-size:0.65rem;font-weight:700;min-width:18px;height:18px;border-radius:50px;display:flex;align-items:center;justify-content:center;padding:0 4px;border:2px solid var(--forest);display:none}
        .notif-badge.visible{display:flex}
        .notif-dropdown{position:absolute;top:calc(100% + 10px);right:0;width:340px;background:var(--white);border-radius:16px;border:1px solid var(--border);box-shadow:0 8px 40px rgba(0,0,0,0.15);z-index:999;overflow:hidden;display:none;animation:dropIn 0.2s ease}
        .notif-dropdown.open{display:block}
        @keyframes dropIn{from{opacity:0;transform:translateY(-8px)}to{opacity:1;transform:translateY(0)}}
        .notif-header{padding:16px 20px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between}
        .notif-header h4{font-size:0.9rem;font-weight:600;color:var(--charcoal)}
        .notif-mark-read{font-size:0.75rem;color:var(--forest);cursor:pointer;background:none;border:none;font-family:'DM Sans',sans-serif;font-weight:500}
        .notif-mark-read:hover{text-decoration:underline}
        .notif-list{max-height:320px;overflow-y:auto}
        .notif-item{padding:14px 20px;border-bottom:1px solid var(--border);display:flex;gap:12px;align-items:flex-start;transition:background 0.15s;cursor:default}
        .notif-item:last-child{border-bottom:none}
        .notif-item.unread{background:#F8FDF9}
        .notif-item:hover{background:#F5F5F5}
        .notif-icon{font-size:1.4rem;flex-shrink:0;margin-top:2px}
        .notif-msg{font-size:0.83rem;color:var(--charcoal);line-height:1.4;font-weight:500}
        .notif-time{font-size:0.72rem;color:var(--muted);margin-top:3px}
        .notif-unread-dot{width:8px;height:8px;background:#E74C3C;border-radius:50%;flex-shrink:0;margin-top:6px}
        .notif-empty{padding:40px 20px;text-align:center;color:var(--muted);font-size:0.85rem}
        .notif-empty .icon{font-size:2rem;margin-bottom:8px}
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
    <a href="Catalogue.aspx" class="nav-brand">Thrift<span>Hub</span></a>
    <div class="nav-links">
        <a href="Catalogue.aspx">Catalogue</a>
        <a href="Basket.aspx">🛒 Basket</a>
        <a href="OrderTracking.aspx" class="active">📦 My Orders</a>
        <a href="../Settings.aspx">⚙️ Settings</a>
    </div>
    <div class="nav-user">
        <span>👋 <asp:Literal ID="litName" runat="server"/></span>

        <%-- ===== NOTIFICATION BELL ===== --%>
        <div class="notif-wrapper">
            <button class="notif-btn" onclick="toggleNotifDropdown(event)" title="Notifications" aria-label="Notifications">
                🔔
                <span class="notif-badge" id="notifBadge"></span>
            </button>
            <div class="notif-dropdown" id="notifDropdown">
                <div class="notif-header">
                    <h4>🔔 Notifications</h4>
                    <button class="notif-mark-read" onclick="markAllRead()">Mark all read</button>
                </div>
                <div class="notif-list" id="notifList">
                    <div class="notif-empty">
                        <div class="icon">🔕</div>
                        <div>No notifications yet</div>
                    </div>
                </div>
            </div>
        </div>
        <%-- ===== END NOTIFICATION BELL ===== --%>

        <a href="../../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="page-wrap">
    <div class="page-header">
        <h1>My Orders</h1>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="success-banner">
            <div class="icon">🎉</div>
            <div>
                <h3>Order placed successfully!</h3>
                <p>Your order has been confirmed. Track its progress below.</p>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <div class="icon">📦</div>
            <p style="margin-bottom:16px">You haven't placed any orders yet.</p>
            <a href="Catalogue.aspx">Start Shopping →</a>
        </div>
    </asp:Panel>

    <asp:Repeater ID="rptOrders" runat="server">
        <ItemTemplate>
            <div class="order-card">
                <div class="order-header" onclick="toggleOrder('order_<%# Eval("OrderID") %>')">
                    <div>
                        <div class="order-id">Order #<%# Eval("OrderID") %></div>
                        <div class="order-date"><%# Convert.ToDateTime(Eval("OrderDate")).ToString("dd MMM yyyy HH:mm") %> · <%# Eval("PaymentMethod") %></div>
                    </div>
                    <div style="display:flex;align-items:center;gap:12px">
                        <%# GetStatusBadge(Eval("OrderStatus").ToString()) %>
                        <div class="order-total">R <%# string.Format("{0:F2}", Eval("FinalAmount")) %></div>
                        <span style="color:#7A7A6E;font-size:0.8rem">▼</span>
                    </div>
                </div>
                <div class="order-body" id="order_<%# Eval("OrderID") %>">
                    <div class="timeline">
                        <%# GetTracking(Eval("OrderID")) %>
                    </div>
                    <div class="order-items-list">
                        <h4>Items in this order</h4>
                        <%# GetOrderItems(Eval("OrderID")) %>
                    </div>
                    <div style="margin-top:16px;font-size:0.82rem;color:#7A7A6E">
                        <strong>Delivery Address:</strong> <%# Eval("ShippingAddress") %>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<script type="text/javascript">
    // ===== ORDER ACCORDION =====
    function toggleOrder(id) {
        var el = document.getElementById(id);
        el.classList.toggle('open');
    }
    <% if (Request.QueryString["success"] == "1" && Request.QueryString["orderID"] != null) { %>
        window.onload = function() {
            var el = document.getElementById('order_<%= Request.QueryString["orderID"] %>');
            if (el) el.classList.add('open');
        }
    <% } %>

    // ===================================================
    // NOTIFICATION SYSTEM — BUYER
    // ===================================================
    var NOTIF_KEY = 'thrifthub_buyer_notifications';

    function loadNotifications() {
        try { return JSON.parse(sessionStorage.getItem(NOTIF_KEY)) || []; }
        catch(e) { return []; }
    }

    function saveNotifications(list) {
        sessionStorage.setItem(NOTIF_KEY, JSON.stringify(list));
    }

    function addBuyerNotification(type, message) {
        var list = loadNotifications();
        list.unshift({ id: Date.now(), type: type, message: message, time: new Date().toLocaleString(), read: false });
        if (list.length > 20) list = list.slice(0, 20);
        saveNotifications(list);
        renderNotifications();
    }

    function getNotifIcon(type) {
        var icons = { confirmed: '✅', shipped: '🚚', delivered: '📦', info: 'ℹ️' };
        return icons[type] || '🔔';
    }

    function renderNotifications() {
        var list = loadNotifications();
        var unread = list.filter(function(n){ return !n.read; }).length;
        var badge = document.getElementById('notifBadge');
        var notifList = document.getElementById('notifList');

        if (unread > 0) { badge.textContent = unread > 9 ? '9+' : unread; badge.classList.add('visible'); }
        else { badge.classList.remove('visible'); }

        if (list.length === 0) {
            notifList.innerHTML = '<div class="notif-empty"><div class="icon">🔕</div><div>No notifications yet</div></div>';
            return;
        }

        notifList.innerHTML = list.map(function(n) {
            return '<div class="notif-item ' + (n.read ? '' : 'unread') + '" onclick="markOneRead(' + n.id + ')">' +
                '<div class="notif-icon">' + getNotifIcon(n.type) + '</div>' +
                '<div class="notif-content">' +
                    '<div class="notif-msg">' + n.message + '</div>' +
                    '<div class="notif-time">' + n.time + '</div>' +
                '</div>' +
                (!n.read ? '<div class="notif-unread-dot"></div>' : '') +
            '</div>';
        }).join('');
    }

    function markOneRead(id) {
        var list = loadNotifications();
        list = list.map(function(n){ if(n.id === id) n.read = true; return n; });
        saveNotifications(list); renderNotifications();
    }

    function markAllRead() {
        var list = loadNotifications();
        list = list.map(function(n){ n.read = true; return n; });
        saveNotifications(list); renderNotifications();
    }

    function toggleNotifDropdown(e) {
        e.stopPropagation();
        document.getElementById('notifDropdown').classList.toggle('open');
    }

    document.addEventListener('click', function(e) {
        var dd = document.getElementById('notifDropdown');
        if (dd && dd.classList.contains('open') && !dd.contains(e.target)) dd.classList.remove('open');
    });

    // ===================================================
    // ORDER STATUS NOTIFICATIONS
    // Your C# code-behind should call addBuyerNotification()
    // whenever an order status changes. Inject it here:
    //
    // Confirmed:  addBuyerNotification('confirmed', 'Order #123 confirmed! 🎉');
    // Shipped:    addBuyerNotification('shipped',   'Order #123 is on its way! 🚚');
    // Delivered:  addBuyerNotification('delivered', 'Order #123 has been delivered! 📦');
    // ===================================================
    <% if (!string.IsNullOrEmpty(BuyerNotificationMessage)) { %>
        addBuyerNotification('<%= BuyerNotificationType %>', '<%= BuyerNotificationMessage %>');
    <% } %>

    window.addEventListener('load', renderNotifications);
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
<li><a href="Catalogue.aspx" runat="server">Browse Catalogue</a></li>
<li><a href="Wishlist.aspx"              runat="server">Wishlist</a></li>
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
