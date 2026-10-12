<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ListItem.aspx.cs" Inherits="ThriftHub.Pages.Seller.ListItem" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>List an Item – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root { --cream:#F5F0E8; --forest:#2C4A3E; --gold:#D4A853; --charcoal:#1A1A1A; --muted:#7A7A6E; --white:#FFFFFF; --border:#DDD8CE; --error:#C0392B; --success:#27AE60; }
        body { font-family:'DM Sans',sans-serif; background:var(--cream); min-height:100vh; }
        nav { background:var(--forest); padding:0 40px; display:flex; align-items:center; justify-content:space-between; height:64px; position:sticky; top:0; z-index:100; }
        .nav-brand { font-family:'Playfair Display',serif; font-size:1.5rem; color:var(--white); text-decoration:none; }
        .nav-brand span { color:var(--gold); }
        .nav-links a { color:rgba(255,255,255,0.75); text-decoration:none; padding:8px 16px; border-radius:8px; font-size:0.88rem; transition:all 0.2s; }
        .nav-links a:hover, .nav-links a.active { background:rgba(255,255,255,0.12); color:var(--white); }
        .nav-user { display:flex; align-items:center; gap:12px; }
        .nav-user span { color:rgba(255,255,255,0.7); font-size:0.85rem; }
        .btn-logout { background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.2); color:var(--white); padding:7px 16px; border-radius:8px; font-size:0.82rem; text-decoration:none; }
        .page-wrap { max-width:800px; margin:0 auto; padding:40px 24px; }
        .page-header { margin-bottom:32px; }
        .page-header h1 { font-family:'Playfair Display',serif; font-size:1.8rem; color:var(--charcoal); }
        .page-header p { color:var(--muted); font-size:0.9rem; margin-top:4px; }
        .form-card { background:var(--white); border-radius:20px; padding:36px; border:1px solid var(--border); margin-bottom:24px; }
        .section-heading { font-size:0.78rem; font-weight:600; text-transform:uppercase; letter-spacing:1px; color:var(--muted); margin-bottom:20px; padding-bottom:10px; border-bottom:1px solid var(--border); }
        .form-row { display:flex; gap:16px; margin-bottom:18px; }
        .form-group { flex:1; display:flex; flex-direction:column; margin-bottom:18px; }
        .form-row .form-group { margin-bottom:0; }
        label { font-size:0.82rem; font-weight:500; color:var(--charcoal); margin-bottom:7px; }
        input[type=text], input[type=number], select, textarea { width:100%; padding:12px 16px; border:1.5px solid var(--border); border-radius:10px; font-family:'DM Sans',sans-serif; font-size:0.93rem; color:var(--charcoal); background:var(--white); transition:border-color 0.2s; appearance:none; }
        input:focus, select:focus, textarea:focus { outline:none; border-color:var(--forest); box-shadow:0 0 0 3px rgba(44,74,62,0.08); }
        textarea { resize:vertical; min-height:100px; }
        .field-error { color:var(--error); font-size:0.78rem; margin-top:5px; }
        .server-message { padding:12px 16px; border-radius:10px; font-size:0.88rem; margin-bottom:20px; }
        .server-message.error   { background:#FDECEA; color:var(--error); border:1px solid #F5C6C2; }
        .server-message.success { background:#E9F7EF; color:var(--success); border:1px solid #A9DFBF; }
        .upload-zone { border:2px dashed var(--border); border-radius:12px; padding:32px; text-align:center; cursor:pointer; transition:border-color 0.2s, background 0.2s; background:#FAFAF8; }
        .upload-zone:hover { border-color:var(--forest); background:#EFF5F3; }
        .upload-zone .icon { font-size:2rem; margin-bottom:8px; }
        .upload-zone p { color:var(--muted); font-size:0.88rem; }
        .upload-zone input[type=file] { display:none; }
        #imagePreview { display:flex; flex-wrap:wrap; gap:10px; margin-top:14px; }
        #imagePreview img { width:80px; height:80px; object-fit:cover; border-radius:8px; border:1px solid var(--border); }
        .price-wrap { position:relative; }
        .price-wrap::before { content:'R'; position:absolute; left:14px; top:50%; transform:translateY(-50%); color:var(--muted); font-weight:500; }
        .price-wrap input { padding-left:32px; }
        .commission-note { background:#FEF3E2; border:1px solid #FAD7A0; border-radius:10px; padding:12px 16px; font-size:0.83rem; color:#784212; margin-top:8px; }
        .btn-submit { width:100%; padding:15px; background:var(--forest); color:var(--white); border:none; border-radius:12px; font-family:'DM Sans',sans-serif; font-size:0.97rem; font-weight:500; cursor:pointer; transition:background 0.2s, transform 0.15s; }
        .btn-submit:hover { background:#1E3329; transform:translateY(-1px); }
        .btn-back { display:inline-block; color:var(--forest); text-decoration:none; font-size:0.88rem; margin-bottom:20px; }
        .btn-back:hover { text-decoration:underline; }
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
        <a href="Dashboard.aspx">Dashboard</a>
        <a href="ListItem.aspx" class="active">+ List Item</a>
        <a href="Dashboard.aspx">My Listings</a>
        <a href="../Settings.aspx">⚙️ Settings</a>
    </div>
    <div class="nav-user">
        <span>👋 <asp:Literal ID="litName" runat="server"/></span>
        <a href="../../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="page-wrap">
    <a href="Dashboard.aspx" class="btn-back">← Back to Dashboard</a>

    <div class="page-header">
        <h1><asp:Literal ID="litPageTitle" runat="server">List a New Item</asp:Literal></h1>
        <p>Fill in your item details. It will be reviewed by a moderator before going live.</p>
    </div>

    <form id="listForm" runat="server" enctype="multipart/form-data">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>

        <!-- Basic Info -->
        <div class="form-card">
            <div class="section-heading">Item Details</div>

            <div class="form-group">
                <label>Title *</label>
                <asp:TextBox ID="txtTitle" runat="server" placeholder="e.g. Levi's 501 Blue Denim Jeans" />
                <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" ErrorMessage="Title is required." CssClass="field-error" Display="Dynamic" />
            </div>

            <div class="form-group">
                <label>Description *</label>
                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" placeholder="Describe the item — condition, any flaws, why you're selling it..." />
                <asp:RequiredFieldValidator ID="rfvDesc" runat="server" ControlToValidate="txtDescription" ErrorMessage="Description is required." CssClass="field-error" Display="Dynamic" />
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Brand</label>
                    <asp:TextBox ID="txtBrand" runat="server" placeholder="e.g. Nike, Zara, H&M" />
                </div>
                <div class="form-group">
                    <label>Category *</label>
                    <asp:DropDownList ID="ddlCategory" runat="server">
                        <asp:ListItem Value="">-- Select Category --</asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvCat" runat="server" ControlToValidate="ddlCategory" InitialValue="" ErrorMessage="Please select a category." CssClass="field-error" Display="Dynamic" />
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Size</label>
                    <asp:DropDownList ID="ddlSize" runat="server">
                        <asp:ListItem Value="">-- Select --</asp:ListItem>
                        <asp:ListItem>XS</asp:ListItem>
                        <asp:ListItem>S</asp:ListItem>
                        <asp:ListItem>M</asp:ListItem>
                        <asp:ListItem>L</asp:ListItem>
                        <asp:ListItem>XL</asp:ListItem>
                        <asp:ListItem>XXL</asp:ListItem>
                        <asp:ListItem>One Size</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group">
                    <label>Condition *</label>
                    <asp:DropDownList ID="ddlCondition" runat="server">
                        <asp:ListItem Value="">-- Select --</asp:ListItem>
                        <asp:ListItem>New with tags</asp:ListItem>
                        <asp:ListItem>Like New</asp:ListItem>
                        <asp:ListItem>Good</asp:ListItem>
                        <asp:ListItem>Fair</asp:ListItem>
                        <asp:ListItem>Poor</asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvCond" runat="server" ControlToValidate="ddlCondition" InitialValue="" ErrorMessage="Please select condition." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="form-group">
                    <label>Gender</label>
                    <asp:DropDownList ID="ddlGender" runat="server">
                        <asp:ListItem Value="">-- Select --</asp:ListItem>
                        <asp:ListItem>Male</asp:ListItem>
                        <asp:ListItem>Female</asp:ListItem>
                        <asp:ListItem>Unisex</asp:ListItem>
                        <asp:ListItem>Kids</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Colour</label>
                    <asp:TextBox ID="txtColour" runat="server" placeholder="e.g. Navy Blue" />
                </div>
                <div class="form-group">
                    <label>Price (ZAR) *</label>
                    <div class="price-wrap">
                        <asp:TextBox ID="txtPrice" runat="server" placeholder="0.00" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPrice" runat="server" ControlToValidate="txtPrice" ErrorMessage="Price is required." CssClass="field-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revPrice" runat="server" ControlToValidate="txtPrice" ValidationExpression="^\d+(\.\d{1,2})?$" ErrorMessage="Enter a valid price." CssClass="field-error" Display="Dynamic" />
                    <div class="commission-note" id="commNote" style="display:none">
                        💡 You will receive <strong id="sellerAmount">R0.00</strong> after 5% platform commission.
                    </div>
                </div>
            </div>
        </div>

        <!-- Images -->
        <div class="form-card">
            <div class="section-heading">Photos</div>
            <div class="upload-zone" onclick="document.getElementById('<%= fuImages.ClientID %>').click()">
                <div class="icon">📷</div>
                <p>Click to upload photos (max 5, JPG/PNG)</p>
                <asp:FileUpload ID="fuImages" runat="server" AllowMultiple="true" accept="image/jpeg,image/png" />
            </div>
            <div id="imagePreview"></div>
        </div>

        <asp:Button ID="btnSubmit" runat="server" Text="Submit for Approval" CssClass="btn-submit" OnClick="BtnSubmit_Click" />
    </form>
</div>

<script>
    // Image preview
    document.getElementById('<%= fuImages.ClientID %>').addEventListener('change', function () {
        var preview = document.getElementById('imagePreview');
        preview.innerHTML = '';
        var files = this.files;
        for (var i = 0; i < Math.min(files.length, 5); i++) {
            var reader = new FileReader();
            reader.onload = function (e) {
                var img = document.createElement('img');
                img.src = e.target.result;
                preview.appendChild(img);
            };
            reader.readAsDataURL(files[i]);
        }
    });

    // Commission calculator
    document.getElementById('<%= txtPrice.ClientID %>').addEventListener('input', function () {
        var price = parseFloat(this.value);
        var note = document.getElementById('commNote');
        if (!isNaN(price) && price > 0) {
            var payout = (price * 0.95).toFixed(2);
            document.getElementById('sellerAmount').textContent = 'R' + payout;
            note.style.display = 'block';
        } else {
            note.style.display = 'none';
        }
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
                <li><a href="Dashboard.aspx"               runat="server">Home</a></li>
                <li><a href="Dashboard.aspx" runat="server">My listing</a></li>                
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