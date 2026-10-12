<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Wishlist.aspx.cs" Inherits="ThriftHub.Pages.Buyer.Wishlist" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>My Wishlist – ThriftHub</title>
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
        .page-wrap{max-width:1200px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:32px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:2rem;color:var(--charcoal)}
        .page-header p{color:var(--muted);font-size:0.9rem;margin-top:4px}
        .items-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:20px}
        .item-card{background:var(--white);border-radius:16px;border:1px solid var(--border);overflow:hidden;transition:box-shadow 0.2s,transform 0.2s;position:relative}
        .item-card:hover{box-shadow:0 8px 30px rgba(0,0,0,0.1);transform:translateY(-3px)}
        .item-img{width:100%;height:220px;background:#F0EBE0;display:flex;align-items:center;justify-content:center;font-size:4rem;position:relative;overflow:hidden;cursor:pointer}
        .item-img img{width:100%;height:220px;object-fit:cover}
        .item-badge{position:absolute;top:12px;left:12px;background:var(--forest);color:var(--white);font-size:0.72rem;padding:4px 10px;border-radius:50px;font-weight:500}
        .item-body{padding:16px}
        .item-title{font-weight:600;font-size:0.95rem;color:var(--charcoal);margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .item-meta{font-size:0.8rem;color:var(--muted);margin-bottom:10px}
        .item-footer{display:flex;align-items:center;justify-content:space-between;margin-top:12px;gap:8px}
        .item-price{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--forest)}
        .btn-cart{background:var(--forest);color:var(--white);border:none;padding:8px 14px;border-radius:8px;font-size:0.82rem;cursor:pointer;font-family:'DM Sans',sans-serif;transition:background 0.2s}
        .btn-cart:hover{background:#1E3329}
        .btn-remove-wish{background:none;border:1.5px solid var(--error);color:var(--error);padding:7px 12px;border-radius:8px;font-size:0.82rem;cursor:pointer;font-family:'DM Sans',sans-serif;transition:all 0.2s;white-space:nowrap}
        .btn-remove-wish:hover{background:var(--error);color:var(--white)}
        .item-date{font-size:0.72rem;color:var(--muted);margin-top:8px}
        .empty-state{text-align:center;padding:80px 20px;color:var(--muted)}
        .empty-state .icon{font-size:4rem;margin-bottom:16px}
        .empty-state a{color:var(--forest);font-weight:500;text-decoration:none}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}
        .toast{position:fixed;bottom:24px;right:24px;background:var(--forest);color:var(--white);padding:14px 24px;border-radius:12px;font-size:0.9rem;box-shadow:0 4px 20px rgba(0,0,0,0.15);transform:translateY(100px);opacity:0;transition:all 0.3s;z-index:999}
        .toast.show{transform:translateY(0);opacity:1}
        /* Notification bell */
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
        .notif-item{padding:14px 20px;border-bottom:1px solid var(--border);display:flex;gap:12px;align-items:flex-start;transition:background 0.15s}
        .notif-item:last-child{border-bottom:none}
        .notif-item.unread{background:#F8FDF9}
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
<form id="mainForm" runat="server">

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
        <div class="notif-wrapper">
            <button class="notif-btn" onclick="toggleNotifDropdown(event)" title="Notifications">
                🔔<span class="notif-badge" id="notifBadge"></span>
            </button>
            <div class="notif-dropdown" id="notifDropdown">
                <div class="notif-header">
                    <h4>🔔 Notifications</h4>
                    <button class="notif-mark-read" onclick="markAllRead()">Mark all read</button>
                </div>
                <div class="notif-list" id="notifList">
                    <div class="notif-empty"><div class="icon">🔕</div><div>No notifications yet</div></div>
                </div>
            </div>
        </div>
        <a href="../../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="page-wrap">
    <div class="page-header">
        <h1>❤️ My Wishlist</h1>
        <p>Items you've saved — <asp:Literal ID="litCount" runat="server">0</asp:Literal> item(s)</p>
    </div>

    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <div class="icon">💔</div>
                <p style="margin-bottom:16px">Your wishlist is empty.</p>
                <a href="Catalogue.aspx">Browse the Catalogue →</a>
            </div>
        </asp:Panel>

        <div class="items-grid">
            <asp:Repeater ID="rptWishlist" runat="server" OnItemCommand="rptWishlist_ItemCommand">
                <ItemTemplate>
                    <div class="item-card">
                        <div class="item-img" onclick='window.location="ItemDetail.aspx?id=<%# Eval("ListingID") %>"'>
                            <%# GetItemImage(Eval("ListingID")) %>
                            <span class="item-badge"><%# Eval("Condition") %></span>
                        </div>
                        <div class="item-body">
                            <div class="item-title"><%# Eval("Title") %></div>
                            <div class="item-meta"><%# Eval("Brand") %> · Size <%# Eval("Size") %> · <%# Eval("CategoryName") %></div>
                            <div class="item-footer">
                                <div class="item-price">R <%# string.Format("{0:F2}", Eval("Price")) %></div>
                                <asp:LinkButton runat="server" CommandName="AddToBasket"
                                    CommandArgument='<%# Eval("ListingID") %>'
                                    CssClass="btn-cart">🛒 Add</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="RemoveWishlist"
                                    CommandArgument='<%# Eval("ListingID") %>'
                                    CssClass="btn-remove-wish"
                                    OnClientClick="return confirm('Remove from wishlist?')">🗑️</asp:LinkButton>
                            </div>
                            <div class="item-date">Saved <%# Convert.ToDateTime(Eval("DateAdded")).ToString("dd MMM yyyy") %></div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

</div>

<div class="toast" id="toastBox"></div>

<script type="text/javascript">
    function showToast(msg) {
        var t = document.getElementById('toastBox');
        t.textContent = msg; t.classList.add('show');
        setTimeout(function(){ t.classList.remove('show'); }, 3000);
    }
    <% if (!string.IsNullOrEmpty(ToastMessage)) { %>
        window.addEventListener('load', function(){ showToast('<%= ToastMessage %>'); });
    <% } %>

    var NOTIF_KEY = 'thrifthub_buyer_notifications';
    function loadNotifications() { try { return JSON.parse(sessionStorage.getItem(NOTIF_KEY)) || []; } catch (e) { return []; } }
    function saveNotifications(l) { sessionStorage.setItem(NOTIF_KEY, JSON.stringify(l)); }
    function getNotifIcon(t) { return { confirmed: '✅', shipped: '🚚', delivered: '📦', info: 'ℹ️' }[t] || '🔔'; }
    function renderNotifications() {
        var list = loadNotifications(), unread = list.filter(function (n) { return !n.read; }).length;
        var badge = document.getElementById('notifBadge'), nl = document.getElementById('notifList');
        if (unread > 0) { badge.textContent = unread > 9 ? '9+' : unread; badge.classList.add('visible'); } else { badge.classList.remove('visible'); }
        if (list.length === 0) { nl.innerHTML = '<div class="notif-empty"><div class="icon">🔕</div><div>No notifications yet</div></div>'; return; }
        nl.innerHTML = list.map(function (n) {
            return '<div class="notif-item ' + (n.read ? '' : 'unread') + '" onclick="markOneRead(' + n.id + ')">'
                + '<div class="notif-icon">' + getNotifIcon(n.type) + '</div>'
                + '<div class="notif-content"><div class="notif-msg">' + n.message + '</div><div class="notif-time">' + n.time + '</div></div>'
                + (!n.read ? '<div class="notif-unread-dot"></div>' : '') + '</div>';
        }).join('');
    }
    function markOneRead(id) { var l = loadNotifications(); l = l.map(function (n) { if (n.id === id) n.read = true; return n; }); saveNotifications(l); renderNotifications(); }
    function markAllRead() { var l = loadNotifications(); l = l.map(function (n) { n.read = true; return n; }); saveNotifications(l); renderNotifications(); }
    function toggleNotifDropdown(e) { e.stopPropagation(); document.getElementById('notifDropdown').classList.toggle('open'); }
    document.addEventListener('click', function (e) { var d = document.getElementById('notifDropdown'); if (d && d.classList.contains('open') && !d.contains(e.target)) d.classList.remove('open'); });
    window.addEventListener('load', renderNotifications);
</script>

</form>
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


