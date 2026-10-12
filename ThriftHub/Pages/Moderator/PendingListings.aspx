<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PendingListings.aspx.cs" Inherits="ThriftHub.Pages.Moderator.PendingListings" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Pending Listings – ThriftHub</title>
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
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .page-header p{color:var(--muted);font-size:0.9rem;margin-top:4px}
        .cards-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:20px}
        .listing-card{background:var(--white);border-radius:16px;border:1px solid var(--border);overflow:hidden;transition:box-shadow 0.2s}
        .listing-card:hover{box-shadow:0 4px 20px rgba(0,0,0,0.08)}
        .card-img{width:100%;height:180px;background:#F0EBE0;display:flex;align-items:center;justify-content:center;font-size:3rem;overflow:hidden}
        .card-img img{width:100%;height:180px;object-fit:cover}
        .card-body{padding:20px}
        .card-title{font-weight:600;font-size:1rem;color:var(--charcoal);margin-bottom:4px}
        .card-meta{font-size:0.82rem;color:var(--muted);margin-bottom:12px;line-height:1.6}
        .card-price{font-family:'Playfair Display',serif;font-size:1.3rem;color:var(--forest);margin-bottom:16px}
        .card-seller{background:#F8F5EF;border-radius:8px;padding:10px 14px;font-size:0.82rem;color:var(--muted);margin-bottom:16px}
        .card-seller strong{color:var(--charcoal)}
        .moderation-form{border-top:1px solid var(--border);padding-top:16px}
        .moderation-form label{font-size:0.78rem;font-weight:500;color:var(--charcoal);margin-bottom:6px;display:block}
        .mod-note{width:100%;padding:10px 14px;border:1.5px solid var(--border);border-radius:8px;font-family:'DM Sans',sans-serif;font-size:0.85rem;resize:none;height:72px;margin-bottom:12px;box-sizing:border-box}
        .mod-note:focus{outline:none;border-color:var(--forest)}
        .btn-group{display:flex;gap:10px}
        .btn-approve{flex:1;padding:11px;background:var(--success);color:var(--white);border:none;border-radius:9px;font-family:'DM Sans',sans-serif;font-weight:500;font-size:0.88rem;cursor:pointer;transition:background 0.2s}
        .btn-approve:hover{background:#219A52}
        .btn-reject{flex:1;padding:11px;background:var(--error);color:var(--white);border:none;border-radius:9px;font-family:'DM Sans',sans-serif;font-weight:500;font-size:0.88rem;cursor:pointer;transition:background 0.2s}
        .btn-reject:hover{background:#A93226}
        .empty-state{text-align:center;padding:80px 20px;color:var(--muted)}
        .empty-state .icon{font-size:4rem;margin-bottom:16px}
        .badge-count{background:#C85C3A;color:white;border-radius:50px;padding:2px 10px;font-size:0.78rem;margin-left:8px}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}
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
    <a href="PendingListings.aspx" class="nav-brand">Thrift<span>Hub</span></a>
    <div class="nav-links">
        <a href="PendingListings.aspx" class="active">
            Pending <asp:Literal ID="litCount" runat="server"></asp:Literal>
        </a>
        <a href="../Settings.aspx">⚙️ Settings</a>
    </div>
    <div class="nav-user">
        <span>🛡️ <asp:Literal ID="litName" runat="server"/></span>
        <a href="../../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<%-- ONE form wraps EVERYTHING --%>
<form id="mainForm" runat="server">

    <%-- Hidden fields MUST be inside form --%>
    <asp:HiddenField ID="hdnNote"      runat="server" />
    <asp:HiddenField ID="hdnListingID" runat="server" />

    <div class="page-wrap">

        <div class="page-header">
            <h1>Pending Listings</h1>
            <p>Review and approve or reject seller submissions</p>
        </div>

        <asp:Literal ID="litMessage" runat="server"></asp:Literal>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <div class="icon">🎉</div>
                <p>All caught up! No pending listings to review.</p>
            </div>
        </asp:Panel>

        <div class="cards-grid">
            <asp:Repeater ID="rptPending" runat="server">
                <ItemTemplate>
                    <div class="listing-card">

                        <div class="card-img">
                            <%# GetImage(Eval("ListingID")) %>
                        </div>

                        <div class="card-body">
                            <div class="card-title"><%# Eval("Title") %></div>
                            <div class="card-meta">
                                <%# Eval("Brand") %> &middot;
                                Size <%# Eval("Size") %> &middot;
                                <%# Eval("Condition") %><br/>
                                <%# Eval("Gender") %> &middot;
                                <%# Eval("CategoryName") %>
                            </div>
                            <div class="card-price">R <%# string.Format("{0:F2}", Eval("Price")) %></div>

                            <div class="card-seller">
                                <strong>Seller:</strong> <%# Eval("SellerName") %><br/>
                                <strong>Listed:</strong> <%# Convert.ToDateTime(Eval("DateListed")).ToString("dd MMM yyyy") %><br/>
                                <strong>Description:</strong>
                                <%# Eval("Description").ToString().Length > 120
                                    ? Eval("Description").ToString().Substring(0, 120) + "..."
                                    : Eval("Description") %>
                            </div>

                            <div class="moderation-form">
                                <label>Moderation Note (optional — shown to seller if rejected)</label>
                                <textarea
                                    class="mod-note"
                                    id='<%# "note_" + Eval("ListingID") %>'
                                    placeholder="Add a note for the seller..."></textarea>

                                <div class="btn-group">
                                    <asp:LinkButton
                                        runat="server"
                                        CommandName="Approve"
                                        CommandArgument='<%# Eval("ListingID") %>'
                                        CssClass="btn-approve"
                                        OnCommand="ModerateItem"
                                        OnClientClick='<%# "saveNote(" + Eval("ListingID") + "); return true;" %>'>
                                        &#x2705; Approve
                                    </asp:LinkButton>

                                    <asp:LinkButton
                                        runat="server"
                                        CommandName="Reject"
                                        CommandArgument='<%# Eval("ListingID") %>'
                                        CssClass="btn-reject"
                                        OnCommand="ModerateItem"
                                        OnClientClick='<%# "saveNote(" + Eval("ListingID") + "); return confirm(\"Reject this listing?\");" %>'>
                                        &#x274C; Reject
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

    </div>

</form>

<script type="text/javascript">
    function saveNote(listingID) {
        var textarea  = document.getElementById('note_' + listingID);
        var noteField = document.getElementById('<%= hdnNote.ClientID %>');
        var idField   = document.getElementById('<%= hdnListingID.ClientID %>');
        if (textarea  && noteField) noteField.value = textarea.value;
        if (idField)                idField.value   = listingID;
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
