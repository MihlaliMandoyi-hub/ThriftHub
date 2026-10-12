<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserManagement.aspx.cs" Inherits="ThriftHub.Pages.Admin.UserManagement" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>User Management – ThriftHub Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;--charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;--border:#DDD8CE;--error:#C0392B;--success:#27AE60}
        body{font-family:'DM Sans',sans-serif;background:var(--cream);min-height:100vh}
        nav{background:var(--charcoal);padding:0 40px;display:flex;align-items:center;justify-content:space-between;height:64px;position:sticky;top:0;z-index:100}
        .nav-brand{font-family:'Playfair Display',serif;font-size:1.5rem;color:var(--white);text-decoration:none}
        .nav-brand span{color:var(--gold)}
        .nav-links{display:flex;gap:8px;align-items:center}
        .nav-links a{color:rgba(255,255,255,0.75);text-decoration:none;padding:8px 16px;border-radius:8px;font-size:0.88rem;transition:all 0.2s}
        .nav-links a:hover,.nav-links a.active{background:rgba(255,255,255,0.12);color:var(--white)}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:1200px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:28px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .page-header p{color:var(--muted);font-size:0.9rem;margin-top:4px}
        .filter-bar{background:var(--white);border-radius:14px;padding:16px 20px;border:1px solid var(--border);margin-bottom:24px;display:flex;gap:12px;flex-wrap:wrap;align-items:flex-end}
        .filter-group{display:flex;flex-direction:column;gap:5px;min-width:160px;flex:1}
        .filter-group label{font-size:0.72rem;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px}
        .filter-group input,.filter-group select{padding:9px 12px;border:1.5px solid var(--border);border-radius:8px;font-family:'DM Sans',sans-serif;font-size:0.87rem;color:var(--charcoal);background:var(--white)}
        .filter-group input:focus,.filter-group select:focus{outline:none;border-color:var(--forest)}
        .btn-filter{padding:9px 20px;background:var(--forest);color:var(--white);border:none;border-radius:8px;font-family:'DM Sans',sans-serif;font-weight:500;font-size:0.87rem;cursor:pointer}
        .btn-filter:hover{background:#1E3329}
        .btn-clear-filter{padding:9px 14px;background:transparent;color:var(--muted);border:1.5px solid var(--border);border-radius:8px;font-family:'DM Sans',sans-serif;font-size:0.87rem;cursor:pointer}
        .btn-clear-filter:hover{border-color:var(--error);color:var(--error)}
        .stats-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;margin-bottom:28px}
        .stat-pill{background:var(--white);border-radius:12px;padding:16px 20px;border:1px solid var(--border);display:flex;align-items:center;gap:12px}
        .stat-pill .icon{font-size:1.5rem}
        .stat-pill .val{font-family:'Playfair Display',serif;font-size:1.4rem;color:var(--charcoal)}
        .stat-pill .lbl{font-size:0.75rem;color:var(--muted)}
        .stat-pill.green{background:var(--forest)}
        .stat-pill.green .val,.stat-pill.green .lbl{color:var(--white)}
        .table-wrap{background:var(--white);border-radius:16px;border:1px solid var(--border);overflow:hidden}
        table{width:100%;border-collapse:collapse}
        thead{background:#F8F5EF}
        th{padding:13px 18px;text-align:left;font-size:0.75rem;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px;white-space:nowrap}
        td{padding:13px 18px;font-size:0.86rem;color:var(--charcoal);border-top:1px solid var(--border);vertical-align:middle}
        tr:hover td{background:#FAFAF8}
        .user-name{font-weight:600}
        .user-email{color:var(--muted);font-size:0.8rem}
        .badge{display:inline-block;padding:4px 12px;border-radius:50px;font-size:0.73rem;font-weight:500}
        .badge-buyer{background:#EBF5FB;color:#2980B9}
        .badge-seller{background:#E9F7EF;color:var(--success)}
        .badge-admin{background:#FDECEA;color:var(--error)}
        .status-active{background:#E9F7EF;color:var(--success);padding:4px 12px;border-radius:50px;font-size:0.73rem;font-weight:500}
        .status-suspended{background:#FEF3E2;color:#E67E22;padding:4px 12px;border-radius:50px;font-size:0.73rem;font-weight:500}
        .status-banned{background:#FDECEA;color:var(--error);padding:4px 12px;border-radius:50px;font-size:0.73rem;font-weight:500}
        .btn-action{padding:6px 14px;border-radius:7px;font-family:'DM Sans',sans-serif;font-size:0.78rem;font-weight:500;cursor:pointer;border:none;transition:all 0.2s;white-space:nowrap}
        .btn-suspend{background:#FEF3E2;color:#E67E22;border:1px solid #F5CBA7}
        .btn-suspend:hover{background:#E67E22;color:var(--white)}
        .btn-ban{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}
        .btn-ban:hover{background:var(--error);color:var(--white)}
        .btn-restore{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .btn-restore:hover{background:var(--success);color:var(--white)}
        .actions-cell{display:flex;gap:6px;flex-wrap:wrap}
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:500;align-items:center;justify-content:center}
        .modal-overlay.open{display:flex}
        .modal{background:var(--white);border-radius:20px;padding:32px;width:100%;max-width:440px;box-shadow:0 20px 60px rgba(0,0,0,0.2)}
        .modal h3{font-family:'Playfair Display',serif;font-size:1.3rem;color:var(--charcoal);margin-bottom:8px}
        .modal p{color:var(--muted);font-size:0.88rem;margin-bottom:20px;line-height:1.6}
        .modal label{font-size:0.78rem;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px;display:block;margin-bottom:6px}
        .modal textarea{width:100%;padding:10px 14px;border:1.5px solid var(--border);border-radius:10px;font-family:'DM Sans',sans-serif;font-size:0.87rem;resize:none;height:80px;margin-bottom:20px}
        .modal textarea:focus{outline:none;border-color:var(--forest)}
        .modal-btns{display:flex;gap:10px}
        .btn-modal-confirm{flex:1;padding:12px;border:none;border-radius:10px;font-family:'DM Sans',sans-serif;font-weight:500;font-size:0.9rem;cursor:pointer;color:var(--white)}
        .btn-modal-confirm.suspend{background:#E67E22}
        .btn-modal-confirm.ban{background:var(--error)}
        .btn-modal-confirm.restore{background:var(--success)}
        .btn-modal-cancel{flex:1;padding:12px;background:var(--cream);border:1.5px solid var(--border);border-radius:10px;font-family:'DM Sans',sans-serif;font-weight:500;font-size:0.9rem;cursor:pointer;color:var(--charcoal)}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}
        .results-info{font-size:0.85rem;color:var(--muted);margin-bottom:14px}
        .results-info strong{color:var(--charcoal)}
        .empty-state{text-align:center;padding:50px 20px;color:var(--muted)}
        .empty-state .icon{font-size:3rem;margin-bottom:12px}
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

    <%-- Hidden fields carry the modal values to the server --%>
    <asp:HiddenField ID="hdnTargetUserID" runat="server" Value="0"/>
    <asp:HiddenField ID="hdnAction"       runat="server" Value=""/>
    <asp:HiddenField ID="hdnReason"       runat="server" Value=""/>

    <%-- Hidden submit button — triggered by JS after setting hidden fields --%>
    <asp:Button ID="btnConfirmAction" runat="server"
        OnClick="BtnConfirmAction_Click"
        Style="position:absolute;left:-9999px;width:1px;height:1px;overflow:hidden"
        CausesValidation="false"/>

<nav>
    <a href="Dashboard.aspx" class="nav-brand">Thrift<span>Hub</span></a>
    <div class="nav-links">
        <a href="Dashboard.aspx">Dashboard</a>
        <a href="UserManagement.aspx" class="active">👥 Users</a>
        <a href="ManageOrders.aspx">📦 Orders</a>
        <a href="Reports.aspx">📊 Reports</a>
        <a href="../Settings.aspx">⚙️ Settings</a>
    </div>
    <div class="nav-user">
        <span>🛡️ <asp:Literal ID="litName" runat="server"/></span>
        <a href="../../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="page-wrap">

    <div class="page-header">
        <h1>👥 User Management</h1>
        <p>View, suspend, or ban users across the platform</p>
    </div>

    <asp:Literal ID="litMessage" runat="server"/>

    <div class="stats-row">
        <div class="stat-pill">
            <div class="icon">👥</div>
            <div><div class="val"><asp:Literal ID="litTotalUsers" runat="server">0</asp:Literal></div><div class="lbl">Total Users</div></div>
        </div>
        <div class="stat-pill">
            <div class="icon">🛍️</div>
            <div><div class="val"><asp:Literal ID="litTotalBuyers" runat="server">0</asp:Literal></div><div class="lbl">Buyers</div></div>
        </div>
        <div class="stat-pill">
            <div class="icon">🏪</div>
            <div><div class="val"><asp:Literal ID="litTotalSellers" runat="server">0</asp:Literal></div><div class="lbl">Sellers</div></div>
        </div>
        <div class="stat-pill green">
            <div class="icon">✅</div>
            <div><div class="val"><asp:Literal ID="litActiveUsers" runat="server">0</asp:Literal></div><div class="lbl">Active</div></div>
        </div>
        <div class="stat-pill">
            <div class="icon">🚫</div>
            <div><div class="val"><asp:Literal ID="litBannedUsers" runat="server">0</asp:Literal></div><div class="lbl">Banned / Suspended</div></div>
        </div>
    </div>

    <div class="filter-bar">
        <div class="filter-group" style="flex:2;min-width:180px">
            <label>Search</label>
            <asp:TextBox ID="txtSearch" runat="server" placeholder="Name or email..."/>
        </div>
        <div class="filter-group">
            <label>Role</label>
            <asp:DropDownList ID="ddlRole" runat="server">
                <asp:ListItem Value="">All Roles</asp:ListItem>
                <asp:ListItem Value="Buyer">Buyer</asp:ListItem>
                <asp:ListItem Value="Seller">Seller</asp:ListItem>
                <asp:ListItem Value="Admin">Admin</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="filter-group">
            <label>Status</label>
            <asp:DropDownList ID="ddlStatus" runat="server">
                <asp:ListItem Value="">All Statuses</asp:ListItem>
                <asp:ListItem Value="Active">Active</asp:ListItem>
                <asp:ListItem Value="Suspended">Suspended</asp:ListItem>
                <asp:ListItem Value="Banned">Banned</asp:ListItem>
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn-filter" OnClick="BtnSearch_Click" CausesValidation="false"/>
        <asp:Button ID="btnClear"  runat="server" Text="Clear"  CssClass="btn-clear-filter" OnClick="BtnClear_Click" CausesValidation="false"/>
    </div>

    <div class="results-info">Showing <strong><asp:Literal ID="litCount" runat="server">0</asp:Literal></strong> users</div>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="table-wrap">
            <div class="empty-state"><div class="icon">🔍</div><p>No users found.</p></div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlTable" runat="server">
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>User</th><th>Role</th><th>Status</th><th>Joined</th><th>Orders / Listings</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptUsers" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div class="user-name"><%# Eval("FullName") %></div>
                                    <div class="user-email"><%# Eval("Email") %></div>
                                </td>
                                <td><%# GetRoleBadge(Eval("Role").ToString()) %></td>
                                <td><%# GetStatusBadge(Eval("AccountStatus").ToString()) %></td>
                                <td><%# Convert.ToDateTime(Eval("DateJoined")).ToString("dd MMM yyyy") %></td>
                                <td style="color:var(--muted);font-size:0.82rem">
                                    <%# Eval("Role").ToString() == "Buyer"  ? Eval("OrderCount")   + " orders"   : "" %>
                                    <%# Eval("Role").ToString() == "Seller" ? Eval("ListingCount") + " listings" : "" %>
                                </td>
                                <td>
                                    <div class="actions-cell">
                                        <%# GetActionButtons(Eval("UserID"), Eval("FullName").ToString(), Eval("AccountStatus").ToString(), Eval("Role").ToString()) %>
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

<%-- MODAL --%>
<div class="modal-overlay" id="modalOverlay">
    <div class="modal">
        <h3 id="modalTitle">Confirm Action</h3>
        <p  id="modalDesc">Are you sure?</p>
        <label>Reason (optional)</label>
        <textarea id="modalReason" placeholder="Enter reason..."></textarea>
        <div class="modal-btns">
            <button type="button" class="btn-modal-cancel" onclick="closeModal()">Cancel</button>
            <button type="button" class="btn-modal-confirm" id="modalConfirmBtn" onclick="submitAction()">Confirm</button>
        </div>
    </div>
</div>

<script type="text/javascript">
    var _uid    = 0;
    var _action = '';

    function openModal(uid, name, action) {
        _uid    = uid;
        _action = action;
        var title = document.getElementById('modalTitle');
        var desc  = document.getElementById('modalDesc');
        var btn   = document.getElementById('modalConfirmBtn');
        document.getElementById('modalReason').value = '';

        if (action === 'suspend') {
            title.textContent = '⏸️ Suspend ' + name + '?';
            desc.textContent  = 'This user will be temporarily suspended and cannot log in until restored.';
            btn.textContent   = 'Suspend User';
            btn.className     = 'btn-modal-confirm suspend';
        } else if (action === 'ban') {
            title.textContent = '🚫 Ban ' + name + '?';
            desc.textContent  = 'This user will be permanently banned. This action is serious.';
            btn.textContent   = 'Ban User';
            btn.className     = 'btn-modal-confirm ban';
        } else {
            title.textContent = '✅ Restore ' + name + '?';
            desc.textContent  = 'This user will be restored to Active status.';
            btn.textContent   = 'Restore User';
            btn.className     = 'btn-modal-confirm restore';
        }
        document.getElementById('modalOverlay').classList.add('open');
    }

    function closeModal() {
        document.getElementById('modalOverlay').classList.remove('open');
    }

    function submitAction() {
        // Set hidden field values
        document.getElementById('<%= hdnTargetUserID.ClientID %>').value = _uid;
        document.getElementById('<%= hdnAction.ClientID %>').value       = _action;
        document.getElementById('<%= hdnReason.ClientID %>').value       = document.getElementById('modalReason').value;

        // Close modal first
        closeModal();

        // Click the hidden ASP.NET button to trigger postback
        document.getElementById('<%= btnConfirmAction.ClientID %>').click();
    }

    document.getElementById('modalOverlay').addEventListener('click', function (e) {
        if (e.target === this) closeModal();
    });
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
                <li><a href="Dashboard.aspx"               runat="server">Home</a></li>
                <li><a href="Reports.aspx"              runat="server">Report</a></li>
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
