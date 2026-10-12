<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Catalogue.aspx.cs" Inherits="ThriftHub.Pages.Buyer.Catalogue" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Catalogue – ThriftHub</title>
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
        .filter-bar{background:var(--white);border-radius:16px;padding:20px 24px;border:1px solid var(--border);margin-bottom:28px;display:flex;gap:12px;flex-wrap:wrap;align-items:flex-end}
        .filter-group{display:flex;flex-direction:column;gap:6px;min-width:160px;flex:1}
        .filter-group label{font-size:0.75rem;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px}
        .filter-group input,.filter-group select{padding:10px 14px;border:1.5px solid var(--border);border-radius:9px;font-family:'DM Sans',sans-serif;font-size:0.88rem;color:var(--charcoal);background:var(--white);appearance:none}
        .filter-group input:focus,.filter-group select:focus{outline:none;border-color:var(--forest)}
        .btn-search{padding:10px 24px;background:var(--forest);color:var(--white);border:none;border-radius:9px;font-family:'DM Sans',sans-serif;font-weight:500;cursor:pointer;transition:background 0.2s;white-space:nowrap}
        .btn-search:hover{background:#1E3329}
        .btn-clear{padding:10px 16px;background:transparent;color:var(--muted);border:1.5px solid var(--border);border-radius:9px;font-family:'DM Sans',sans-serif;cursor:pointer;transition:all 0.2s}
        .btn-clear:hover{border-color:var(--error);color:var(--error)}
        .results-info{font-size:0.88rem;color:var(--muted);margin-bottom:20px}
        .results-info strong{color:var(--charcoal)}
        .items-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:20px}
        .item-card{background:var(--white);border-radius:16px;border:1px solid var(--border);overflow:hidden;transition:box-shadow 0.2s,transform 0.2s;cursor:pointer;position:relative}
        .item-card:hover{box-shadow:0 8px 30px rgba(0,0,0,0.1);transform:translateY(-3px)}
        .item-img{width:100%;height:220px;background:#F0EBE0;display:flex;align-items:center;justify-content:center;font-size:4rem;position:relative;overflow:hidden}
        .item-img img{width:100%;height:220px;object-fit:cover}
        .item-badge{position:absolute;top:12px;left:12px;background:var(--forest);color:var(--white);font-size:0.72rem;padding:4px 10px;border-radius:50px;font-weight:500}
        .btn-wish{position:absolute;top:10px;right:10px;width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,0.92);border:none;cursor:pointer;font-size:1rem;display:flex;align-items:center;justify-content:center;box-shadow:0 2px 8px rgba(0,0,0,0.12);transition:transform 0.2s,background 0.2s;z-index:10;text-decoration:none}
        .btn-wish:hover{transform:scale(1.15);background:var(--white)}
        .btn-wish.wished{background:#FFF0F0}
        .item-body{padding:16px}
        .item-title{font-weight:600;font-size:0.95rem;color:var(--charcoal);margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .item-meta{font-size:0.8rem;color:var(--muted);margin-bottom:10px}
        .item-footer{display:flex;align-items:center;justify-content:space-between;margin-top:12px}
        .item-price{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--forest)}
        .btn-cart{background:var(--forest);color:var(--white);border:none;padding:8px 16px;border-radius:8px;font-size:0.82rem;cursor:pointer;font-family:'DM Sans',sans-serif;transition:background 0.2s}
        .btn-cart:hover{background:#1E3329}
        .empty-state{text-align:center;padding:80px 20px;color:var(--muted)}
        .empty-state .icon{font-size:4rem;margin-bottom:16px}
        .toast{position:fixed;bottom:24px;right:24px;background:var(--forest);color:var(--white);padding:14px 24px;border-radius:12px;font-size:0.9rem;box-shadow:0 4px 20px rgba(0,0,0,0.15);transform:translateY(100px);opacity:0;transition:all 0.3s;z-index:999}
        .toast.show{transform:translateY(0);opacity:1}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.success{background:#E9F7EF;color:var(--success);border:1px solid #A9DFBF}
        .server-message.error{background:#FDECEA;color:var(--error);border:1px solid #F5C6C2}
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

        /* ============================================
           AD BANNER
        ============================================ */
        .ad-banner-wrap{position:relative;width:100%;overflow:hidden;background:var(--charcoal);height:80px;transition:height 0.4s ease}
        .ad-banner-wrap.dismissed{height:0;overflow:hidden}
        .ad-track{display:flex;height:100%;transition:transform 0.6s cubic-bezier(0.4,0,0.2,1)}
        .ad-slide{min-width:100%;height:80px;display:flex;align-items:center;justify-content:space-between;padding:0 48px 0 40px;position:relative;overflow:hidden;cursor:pointer}
        /* Brand slides */
        .ad-slide.nike   {background:linear-gradient(135deg,#111 0%,#2A2A2A 100%)}
        .ad-slide.adidas {background:linear-gradient(135deg,#000 0%,#1A1A2E 100%)}
        .ad-slide.zara   {background:linear-gradient(135deg,#1A1A1A 0%,#3D3D3D 100%)}
        /* ThriftHub promo slides */
        .ad-slide.promo-sell  {background:linear-gradient(135deg,#2C4A3E 0%,#1A3028 100%)}
        .ad-slide.promo-new   {background:linear-gradient(135deg,#4A3A2C 0%,#2E2218 100%)}
        .ad-slide.promo-refer {background:linear-gradient(135deg,#2C3A4A 0%,#1A2430 100%)}
        /* Glow blob */
        .ad-slide::before{content:'';position:absolute;right:-40px;top:50%;transform:translateY(-50%);width:180px;height:180px;border-radius:50%;opacity:0.07}
        .ad-slide.nike::before,.ad-slide.adidas::before,.ad-slide.zara::before{background:#fff}
        .ad-slide.promo-sell::before,.ad-slide.promo-new::before,.ad-slide.promo-refer::before{background:var(--gold);right:80px}
        /* Left content */
        .ad-left{display:flex;align-items:center;gap:16px;z-index:1;min-width:0;flex:1}
        .ad-tag{font-size:0.58rem;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;color:rgba(255,255,255,0.35);border:1px solid rgba(255,255,255,0.15);border-radius:4px;padding:3px 7px;white-space:nowrap;flex-shrink:0}
        .ad-brand-logo{font-size:1.5rem;font-weight:900;letter-spacing:-1px;white-space:nowrap;flex-shrink:0}
        .ad-slide.nike   .ad-brand-logo{color:#fff;font-family:Arial Black,sans-serif}
        .ad-slide.adidas .ad-brand-logo{color:#fff;font-family:Arial Black,sans-serif}
        .ad-slide.zara   .ad-brand-logo{color:#fff;font-family:'Playfair Display',serif;letter-spacing:4px}
        .ad-promo-logo{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--white);white-space:nowrap;flex-shrink:0}
        .ad-promo-logo span{color:var(--gold)}
        .ad-divider{width:1px;height:28px;background:rgba(255,255,255,0.15);flex-shrink:0}
        .ad-headline{font-size:0.87rem;font-weight:400;color:rgba(255,255,255,0.80);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .ad-headline strong{color:var(--white);font-weight:700}
        .ad-headline .hl{color:var(--gold);font-weight:600}
        /* Right CTA */
        .ad-right{z-index:1;flex-shrink:0;margin-left:20px}
        .ad-cta{display:inline-block;padding:8px 20px;border-radius:8px;font-family:'DM Sans',sans-serif;font-size:0.8rem;font-weight:600;text-decoration:none;transition:all 0.2s;white-space:nowrap;cursor:pointer;border:none}
        .ad-slide.nike    .ad-cta{background:#fff;color:#111}
        .ad-slide.adidas  .ad-cta{background:#fff;color:#000}
        .ad-slide.zara    .ad-cta{background:#fff;color:#1A1A1A}
        .ad-slide.promo-sell  .ad-cta{background:var(--gold);color:var(--charcoal)}
        .ad-slide.promo-new   .ad-cta{background:var(--gold);color:var(--charcoal)}
        .ad-slide.promo-refer .ad-cta{background:var(--gold);color:var(--charcoal)}
        .ad-cta:hover{transform:scale(1.04);opacity:0.88}
        /* Dismiss */
        .ad-dismiss{position:absolute;top:50%;right:12px;transform:translateY(-50%);background:rgba(255,255,255,0.08);border:none;color:rgba(255,255,255,0.35);width:22px;height:22px;border-radius:50%;font-size:0.68rem;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all 0.2s;z-index:10}
        .ad-dismiss:hover{background:rgba(255,255,255,0.18);color:#fff}
        /* Dots */
        .ad-dots{position:absolute;bottom:6px;left:50%;transform:translateX(-50%);display:flex;gap:5px;z-index:10}
        .ad-dot{width:5px;height:5px;border-radius:50%;background:rgba(255,255,255,0.22);cursor:pointer;transition:all 0.3s}
        .ad-dot.active{background:var(--gold);width:16px;border-radius:3px}
        /* Progress bar */
        .ad-progress{position:absolute;bottom:0;left:0;height:2px;background:var(--gold);opacity:0.55;width:0%}
        .ad-progress.running{animation:adProg 5s linear}
        @keyframes adProg{0%{width:0%}100%{width:100%}}
        /* ============================================ */

        footer{background:var(--forest);color:rgba(255,255,255,0.75);padding:40px 0 0 0}
        .footer-top{max-width:1200px;margin:0 auto;padding:0 24px 32px;display:grid;grid-template-columns:1fr 1fr 1fr;gap:32px}
        .footer-brand{font-family:'Playfair Display',serif;font-size:1.4rem;color:var(--white);margin-bottom:8px}
        .footer-brand span{color:var(--gold)}
        .footer-tagline{font-size:0.83rem;color:rgba(255,255,255,0.55);line-height:1.6}
        .footer-heading{font-size:0.75rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--gold);margin-bottom:12px}
        .footer-links{list-style:none;padding:0}
        .footer-links li{margin-bottom:6px}
        .footer-links a{color:rgba(255,255,255,0.6);text-decoration:none;font-size:0.85rem;transition:color 0.2s}
        .footer-links a:hover{color:var(--white)}
        .brand-ticker{background:var(--charcoal);padding:10px 0;overflow:hidden;border-top:1px solid rgba(255,255,255,0.05)}
        .ticker-track{display:flex;animation:tickerScroll 28s linear infinite;white-space:nowrap}
        .ticker-track:hover{animation-play-state:paused}
        .ticker-item{color:rgba(255,255,255,0.35);font-size:0.72rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;padding:0 28px}
        .ticker-dot{color:var(--gold);opacity:0.6}
        @keyframes tickerScroll{0%{transform:translateX(0)}100%{transform:translateX(-50%)}}
        .footer-bottom{background:rgba(0,0,0,0.2);padding:14px 24px;text-align:center;font-size:0.8rem;color:rgba(255,255,255,0.45);border-top:1px solid rgba(255,255,255,0.08)}
        .footer-bottom strong{color:rgba(255,255,255,0.7)}
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

<%-- ============================================
     ROTATING AD BANNER
============================================ --%>
<div class="ad-banner-wrap" id="adBanner">
    <div class="ad-track" id="adTrack">

        <%-- AD 1: Nike --%>
        <div class="ad-slide nike">
            <div class="ad-left">
                <span class="ad-tag">Ad</span>
                <span class="ad-brand-logo">NIKE</span>
                <div class="ad-divider"></div>
                <span class="ad-headline"><strong>Just Do It.</strong> &nbsp;Pre-owned Nike on ThriftHub — <span class="hl">up to 60% off retail</span></span>
            </div>
            <div class="ad-right">
                <button class="ad-cta" onclick="adClick('Nike')">Shop Nike →</button>
            </div>
        </div>

        <%-- AD 2: ThriftHub Sell Promo --%>
        <div class="ad-slide promo-sell">
            <div class="ad-left">
                <span class="ad-tag">Promoted</span>
                <span class="ad-promo-logo">Thrift<span>Hub</span></span>
                <div class="ad-divider"></div>
                <span class="ad-headline">Got clothes you no longer wear? <strong>Turn them into cash.</strong> &nbsp;<span class="hl">List for free today!</span></span>
            </div>
            <div class="ad-right">
                <button class="ad-cta" onclick="adClick('Sell on ThriftHub')">Start Selling →</button>
            </div>
        </div>

        <%-- AD 3: Adidas --%>
        <div class="ad-slide adidas">
            <div class="ad-left">
                <span class="ad-tag">Ad</span>
                <span class="ad-brand-logo">adidas</span>
                <div class="ad-divider"></div>
                <span class="ad-headline"><strong>Impossible Is Nothing.</strong> &nbsp;Find pre-loved Adidas gear — <span class="hl">verified sellers only</span></span>
            </div>
            <div class="ad-right">
                <button class="ad-cta" onclick="adClick('Adidas')">Shop Adidas →</button>
            </div>
        </div>

        <%-- AD 4: ThriftHub New Arrivals Promo --%>
        <div class="ad-slide promo-new">
            <div class="ad-left">
                <span class="ad-tag">Promoted</span>
                <span class="ad-promo-logo">Thrift<span>Hub</span></span>
                <div class="ad-divider"></div>
                <span class="ad-headline"><strong>New arrivals daily.</strong> &nbsp;Fresh pre-loved listings added every day — <span class="hl">don't miss out</span></span>
            </div>
            <div class="ad-right">
                <button class="ad-cta" onclick="adClick('New Arrivals')">See New In →</button>
            </div>
        </div>

        <%-- AD 5: Zara --%>
        <div class="ad-slide zara">
            <div class="ad-left">
                <span class="ad-tag">Ad</span>
                <span class="ad-brand-logo">ZARA</span>
                <div class="ad-divider"></div>
                <span class="ad-headline"><strong>Style redefined.</strong> &nbsp;Pre-owned Zara fashion at a fraction of the price — <span class="hl">shop sustainably</span></span>
            </div>
            <div class="ad-right">
                <button class="ad-cta" onclick="adClick('Zara')">Shop Zara →</button>
            </div>
        </div>

        <%-- AD 6: ThriftHub Refer Promo --%>
        <div class="ad-slide promo-refer">
            <div class="ad-left">
                <span class="ad-tag">Promoted</span>
                <span class="ad-promo-logo">Thrift<span>Hub</span></span>
                <div class="ad-divider"></div>
                <span class="ad-headline"><strong>Refer a friend</strong> and both get <span class="hl">R50 off your next purchase!</span> &nbsp;Limited time.</span>
            </div>
            <div class="ad-right">
                <button class="ad-cta" onclick="adClick('Refer a Friend')">Refer Now →</button>
            </div>
        </div>

    </div>

    <%-- Dot indicators --%>
    <div class="ad-dots" id="adDots">
        <div class="ad-dot active" onclick="goToAd(0)"></div>
        <div class="ad-dot" onclick="goToAd(1)"></div>
        <div class="ad-dot" onclick="goToAd(2)"></div>
        <div class="ad-dot" onclick="goToAd(3)"></div>
        <div class="ad-dot" onclick="goToAd(4)"></div>
        <div class="ad-dot" onclick="goToAd(5)"></div>
    </div>

    <%-- Progress bar --%>
    <div class="ad-progress running" id="adProgress"></div>

    <%-- Dismiss --%>
    <button type="button" class="ad-dismiss" onclick="dismissAd()" title="Close">✕</button>
</div>
<%-- ============================================ --%>

<div class="page-wrap">
    <div class="page-header">
        <h1>Browse Catalogue</h1>
        <p>Discover pre-owned clothing from verified sellers</p>
    </div>

    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <div class="filter-bar">
        <div class="filter-group" style="flex:2;min-width:200px">
            <label>Search</label>
            <asp:TextBox ID="txtSearch" runat="server" placeholder="Search items, brands..."/>
        </div>
        <div class="filter-group">
            <label>Category</label>
            <asp:DropDownList ID="ddlCategory" runat="server">
                <asp:ListItem Value="">All Categories</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="filter-group">
            <label>Size</label>
            <asp:DropDownList ID="ddlSize" runat="server">
                <asp:ListItem Value="">All Sizes</asp:ListItem>
                <asp:ListItem>XS</asp:ListItem><asp:ListItem>S</asp:ListItem>
                <asp:ListItem>M</asp:ListItem><asp:ListItem>L</asp:ListItem>
                <asp:ListItem>XL</asp:ListItem><asp:ListItem>XXL</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="filter-group">
            <label>Gender</label>
            <asp:DropDownList ID="ddlGender" runat="server">
                <asp:ListItem Value="">All</asp:ListItem>
                <asp:ListItem>Male</asp:ListItem><asp:ListItem>Female</asp:ListItem>
                <asp:ListItem>Unisex</asp:ListItem><asp:ListItem>Kids</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="filter-group">
            <label>Max Price (R)</label>
            <asp:TextBox ID="txtMaxPrice" runat="server" placeholder="e.g. 500"/>
        </div>
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn-search" OnClick="BtnSearch_Click"/>
        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn-clear" OnClick="BtnClear_Click" CausesValidation="false"/>
    </div>

    <div class="results-info">
        Showing <strong><asp:Literal ID="litCount" runat="server">0</asp:Literal></strong> approved items
    </div>

    <div class="items-grid">
        <asp:Repeater ID="rptItems" runat="server" OnItemCommand="rptItems_ItemCommand">
            <ItemTemplate>
                <div class="item-card" onclick="window.location='ItemDetail.aspx?id=<%# Eval("ListingID") %>'">
                    <div class="item-img">
                        <%# GetItemImage(Eval("ListingID")) %>
                        <span class="item-badge"><%# Eval("Condition") %></span>
                        <asp:LinkButton runat="server"
                            CommandName="ToggleWishlist"
                            CommandArgument='<%# Eval("ListingID") %>'
                            CssClass='<%# "btn-wish" + (IsWishlisted(Eval("ListingID")) ? " wished" : "") %>'
                            OnClientClick="event.stopPropagation(); return true;"
                            ToolTip="Save to Wishlist"><%# IsWishlisted(Eval("ListingID")) ? "❤️" : "🤍" %></asp:LinkButton>
                    </div>
                    <div class="item-body">
                        <div class="item-title"><%# Eval("Title") %></div>
                        <div class="item-meta"><%# Eval("Brand") %> · Size <%# Eval("Size") %> · <%# Eval("CategoryName") %></div>
                        <div class="item-footer">
                            <div class="item-price">R <%# string.Format("{0:F2}", Eval("Price")) %></div>
                            <asp:LinkButton runat="server"
                                CommandName="AddToBasket"
                                CommandArgument='<%# Eval("ListingID") %>'
                                CssClass="btn-cart"
                                OnClientClick="event.stopPropagation(); return true;">🛒 Add</asp:LinkButton>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <div class="icon">🔍</div>
            <p>No items found. Try adjusting your filters.</p>
        </div>
    </asp:Panel>
</div>

<div class="toast" id="toastBox"></div>

<script type="text/javascript">

    /* ══════════════════════════════
       AD BANNER
    ══════════════════════════════ */
    var adCurrent  = 0;
    var adTotal    = 6;
    var adTimer    = null;

    function goToAd(index) {
        adCurrent = (index + adTotal) % adTotal;
        document.getElementById('adTrack').style.transform = 'translateX(-' + (adCurrent * 100) + '%)';
        document.querySelectorAll('.ad-dot').forEach(function(d, i) {
            d.classList.toggle('active', i === adCurrent);
        });
        restartProgress();
    }

    function restartProgress() {
        var bar = document.getElementById('adProgress');
        bar.classList.remove('running');
        void bar.offsetWidth; // reflow to restart animation
        bar.classList.add('running');
    }

    function startAds() {
        clearInterval(adTimer);
        adTimer = setInterval(function() { goToAd(adCurrent + 1); }, 5000);
    }

    function dismissAd() {
        clearInterval(adTimer);
        document.getElementById('adBanner').classList.add('dismissed');
    }

    function adClick(name) {
        showToast('🔗 ' + name + ' — ad clicked!');
    }

    // Pause on hover
    var banner = document.getElementById('adBanner');
    banner.addEventListener('mouseenter', function() {
        clearInterval(adTimer);
        document.getElementById('adProgress').style.animationPlayState = 'paused';
    });
    banner.addEventListener('mouseleave', function() {
        document.getElementById('adProgress').style.animationPlayState = 'running';
        startAds();
    });

    startAds();
    /* ══════════════════════════════ */

    function showToast(message) {
        var t = document.getElementById('toastBox');
        t.textContent = message; t.classList.add('show');
        setTimeout(function(){ t.classList.remove('show'); }, 3000);
    }
    window.addEventListener('load', function() {
        <% if (!string.IsNullOrEmpty(ToastMessage)) { %>
            showToast('<%= ToastMessage %>');
        <% } %>
    });
    var NOTIF_KEY = 'thrifthub_buyer_notifications';
    function loadNotifications(){ try{ return JSON.parse(sessionStorage.getItem(NOTIF_KEY))||[]; }catch(e){ return []; } }
    function saveNotifications(l){ sessionStorage.setItem(NOTIF_KEY, JSON.stringify(l)); }
    function addBuyerNotification(type,message){ var l=loadNotifications(); l.unshift({id:Date.now(),type:type,message:message,time:new Date().toLocaleString(),read:false}); if(l.length>20)l=l.slice(0,20); saveNotifications(l); renderNotifications(); }
    function getNotifIcon(t){ return {confirmed:'✅',shipped:'🚚',delivered:'📦',info:'ℹ️'}[t]||'🔔'; }
    function renderNotifications(){
        var list=loadNotifications(),unread=list.filter(function(n){return !n.read;}).length;
        var badge=document.getElementById('notifBadge'),nl=document.getElementById('notifList');
        if(unread>0){badge.textContent=unread>9?'9+':unread;badge.classList.add('visible');}else{badge.classList.remove('visible');}
        if(list.length===0){nl.innerHTML='<div class="notif-empty"><div class="icon">🔕</div><div>No notifications yet</div></div>';return;}
        nl.innerHTML=list.map(function(n){return '<div class="notif-item '+(n.read?'':'unread')+'" onclick="markOneRead('+n.id+')">'+'<div class="notif-icon">'+getNotifIcon(n.type)+'</div>'+'<div class="notif-content"><div class="notif-msg">'+n.message+'</div><div class="notif-time">'+n.time+'</div></div>'+(!n.read?'<div class="notif-unread-dot"></div>':'')+'</div>';}).join('');
    }
    function markOneRead(id){ var l=loadNotifications(); l=l.map(function(n){if(n.id===id)n.read=true;return n;}); saveNotifications(l);renderNotifications(); }
    function markAllRead(){ var l=loadNotifications(); l=l.map(function(n){n.read=true;return n;}); saveNotifications(l);renderNotifications(); }
    function toggleNotifDropdown(e){ e.stopPropagation(); document.getElementById('notifDropdown').classList.toggle('open'); }
    document.addEventListener('click',function(e){ var d=document.getElementById('notifDropdown'); if(d&&d.classList.contains('open')&&!d.contains(e.target))d.classList.remove('open'); });
    <% if (!string.IsNullOrEmpty(BuyerNotificationMessage)) { %>
        addBuyerNotification('<%= BuyerNotificationType %>', '<%= BuyerNotificationMessage %>');
    <% } %>
    window.addEventListener('load', renderNotifications);
</script>
</form>

<footer>
    <div class="footer-top">
        <div>
            <div class="footer-brand">Thrift<span>Hub</span></div>
            <p class="footer-tagline">Pre-Loved Fashion. New Possibilities.<br/>South Africa's trusted second-hand clothing marketplace.</p>
        </div>
        <div>
            <div class="footer-heading">Quick Links</div>
            <ul class="footer-links">
                <li><a href="Catalogue.aspx">Home</a></li>
                <li><a href="Catalogue.aspx">Browse Catalogue</a></li>
                <li><a href="OrderTracking.aspx">Order Tracking</a></li>
                <li><a href="../../Logout.aspx">Logout</a></li>
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
        <strong>Group 6</strong> &nbsp;|&nbsp; ThriftHub &nbsp;|&nbsp;
        &copy; <%= DateTime.Now.Year %> ThriftHub. All rights reserved.
    </div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>