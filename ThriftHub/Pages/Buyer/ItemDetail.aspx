<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ItemDetail.aspx.cs" Inherits="ThriftHub.Pages.Buyer.ItemDetail" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Item Detail – ThriftHub</title>
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
        .nav-links a:hover{background:rgba(255,255,255,0.12);color:var(--white)}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:1100px;margin:0 auto;padding:40px 24px}
        .btn-back{display:inline-block;color:var(--forest);text-decoration:none;font-size:0.88rem;margin-bottom:24px}
        .btn-back:hover{text-decoration:underline}
        .detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:40px;align-items:start}
        .main-img{width:100%;height:420px;border-radius:16px;background:#F0EBE0;display:flex;align-items:center;justify-content:center;font-size:6rem;margin-bottom:12px;overflow:hidden}
        .main-img img{width:100%;height:420px;object-fit:cover;border-radius:16px}
        .thumb-row{display:flex;gap:8px;flex-wrap:wrap}
        .thumb{width:72px;height:72px;object-fit:cover;border-radius:8px;border:2px solid transparent;cursor:pointer;transition:border-color 0.2s}
        .thumb:hover,.thumb.active{border-color:var(--forest)}
        .item-category{font-size:0.78rem;color:var(--muted);text-transform:uppercase;letter-spacing:1px;margin-bottom:8px}
        .item-title{font-family:'Playfair Display',serif;font-size:2rem;color:var(--charcoal);line-height:1.2;margin-bottom:12px}
        .item-price{font-family:'Playfair Display',serif;font-size:2.2rem;color:var(--forest);margin-bottom:20px}
        .tags{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:20px}
        .tag{background:#F0EBE0;color:var(--charcoal);padding:6px 14px;border-radius:50px;font-size:0.82rem}
        .description{color:var(--muted);font-size:0.92rem;line-height:1.7;margin-bottom:24px;padding:16px;background:var(--white);border-radius:12px;border:1px solid var(--border)}
        .seller-box{background:var(--white);border-radius:12px;padding:16px;border:1px solid var(--border);margin-bottom:24px}
        .seller-box .label{font-size:0.75rem;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;color:var(--muted);margin-bottom:6px}
        .seller-box .name{font-weight:500;color:var(--charcoal)}
        .action-row{display:flex;gap:12px;margin-bottom:10px}
        .btn-add-cart{flex:1;padding:16px;background:var(--forest);color:var(--white);border:none;border-radius:12px;font-family:'DM Sans',sans-serif;font-size:1rem;font-weight:500;cursor:pointer;transition:background 0.2s,transform 0.15s}
        .btn-add-cart:hover{background:#1E3329;transform:translateY(-1px)}
        .btn-add-cart:disabled{background:#ccc;cursor:not-allowed;transform:none}
        .btn-wishlist-detail{padding:16px 20px;background:var(--white);color:var(--charcoal);border:1.5px solid var(--border);border-radius:12px;font-family:'DM Sans',sans-serif;font-size:1rem;cursor:pointer;transition:all 0.2s;white-space:nowrap}
        .btn-wishlist-detail:hover{border-color:#E74C3C;color:#E74C3C;background:#FFF0F0}
        .btn-wishlist-detail.wished{border-color:#E74C3C;color:#E74C3C;background:#FFF0F0}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:16px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}

        /* ===== SIMILAR ITEMS SECTION ===== */
        .similar-section{margin-top:56px;padding-top:40px;border-top:1px solid var(--border)}
        .similar-title{font-family:'Playfair Display',serif;font-size:1.4rem;color:var(--charcoal);margin-bottom:24px}
        .similar-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px}
        .similar-card{background:var(--white);border-radius:14px;border:1px solid var(--border);overflow:hidden;cursor:pointer;transition:box-shadow 0.2s,transform 0.2s;text-decoration:none;display:block}
        .similar-card:hover{box-shadow:0 6px 24px rgba(0,0,0,0.1);transform:translateY(-3px)}
        .similar-img{width:100%;height:180px;background:#F0EBE0;display:flex;align-items:center;justify-content:center;font-size:3rem;overflow:hidden}
        .similar-img img{width:100%;height:180px;object-fit:cover}
        .similar-body{padding:12px 14px}
        .similar-name{font-weight:600;font-size:0.88rem;color:var(--charcoal);margin-bottom:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .similar-meta{font-size:0.76rem;color:var(--muted);margin-bottom:6px}
        .similar-price{font-family:'Playfair Display',serif;font-size:1.1rem;color:var(--forest)}
        /* ================================= */

        .toast{position:fixed;bottom:24px;right:24px;background:var(--forest);color:var(--white);padding:14px 24px;border-radius:12px;font-size:0.9rem;box-shadow:0 4px 20px rgba(0,0,0,0.15);transform:translateY(100px);opacity:0;transition:all 0.3s;z-index:999}
        .toast.show{transform:translateY(0);opacity:1}
        @media(max-width:768px){.detail-grid{grid-template-columns:1fr}.action-row{flex-direction:column}.similar-grid{grid-template-columns:repeat(2,1fr)}}
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
        <a href="../../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="page-wrap">
    <a href="Catalogue.aspx" class="btn-back">← Back to Catalogue</a>

    <asp:Panel ID="pnlDetail" runat="server">
        <div class="detail-grid">

            <div class="images-col">
                <div class="main-img" id="mainImg">
                    <asp:Literal ID="litMainImage" runat="server">👗</asp:Literal>
                </div>
                <div class="thumb-row" id="thumbRow">
                    <asp:Literal ID="litThumbs" runat="server"></asp:Literal>
                </div>
            </div>

            <div class="info-col">
                <div class="item-category"><asp:Literal ID="litCategory" runat="server"/></div>
                <div class="item-title"><asp:Literal ID="litTitle" runat="server"/></div>
                <div class="item-price">R <asp:Literal ID="litPrice" runat="server"/></div>

                <div class="tags">
                    <span class="tag">📏 <asp:Literal ID="litSize" runat="server"/></span>
                    <span class="tag">✨ <asp:Literal ID="litCondition" runat="server"/></span>
                    <span class="tag">👤 <asp:Literal ID="litGender" runat="server"/></span>
                    <asp:Panel ID="pnlBrand" runat="server"><span class="tag">🏷️ <asp:Literal ID="litBrand" runat="server"/></span></asp:Panel>
                    <asp:Panel ID="pnlColour" runat="server"><span class="tag">🎨 <asp:Literal ID="litColour" runat="server"/></span></asp:Panel>
                </div>

                <div class="description"><asp:Literal ID="litDescription" runat="server"/></div>

                <div class="seller-box">
                    <div class="label">Sold by</div>
                    <div class="name">👤 <asp:Literal ID="litSeller" runat="server"/></div>
                </div>

                <asp:Literal ID="litMessage" runat="server"></asp:Literal>

                <div class="action-row">
                    <asp:Button ID="btnAddToCart" runat="server" Text="🛒 Add to Basket"
                        CssClass="btn-add-cart" OnClick="BtnAddToCart_Click"/>
                    <asp:Button ID="btnWishlist" runat="server"
                        CssClass="btn-wishlist-detail" OnClick="BtnWishlist_Click"/>
                </div>
            </div>

        </div>

        <%-- ===== SIMILAR ITEMS SECTION ===== --%>
        <asp:Panel ID="pnlSimilar" runat="server">
            <div class="similar-section">
                <div class="similar-title">✨ You might also like</div>
                <div class="similar-grid">
                    <asp:Repeater ID="rptSimilar" runat="server">
                        <ItemTemplate>
                            <a class="similar-card" href='ItemDetail.aspx?id=<%# Eval("ListingID") %>'>
                                <div class="similar-img">
                                    <%# GetSimilarImage(Eval("ImagePath")) %>
                                </div>
                                <div class="similar-body">
                                    <div class="similar-name"><%# Eval("Title") %></div>
                                    <div class="similar-meta"><%# Eval("Brand") %> · Size <%# Eval("Size") %> · <%# Eval("Condition") %></div>
                                    <div class="similar-price">R <%# string.Format("{0:F2}", Eval("Price")) %></div>
                                </div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </asp:Panel>
        <%-- ================================= --%>

    </asp:Panel>

    <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
        <div style="text-align:center;padding:80px 20px;color:#7A7A6E">
            <div style="font-size:4rem;margin-bottom:16px">😕</div>
            <p>Item not found or no longer available.</p>
            <a href="Catalogue.aspx" style="color:#2C4A3E;font-weight:500">← Back to Catalogue</a>
        </div>
    </asp:Panel>
</div>

<div class="toast" id="toastBox"></div>

<script>
    function switchImage(src) {
        var main = document.getElementById('mainImg');
        main.innerHTML = '<img src="' + src + '" alt="item"/>';
        document.querySelectorAll('.thumb').forEach(function(t){ t.classList.remove('active'); });
        event.target.classList.add('active');
    }
    function showToast(msg) {
        var t = document.getElementById('toastBox');
        t.textContent = msg; t.classList.add('show');
        setTimeout(function(){ t.classList.remove('show'); }, 3000);
    }
    <% if (!string.IsNullOrEmpty(ToastMessage)) { %>
        window.addEventListener('load', function(){ showToast('<%= ToastMessage %>'); });
    <% } %>
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