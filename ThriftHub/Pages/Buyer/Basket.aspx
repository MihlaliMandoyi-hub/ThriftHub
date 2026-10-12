<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Basket.aspx.cs" Inherits="ThriftHub.Pages.Buyer.Basket" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Basket – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;--charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;--border:#DDD8CE;--error:#C0392B;--success:#27AE60}
        body{font-family:'DM Sans',sans-serif;background:var(--cream);min-height:100vh}
        nav{background:var(--forest);padding:0 40px;display:flex;align-items:center;justify-content:space-between;height:64px;position:sticky;top:0;z-index:100}
        .nav-brand{font-family:'Playfair Display',serif;font-size:1.5rem;color:var(--white);text-decoration:none}
        .nav-brand span{color:var(--gold)}
        .nav-links a{color:rgba(255,255,255,0.75);text-decoration:none;padding:8px 16px;border-radius:8px;font-size:0.88rem;transition:all 0.2s}
        .nav-links a:hover,.nav-links a.active{background:rgba(255,255,255,0.12);color:var(--white)}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:1000px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:28px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .basket-grid{display:grid;grid-template-columns:1fr 340px;gap:24px;align-items:start}
        .basket-item{background:var(--white);border-radius:14px;border:1px solid var(--border);padding:16px;display:flex;gap:16px;margin-bottom:12px;align-items:center;transition:box-shadow 0.2s}
        .basket-item:hover{box-shadow:0 4px 16px rgba(0,0,0,0.07)}
        .basket-item-img{width:80px;height:80px;border-radius:10px;object-fit:cover;background:#F0EBE0;display:flex;align-items:center;justify-content:center;font-size:1.8rem;flex-shrink:0;overflow:hidden}
        .basket-item-img img{width:80px;height:80px;object-fit:cover;border-radius:10px}
        .basket-item-info{flex:1}
        .basket-item-title{font-weight:600;font-size:0.95rem;color:var(--charcoal);margin-bottom:4px}
        .basket-item-meta{font-size:0.8rem;color:var(--muted)}
        .basket-item-price{font-family:'Playfair Display',serif;font-size:1.1rem;color:var(--forest);white-space:nowrap}
        .btn-remove{background:none;border:none;color:var(--error);cursor:pointer;font-size:0.82rem;padding:6px 10px;border-radius:6px;transition:background 0.2s}
        .btn-remove:hover{background:#FDECEA}
        .summary-card{background:var(--white);border-radius:16px;border:1px solid var(--border);padding:24px;position:sticky;top:80px}
        .summary-title{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--charcoal);margin-bottom:20px}
        .summary-row{display:flex;justify-content:space-between;font-size:0.9rem;color:var(--muted);margin-bottom:10px}
        .summary-row.total{border-top:1px solid var(--border);padding-top:14px;margin-top:14px;font-size:1rem;color:var(--charcoal);font-weight:600}
        .summary-row.total .amount{font-family:'Playfair Display',serif;font-size:1.3rem;color:var(--forest)}
        .voucher-section{margin:16px 0;padding:16px 0;border-top:1px solid var(--border);border-bottom:1px solid var(--border)}
        .voucher-section label{font-size:0.78rem;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;color:var(--muted);margin-bottom:8px;display:block}
        .voucher-row{display:flex;gap:8px}
        .voucher-row input{flex:1;padding:10px 14px;border:1.5px solid var(--border);border-radius:8px;font-family:'DM Sans',sans-serif;font-size:0.88rem}
        .voucher-row input:focus{outline:none;border-color:var(--forest)}
        .btn-voucher{padding:10px 16px;background:var(--forest);color:var(--white);border:none;border-radius:8px;font-family:'DM Sans',sans-serif;cursor:pointer;font-size:0.85rem;white-space:nowrap}
        .voucher-msg{font-size:0.8rem;margin-top:6px}
        .voucher-msg.ok{color:var(--success)}
        .voucher-msg.err{color:var(--error)}
        .btn-checkout{width:100%;padding:15px;background:var(--forest);color:var(--white);border:none;border-radius:12px;font-family:'DM Sans',sans-serif;font-size:1rem;font-weight:500;cursor:pointer;margin-top:16px;transition:background 0.2s,transform 0.15s}
        .btn-checkout:hover{background:#1E3329;transform:translateY(-1px)}
        .empty-state{text-align:center;padding:80px 20px;color:var(--muted)}
        .empty-state .icon{font-size:4rem;margin-bottom:16px}
        .empty-state a{color:var(--forest);font-weight:500;text-decoration:none}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}
        @media(max-width:768px){.basket-grid{grid-template-columns:1fr}}

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
        <a href="Catalogue.aspx" class="active">Catalogue</a>
        <a href="Basket.aspx">🛒 Basket <asp:Literal ID="litBasketCount" runat="server"></asp:Literal></a>
        <a href="Wishlist.aspx">❤️ Wishlist</a>
        <a href="OrderTracking.aspx">📦 My Orders</a>
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
        <h1>My Basket</h1>
    </div>

    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <div class="icon">🛒</div>
            <p style="margin-bottom:16px">Your basket is empty.</p>
            <a href="Catalogue.aspx">Browse the Catalogue →</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlBasket" runat="server">
        <form id="basketForm" runat="server">
            <div class="basket-grid">
                <!-- Items -->
                <div class="basket-items">
                    <asp:Repeater ID="rptBasket" runat="server" OnItemCommand="rptBasket_ItemCommand">
                        <ItemTemplate>
                            <div class="basket-item">
                                <div class="basket-item-img"><%# GetItemImage(Eval("ListingID")) %></div>
                                <div class="basket-item-info">
                                    <div class="basket-item-title"><%# Eval("Title") %></div>
                                    <div class="basket-item-meta"><%# Eval("Brand") %> · Size <%# Eval("Size") %> · <%# Eval("Condition") %></div>
                                </div>
                                <div class="basket-item-price">R <%# string.Format("{0:F2}", Eval("Price")) %></div>
                                <asp:LinkButton runat="server" CommandName="Remove" CommandArgument='<%# Eval("ListingID") %>' CssClass="btn-remove" OnClientClick="return confirm('Remove this item?')">✕</asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- Summary -->
                <div class="summary-card">
                    <div class="summary-title">Order Summary</div>
                    <div class="summary-row">
                        <span>Items (<asp:Literal ID="litItemCount" runat="server"/>)</span>
                        <span>R <asp:Literal ID="litSubtotal" runat="server"/></span>
                    </div>
                    <div class="voucher-section">
                        <label>Voucher Code</label>
                        <div class="voucher-row">
                            <asp:TextBox ID="txtVoucher" runat="server" placeholder="Enter code"/>
                            <asp:Button ID="btnApplyVoucher" runat="server" Text="Apply" CssClass="btn-voucher" OnClick="BtnApplyVoucher_Click" CausesValidation="false"/>
                        </div>
                        <asp:Literal ID="litVoucherMsg" runat="server"></asp:Literal>
                    </div>
                    <div class="summary-row" id="discountRow" runat="server" visible="false">
                        <span>Discount</span>
                        <span style="color:#27AE60">- R <asp:Literal ID="litDiscount" runat="server">0.00</asp:Literal></span>
                    </div>
                    <div class="summary-row total">
                        <span>Total</span>
                        <span class="amount">R <asp:Literal ID="litTotal" runat="server"/></span>
                    </div>
                    <asp:Button ID="btnCheckout" runat="server" Text="Proceed to Checkout →" CssClass="btn-checkout" OnClick="BtnCheckout_Click" CausesValidation="false"/>
                </div>
            </div>
        </form>
    </asp:Panel>
</div>

<script type="text/javascript">
    // ===================================================
    // NOTIFICATION SYSTEM — BUYER (shared across buyer pages)
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

    <%-- Server-triggered buyer notification (inject from code-behind) --%>
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
