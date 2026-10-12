<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ThriftHub.Pages.Admin.Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Admin Dashboard – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;--charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;--border:#DDD8CE;--error:#C0392B;--success:#27AE60}
        body{font-family:'DM Sans',sans-serif;background:var(--cream);min-height:100vh}
        nav{background:var(--charcoal);padding:0 40px;display:flex;align-items:center;justify-content:space-between;height:64px;position:sticky;top:0;z-index:100}
        .nav-brand{font-family:'Playfair Display',serif;font-size:1.5rem;color:var(--white);text-decoration:none}
        .nav-brand span{color:var(--gold)}
        .nav-links{display:flex;gap:8px;align-items:center}
        .nav-links a{color:rgba(255,255,255,0.75);text-decoration:none;padding:8px 16px;border-radius:8px;font-size:0.88rem}
        .nav-links a:hover,.nav-links a.active{background:rgba(255,255,255,0.12);color:var(--white)}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:1200px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:32px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .page-header p{color:var(--muted);font-size:0.9rem;margin-top:4px}
        .stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px;margin-bottom:36px}
        .stat-card{background:var(--white);border-radius:16px;padding:22px;border:1px solid var(--border)}
        .stat-card .icon{font-size:1.8rem;margin-bottom:10px}
        .stat-card .value{font-family:'Playfair Display',serif;font-size:1.9rem;color:var(--charcoal)}
        .stat-card .label{color:var(--muted);font-size:0.8rem;margin-top:4px}
        .stat-card.green{background:var(--forest)}
        .stat-card.green .value,.stat-card.green .label{color:var(--white)}
        .stat-card.gold{background:var(--gold)}
        .stat-card.gold .value,.stat-card.gold .label{color:var(--charcoal)}
        .section-title{font-size:1rem;font-weight:600;color:var(--charcoal);margin-bottom:16px;margin-top:36px;display:flex;align-items:center;justify-content:space-between}
        .badge-count{background:#C85C3A;color:white;border-radius:50px;padding:2px 10px;font-size:0.78rem;margin-left:8px}
        .cards-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:20px;margin-bottom:36px}
        .listing-card{background:var(--white);border-radius:16px;border:1px solid var(--border);overflow:hidden}
        .card-img{width:100%;height:170px;background:#F0EBE0;display:flex;align-items:center;justify-content:center;font-size:3rem;overflow:hidden}
        .card-img img{width:100%;height:170px;object-fit:cover}
        .card-body{padding:18px}
        .card-title{font-weight:600;font-size:0.95rem;color:var(--charcoal);margin-bottom:4px}
        .card-meta{font-size:0.8rem;color:var(--muted);margin-bottom:10px;line-height:1.6}
        .card-price{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--forest);margin-bottom:12px}
        .card-seller{background:#F8F5EF;border-radius:8px;padding:10px 14px;font-size:0.8rem;color:var(--muted);margin-bottom:14px}
        .card-seller strong{color:var(--charcoal)}
        .mod-form{border-top:1px solid var(--border);padding-top:14px}
        .mod-note{width:100%;padding:9px 12px;border:1.5px solid var(--border);border-radius:8px;font-family:'DM Sans',sans-serif;font-size:0.83rem;resize:none;height:64px;margin-bottom:10px;box-sizing:border-box}
        .mod-note:focus{outline:none;border-color:var(--forest)}
        .btn-group{display:flex;gap:8px}
        .btn-approve{flex:1;padding:10px;background:var(--success);color:var(--white);border:none;border-radius:8px;font-family:'DM Sans',sans-serif;font-weight:500;font-size:0.85rem;cursor:pointer}
        .btn-approve:hover{background:#219A52}
        .btn-reject{flex:1;padding:10px;background:var(--error);color:var(--white);border:none;border-radius:8px;font-family:'DM Sans',sans-serif;font-weight:500;font-size:0.85rem;cursor:pointer}
        .btn-reject:hover{background:#A93226}
        .table-wrap{background:var(--white);border-radius:16px;border:1px solid var(--border);overflow:hidden;margin-bottom:28px}
        table{width:100%;border-collapse:collapse}
        thead{background:#F8F5EF}
        th{padding:13px 20px;text-align:left;font-size:0.76rem;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px}
        td{padding:13px 20px;font-size:0.87rem;color:var(--charcoal);border-top:1px solid var(--border)}
        tr:hover td{background:#FAFAF8}
        .badge{display:inline-block;padding:4px 12px;border-radius:50px;font-size:0.74rem;font-weight:500}
        .badge-buyer{background:#EBF5FB;color:#2980B9}
        .badge-seller{background:#E9F7EF;color:var(--success)}
        .badge-admin{background:#FDECEA;color:var(--error)}
        .badge-processing{background:#FEF3E2;color:#E67E22}
        .badge-delivered{background:#E9F7EF;color:var(--success)}
        .badge-shipped{background:#F4ECF7;color:#8E44AD}
        .empty-state{text-align:center;padding:50px 20px;color:var(--muted)}
        .empty-state .icon{font-size:3rem;margin-bottom:12px}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}

        /* ===== NOTIFICATION STYLES (admin uses charcoal nav, adjust border) ===== */
        .notif-wrapper{position:relative}
        .notif-btn{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);width:40px;height:40px;border-radius:10px;cursor:pointer;font-size:1.1rem;display:flex;align-items:center;justify-content:center;position:relative;transition:background 0.2s}
        .notif-btn:hover{background:rgba(255,255,255,0.2)}
        .notif-badge{position:absolute;top:-6px;right:-6px;background:#E74C3C;color:var(--white);font-size:0.65rem;font-weight:700;min-width:18px;height:18px;border-radius:50px;display:flex;align-items:center;justify-content:center;padding:0 4px;border:2px solid var(--charcoal);display:none}
        .notif-badge.visible{display:flex}
        .notif-dropdown{position:absolute;top:calc(100% + 10px);right:0;width:360px;background:var(--white);border-radius:16px;border:1px solid var(--border);box-shadow:0 8px 40px rgba(0,0,0,0.2);z-index:999;overflow:hidden;display:none;animation:dropIn 0.2s ease}
        .notif-dropdown.open{display:block}
        @keyframes dropIn{from{opacity:0;transform:translateY(-8px)}to{opacity:1;transform:translateY(0)}}
        .notif-header{padding:16px 20px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between}
        .notif-header h4{font-size:0.9rem;font-weight:600;color:var(--charcoal)}
        .notif-mark-read{font-size:0.75rem;color:var(--forest);cursor:pointer;background:none;border:none;font-family:'DM Sans',sans-serif;font-weight:500}
        .notif-mark-read:hover{text-decoration:underline}
        .notif-list{max-height:340px;overflow-y:auto}
        .notif-item{padding:14px 20px;border-bottom:1px solid var(--border);display:flex;gap:12px;align-items:flex-start;transition:background 0.15s;cursor:default}
        .notif-item:last-child{border-bottom:none}
        .notif-item.unread{background:#FFF8F8}
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
    
</head>
<body>

<nav>
    <a href="Dashboard.aspx" class="nav-brand">Thrift<span>Hub</span></a>
    <div class="nav-links">
        <a href="Dashboard.aspx" class="active">Dashboard</a>
        <a href="ManageOrders.aspx">📦 Orders</a>
        <a href="Reports.aspx">📊 Reports</a>
        <a href="UserManagement.aspx">👥 Users</a>
        <a href="../Settings.aspx">⚙️ Settings</a>
    </div>
    <div class="nav-user">
        <span>🛡️ <asp:Literal ID="litName" runat="server"/></span>

        <%-- ===== NOTIFICATION BELL ===== --%>
        <div class="notif-wrapper">
            <button class="notif-btn" onclick="toggleNotifDropdown(event)" title="Notifications" aria-label="Notifications">
                🔔
                <span class="notif-badge" id="notifBadge"></span>
            </button>
            <div class="notif-dropdown" id="notifDropdown">
                <div class="notif-header">
                    <h4>🔔 Admin Notifications</h4>
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
    <asp:HiddenField ID="hdnNote" runat="server"/>
    <asp:HiddenField ID="hdnListingID" runat="server"/>

    <div class="page-wrap">

        <div class="page-header">
            <h1>Admin Dashboard</h1>
            <p>Platform overview, pending approvals and recent activity</p>
        </div>

        <asp:Literal ID="litMessage" runat="server"/>

        <%-- STATS --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="icon">👥</div>
                <div class="value"><asp:Literal ID="litTotalUsers" runat="server">0</asp:Literal></div>
                <div class="label">Total Users</div>
            </div>
            <div class="stat-card">
                <div class="icon">👗</div>
                <div class="value"><asp:Literal ID="litTotalListings" runat="server">0</asp:Literal></div>
                <div class="label">Total Listings</div>
            </div>
            <div class="stat-card">
                <div class="icon">⏳</div>
                <div class="value"><asp:Literal ID="litPending" runat="server">0</asp:Literal></div>
                <div class="label">Pending Approval</div>
            </div>
            <div class="stat-card">
                <div class="icon">🛒</div>
                <div class="value"><asp:Literal ID="litTotalOrders" runat="server">0</asp:Literal></div>
                <div class="label">Total Orders</div>
            </div>
            <div class="stat-card green">
                <div class="icon">💰</div>
                <div class="value">R <asp:Literal ID="litRevenue" runat="server">0.00</asp:Literal></div>
                <div class="label">Total Revenue</div>
            </div>
            <div class="stat-card gold">
                <div class="icon">🏦</div>
                <div class="value">R <asp:Literal ID="litCommission" runat="server">0.00</asp:Literal></div>
                <div class="label">Commission (5%)</div>
            </div>
        </div>

        <%-- PENDING LISTINGS --%>
        <div class="section-title">
            <span>⏳ Pending Listings <asp:Literal ID="litPendingCount" runat="server"/></span>
        </div>

        <asp:Panel ID="pnlNoPending" runat="server" Visible="false">
            <div class="empty-state">
                <div class="icon">🎉</div>
                <p>All caught up! No listings waiting for approval.</p>
            </div>
        </asp:Panel>

        <div class="cards-grid">
            <asp:Repeater ID="rptPending" runat="server" OnItemCommand="ModerateItem">
                <ItemTemplate>
                    <div class="listing-card">
                        <div class="card-img"><%# GetImage(Eval("ListingID")) %></div>
                        <div class="card-body">
                            <div class="card-title"><%# Eval("Title") %></div>
                            <div class="card-meta"><%# Eval("Brand") %> · Size <%# Eval("Size") %> · <%# Eval("Condition") %><br/><%# Eval("Gender") %> · <%# Eval("CategoryName") %></div>
                            <div class="card-price">R <%# string.Format("{0:F2}", Eval("Price")) %></div>
                            <div class="card-seller">
                                <strong>Seller:</strong> <%# Eval("SellerName") %><br/>
                                <strong>Listed:</strong> <%# Convert.ToDateTime(Eval("DateListed")).ToString("dd MMM yyyy") %><br/>
                                <strong>Note:</strong> <%# Eval("Description").ToString().Length > 100 ? Eval("Description").ToString().Substring(0,100) + "..." : Eval("Description") %>
                            </div>
                            <div class="mod-form">
                                <textarea class="mod-note" id='<%# "note_" + Eval("ListingID") %>' placeholder="Optional note to seller..."></textarea>
                                <div class="btn-group">
                                    <asp:LinkButton runat="server" CommandName="Approve" CommandArgument='<%# Eval("ListingID") %>' CssClass="btn-approve" OnCommand="ModerateItem" OnClientClick='<%# "saveNote(" + Eval("ListingID") + "); return true;" %>'>✅ Approve</asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Reject" CommandArgument='<%# Eval("ListingID") %>' CssClass="btn-reject" OnCommand="ModerateItem" OnClientClick='<%# "saveNote(" + Eval("ListingID") + "); return confirm(\"Reject this listing?\");" %>'>❌ Reject</asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <%-- RECENT ORDERS --%>
        <div class="section-title">📦 Recent Orders</div>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Order #</th><th>Buyer</th><th>Amount</th><th>Payment</th><th>Status</th><th>Date</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptOrders" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><strong>#<%# Eval("OrderID") %></strong></td>
                                <td><%# Eval("BuyerName") %></td>
                                <td><strong>R <%# string.Format("{0:F2}", Eval("FinalAmount")) %></strong></td>
                                <td><%# Eval("PaymentMethod") %></td>
                                <td><%# GetOrderBadge(Eval("OrderStatus").ToString()) %></td>
                                <td><%# Convert.ToDateTime(Eval("OrderDate")).ToString("dd MMM yyyy") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <%-- RECENT USERS --%>
        <div class="section-title">👥 Recent Users</div>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Name</th><th>Email</th><th>Role</th><th>Joined</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptUsers" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><strong><%# Eval("FullName") %></strong></td>
                                <td><%# Eval("Email") %></td>
                                <td><%# GetRoleBadge(Eval("Role").ToString()) %></td>
                                <td><%# Convert.ToDateTime(Eval("DateJoined")).ToString("dd MMM yyyy") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

    </div>
</form>

<script type="text/javascript">
    function saveNote(listingID) {
        var textarea = document.getElementById('note_' + listingID);
        var noteField = document.getElementById('<%= hdnNote.ClientID %>');
        var idField = document.getElementById('<%= hdnListingID.ClientID %>');
        if (textarea) noteField.value = textarea.value;
        if (idField) idField.value = listingID;
    }

    // ===================================================
    // NOTIFICATION SYSTEM — ADMIN
    // Notifies admin when:
    //   1. A seller lists a new item (pending review)
    //   2. A buyer purchases an item
    // ===================================================
    var NOTIF_KEY = 'thrifthub_admin_notifications';

    function loadNotifications() {
        try { return JSON.parse(sessionStorage.getItem(NOTIF_KEY)) || []; }
        catch(e) { return []; }
    }

    function saveNotifications(list) {
        sessionStorage.setItem(NOTIF_KEY, JSON.stringify(list));
    }

    function addAdminNotification(type, message) {
        var list = loadNotifications();
        list.unshift({ id: Date.now(), type: type, message: message, time: new Date().toLocaleString(), read: false });
        if (list.length > 30) list = list.slice(0, 30);
        saveNotifications(list);
        renderNotifications();
    }

    function getNotifIcon(type) {
        var icons = { new_listing: '📋', purchase: '🛒', user: '👤', info: 'ℹ️' };
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
    // SERVER-TRIGGERED ADMIN NOTIFICATIONS
    // In your code-behind, call these at the right moments:
    //
    // New item listed by seller:
    //   addAdminNotification('new_listing', 'New listing pending review: "Levi Jeans" by John Doe 📋');
    //
    // Item purchased by buyer:
    //   addAdminNotification('purchase', 'Order #123 placed by Jane Smith for R250 🛒');
    //
    // New user registered:
    //   addAdminNotification('user', 'New user registered: Jane Smith (Buyer) 👤');
    // ===================================================
    <% if (!string.IsNullOrEmpty(AdminNotificationMessage)) { %>
        addAdminNotification('<%= AdminNotificationType %>', '<%= AdminNotificationMessage %>');
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
                <li><a href="Reports.aspx"              runat="server">Generate Report</a></li>
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