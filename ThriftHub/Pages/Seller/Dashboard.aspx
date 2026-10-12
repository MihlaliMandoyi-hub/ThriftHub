<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ThriftHub.Pages.Seller.Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Seller Dashboard – ThriftHub</title>
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
        .page-wrap{max-width:1100px;margin:0 auto;padding:40px 24px}
        .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:32px;flex-wrap:wrap;gap:16px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .page-header p{color:var(--muted);font-size:0.9rem;margin-top:4px}
        .btn-new{background:var(--forest);color:var(--white);padding:12px 24px;border-radius:10px;text-decoration:none;font-weight:500;font-size:0.9rem;transition:background 0.2s}
        .btn-new:hover{background:#1E3329}
        .stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px;margin-bottom:36px}
        .stat-card{background:var(--white);border-radius:16px;padding:22px;border:1px solid var(--border)}
        .stat-card .icon{font-size:1.6rem;margin-bottom:10px}
        .stat-card .value{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .stat-card .label{color:var(--muted);font-size:0.8rem;margin-top:4px}
        .stat-card.highlight{background:var(--forest)}
        .stat-card.highlight .value,.stat-card.highlight .label{color:var(--white)}
        .section-title{font-size:1rem;font-weight:600;color:var(--charcoal);margin-bottom:16px}
        .listings-table{background:var(--white);border-radius:16px;border:1px solid var(--border);overflow:hidden}
        table{width:100%;border-collapse:collapse}
        thead{background:#F8F5EF}
        th{padding:14px 20px;text-align:left;font-size:0.75rem;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px}
        td{padding:14px 20px;font-size:0.88rem;color:var(--charcoal);border-top:1px solid var(--border);vertical-align:middle}
        tr:hover td{background:#FAFAF8}
        .badge{display:inline-block;padding:4px 12px;border-radius:50px;font-size:0.75rem;font-weight:500}
        .badge-pending{background:#FEF3E2;color:#E67E22}
        .badge-approved{background:#E9F7EF;color:#27AE60}
        .badge-rejected{background:#FDECEA;color:#C0392B}
        .badge-sold{background:#EBF5FB;color:#2980B9}
        .btn-edit{background:var(--forest);color:var(--white);border:none;padding:6px 14px;border-radius:7px;font-size:0.8rem;cursor:pointer;font-family:'DM Sans',sans-serif;text-decoration:none;transition:background 0.2s}
        .btn-edit:hover{background:#1E3329}
        .btn-remove{background:none;border:1.5px solid var(--error);color:var(--error);padding:6px 14px;border-radius:7px;font-size:0.8rem;cursor:pointer;font-family:'DM Sans',sans-serif;transition:all 0.2s}
        .btn-remove:hover{background:var(--error);color:var(--white)}
        .empty-state{text-align:center;padding:60px 20px;color:var(--muted)}
        .empty-state .icon{font-size:3.5rem;margin-bottom:12px}
        .empty-state a{color:var(--forest);font-weight:500;text-decoration:none}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}

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
    <a href="Dashboard.aspx" class="nav-brand">Thrift<span>Hub</span></a>
    <div class="nav-links">
        <a href="Dashboard.aspx" class="active">Dashboard</a>
        <a href="ListItem.aspx">+ List Item</a>
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

<form id="mainForm" runat="server">
<div class="page-wrap">

    <div class="page-header">
        <div>
            <h1>Seller Dashboard</h1>
            <p>Manage your listings and track your sales</p>
        </div>
        <a href="ListItem.aspx" class="btn-new">+ List New Item</a>
    </div>

    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <%-- ===== STATS ===== --%>
    <div class="stats-grid">
        <div class="stat-card">
            <div class="icon">📦</div>
            <div class="value"><asp:Literal ID="litTotal" runat="server">0</asp:Literal></div>
            <div class="label">Total Listings</div>
        </div>
        <div class="stat-card">
            <div class="icon">⏳</div>
            <div class="value"><asp:Literal ID="litPending" runat="server">0</asp:Literal></div>
            <div class="label">Pending Approval</div>
        </div>
        <div class="stat-card">
            <div class="icon">✅</div>
            <div class="value"><asp:Literal ID="litApproved" runat="server">0</asp:Literal></div>
            <div class="label">Approved & Live</div>
        </div>
        <div class="stat-card">
            <div class="icon">🛒</div>
            <div class="value"><asp:Literal ID="litSold" runat="server">0</asp:Literal></div>
            <div class="label">Sold</div>
        </div>
        <div class="stat-card highlight">
            <div class="icon">💰</div>
            <div class="value">R <asp:Literal ID="litEarnings" runat="server">0.00</asp:Literal></div>
            <div class="label">Total Earnings</div>
        </div>
    </div>

    <%-- ===== LISTINGS TABLE ===== --%>
    <div class="section-title">My Listings</div>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <div class="icon">📭</div>
            <p style="margin-bottom:12px">You have no listings yet.</p>
            <a href="ListItem.aspx">List your first item →</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlTable" runat="server">
        <div class="listings-table">
            <table>
                <thead>
                    <tr>
                        <th>Item</th>
                        <th>Price</th>
                        <th>Category</th>
                        <th>Status</th>
                        <th>Date Listed</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptListings" runat="server" OnItemCommand="rptListings_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <strong><%# Eval("Title") %></strong><br/>
                                    <span style="color:#7A7A6E;font-size:0.78rem"><%# Eval("Brand") %> · Size <%# Eval("Size") %></span>
                                </td>
                                <td><strong>R <%# string.Format("{0:F2}", Eval("Price")) %></strong></td>
                                <td><%# Eval("CategoryName") %></td>
                                <td><%# GetStatusBadge(Eval("Status").ToString()) %></td>
                                <td><%# Convert.ToDateTime(Eval("DateListed")).ToString("dd MMM yyyy") %></td>
                                <td>
                                    <div style="display:flex;gap:8px">
                                        <asp:LinkButton runat="server" CommandName="Edit" CommandArgument='<%# Eval("ListingID") %>' CssClass="btn-edit">✏️ Edit</asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="Remove" CommandArgument='<%# Eval("ListingID") %>' CssClass="btn-remove" OnClientClick="return confirm('Remove this listing?');">🗑️ Remove</asp:LinkButton>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

</div>
</form>

<script type="text/javascript">
    // ===================================================
    // NOTIFICATION SYSTEM — SELLER
    // Notifies seller when someone buys their item.
    // ===================================================
    var NOTIF_KEY = 'thrifthub_seller_notifications';

    function loadNotifications() {
        try { return JSON.parse(sessionStorage.getItem(NOTIF_KEY)) || []; }
        catch(e) { return []; }
    }

    function saveNotifications(list) {
        sessionStorage.setItem(NOTIF_KEY, JSON.stringify(list));
    }

    function addSellerNotification(type, message) {
        var list = loadNotifications();
        list.unshift({ id: Date.now(), type: type, message: message, time: new Date().toLocaleString(), read: false });
        if (list.length > 20) list = list.slice(0, 20);
        saveNotifications(list);
        renderNotifications();
    }

    function getNotifIcon(type) {
        var icons = { sale: '🛒', approved: '✅', rejected: '❌', info: 'ℹ️' };
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
    // SERVER-TRIGGERED SELLER NOTIFICATIONS
    // In your code-behind, after a sale is recorded:
    //   addSellerNotification('sale', 'Someone bought your item "Levi Jeans" for R250! 🛒');
    //
    // After listing approved:
    //   addSellerNotification('approved', 'Your listing "Levi Jeans" was approved! ✅');
    // ===================================================
    <% if (!string.IsNullOrEmpty(SellerNotificationMessage)) { %>
        addSellerNotification('<%= SellerNotificationType %>', '<%= SellerNotificationMessage %>');
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
                <li><a href="Dashboard.aspx"               runat="server">Home</a></li>
                <li><a href="ListItem.aspx" runat="server">Items</a></li>
                <li><a href="Dashboard.aspx"              runat="server">My Listing</a></li>
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
