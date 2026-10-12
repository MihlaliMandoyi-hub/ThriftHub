<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReviewOrder.aspx.cs" Inherits="ThriftHub.Pages.Buyer.ReviewOrder" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Review Order – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;--charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;--border:#DDD8CE;--error:#C0392B;--success:#27AE60}
        body{font-family:'DM Sans',sans-serif;background:var(--cream);min-height:100vh}
        nav{background:var(--forest);padding:0 40px;display:flex;align-items:center;justify-content:space-between;height:64px;position:sticky;top:0;z-index:100}
        .nav-brand{font-family:'Playfair Display',serif;font-size:1.5rem;color:var(--white);text-decoration:none}
        .nav-brand span{color:var(--gold)}
        .nav-links a{color:rgba(255,255,255,0.75);text-decoration:none;padding:8px 16px;border-radius:8px;font-size:0.88rem}
        .nav-links a:hover{background:rgba(255,255,255,0.12);color:var(--white)}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:680px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:28px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .page-header p{color:var(--muted);font-size:0.9rem;margin-top:4px}
        .review-card{background:var(--white);border-radius:20px;border:1px solid var(--border);padding:32px;margin-bottom:20px}
        .item-preview{display:flex;gap:16px;align-items:center;margin-bottom:24px;padding-bottom:20px;border-bottom:1px solid var(--border)}
        .item-preview .img{width:72px;height:72px;border-radius:10px;background:#F0EBE0;display:flex;align-items:center;justify-content:center;font-size:2rem;flex-shrink:0;overflow:hidden}
        .item-preview .img img{width:72px;height:72px;object-fit:cover;border-radius:10px}
        .item-preview .info strong{font-size:0.95rem;color:var(--charcoal)}
        .item-preview .info span{font-size:0.82rem;color:var(--muted);display:block;margin-top:2px}
        .section-label{font-size:0.82rem;font-weight:600;color:var(--charcoal);margin-bottom:12px;text-transform:uppercase;letter-spacing:0.5px}
        /* Star rating */
        .star-rating{display:flex;gap:8px;margin-bottom:24px;flex-direction:row-reverse;justify-content:flex-end}
        .star-rating input{display:none}
        .star-rating label{font-size:2.4rem;cursor:pointer;color:#DDD8CE;transition:color 0.15s;line-height:1}
        .star-rating label:hover,.star-rating label:hover ~ label,
        .star-rating input:checked ~ label{color:var(--gold)}
        /* Review text */
        .review-textarea{width:100%;padding:14px;border:1.5px solid var(--border);border-radius:10px;font-family:'DM Sans',sans-serif;font-size:0.92rem;height:120px;resize:none;color:var(--charcoal);margin-bottom:20px;box-sizing:border-box}
        .review-textarea:focus{outline:none;border-color:var(--forest)}
        .btn-submit{width:100%;padding:15px;background:var(--forest);color:var(--white);border:none;border-radius:12px;font-family:'DM Sans',sans-serif;font-size:1rem;font-weight:500;cursor:pointer;transition:background 0.2s}
        .btn-submit:hover{background:#1E3329}
        .btn-back{display:inline-block;color:var(--forest);text-decoration:none;font-size:0.88rem;margin-bottom:24px}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}
        .already-reviewed{text-align:center;padding:40px;color:var(--muted)}
        .already-reviewed .stars{font-size:2rem;margin-bottom:12px}
        /* Rating hint */
        .rating-hint{font-size:0.82rem;color:var(--muted);margin-bottom:16px;height:20px;transition:all 0.2s}
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
        <a href="../../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<form id="mainForm" runat="server">
<div class="page-wrap">

    <a href="OrderTracking.aspx" class="btn-back">← Back to My Orders</a>

    <div class="page-header">
        <h1>Leave a Review</h1>
        <p>Share your experience with this purchase</p>
    </div>

    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <%-- Already reviewed panel --%>
    <asp:Panel ID="pnlAlreadyReviewed" runat="server" Visible="false">
        <div class="review-card">
            <div class="already-reviewed">
                <div class="stars">⭐⭐⭐⭐⭐</div>
                <h3 style="color:var(--charcoal);margin-bottom:8px">Already Reviewed!</h3>
                <p>You have already submitted a review for this item.</p>
                <a href="OrderTracking.aspx" style="color:var(--forest);font-weight:500;text-decoration:none;display:inline-block;margin-top:16px">← Back to Orders</a>
            </div>
        </div>
    </asp:Panel>

    <%-- Review form panel --%>
    <asp:Panel ID="pnlReview" runat="server">
        <div class="review-card">

            <%-- Item preview --%>
            <div class="item-preview">
                <div class="img">
                    <asp:Literal ID="litItemImage" runat="server">👗</asp:Literal>
                </div>
                <div class="info">
                    <strong><asp:Literal ID="litItemTitle" runat="server"/></strong>
                    <span>Sold by: <asp:Literal ID="litSellerName" runat="server"/></span>
                    <span>Order #<asp:Literal ID="litOrderID" runat="server"/></span>
                </div>
            </div>

            <%-- Star rating --%>
            <div class="section-label">Your Rating</div>
            <div class="star-rating" id="starRating">
                <asp:RadioButton ID="rb5" runat="server" GroupName="Rating" InputAttributes-id="star5"/>
                <label for="star5" title="5 stars – Excellent!" onclick="setRating(5)">★</label>

                <asp:RadioButton ID="rb4" runat="server" GroupName="Rating" InputAttributes-id="star4"/>
                <label for="star4" title="4 stars – Good" onclick="setRating(4)">★</label>

                <asp:RadioButton ID="rb3" runat="server" GroupName="Rating" InputAttributes-id="star3"/>
                <label for="star3" title="3 stars – Average" onclick="setRating(3)">★</label>

                <asp:RadioButton ID="rb2" runat="server" GroupName="Rating" InputAttributes-id="star2"/>
                <label for="star2" title="2 stars – Poor" onclick="setRating(2)">★</label>

                <asp:RadioButton ID="rb1" runat="server" GroupName="Rating" InputAttributes-id="star1"/>
                <label for="star1" title="1 star – Terrible" onclick="setRating(1)">★</label>
            </div>

            <asp:HiddenField ID="hdnRating" runat="server" Value="5"/>

            <div class="rating-hint" id="ratingHint">⭐⭐⭐⭐⭐ Excellent!</div>

            <%-- Review comment --%>
            <div class="section-label">Your Review</div>
            <asp:TextBox ID="txtReview" runat="server"
                TextMode="MultiLine"
                CssClass="review-textarea"
                placeholder="Tell others about the item quality, packaging, and seller communication..."/>

            <asp:Button ID="btnSubmit" runat="server"
                Text="Submit Review"
                CssClass="btn-submit"
                OnClick="BtnSubmit_Click"
                CausesValidation="false"/>
        </div>
    </asp:Panel>

</div>
</form>

<script type="text/javascript">
    var ratings = {
        1: '⭐ Terrible',
        2: '⭐⭐ Poor',
        3: '⭐⭐⭐ Average',
        4: '⭐⭐⭐⭐ Good',
        5: '⭐⭐⭐⭐⭐ Excellent!'
    };

    function setRating(val) {
        document.getElementById('<%= hdnRating.ClientID %>').value = val;
        document.getElementById('ratingHint').textContent = ratings[val] || '';
    }

    // Set default rating display
    window.addEventListener('load', function () {
        var current = document.getElementById('<%= hdnRating.ClientID %>').value || 5;
        document.getElementById('ratingHint').textContent = ratings[current] || '';
    });
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
