<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="ThriftHub.Pages.Settings" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Settings – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{
            --cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;
            --charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;
            --border:#DDD8CE;--error:#C0392B;--success:#27AE60;
            --bg:#F5F0E8;--card:#FFFFFF;--text:#1A1A1A;
            --text-muted:#7A7A6E;--card-border:#DDD8CE;
            --input-bg:#FFFFFF;--input-border:#DDD8CE;
            --nav-bg:#2C4A3E;--section-bg:#F8F5EF;
        }
        body.dark-mode{
            --bg:#0F1C18;--card:#1A2E28;--text:#E8E0D0;
            --text-muted:#8A9E96;--card-border:#2A4038;
            --input-bg:#1F3530;--input-border:#2A4038;
            --nav-bg:#0A1410;--section-bg:#162420;
            --forest:#3D6B5C;
        }
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;transition:background 0.3s,color 0.3s}
        nav{background:var(--nav-bg);padding:0 40px;display:flex;align-items:center;justify-content:space-between;height:64px;position:sticky;top:0;z-index:100;transition:background 0.3s}
        .nav-brand{font-family:'Playfair Display',serif;font-size:1.5rem;color:#fff;text-decoration:none}
        .nav-brand span{color:var(--gold)}
        .nav-links{display:flex;gap:8px}
        .nav-links a{color:rgba(255,255,255,0.75);text-decoration:none;padding:8px 16px;border-radius:8px;font-size:0.88rem;transition:all 0.2s}
        .nav-links a:hover{background:rgba(255,255,255,0.12);color:#fff}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:#fff;padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:800px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:32px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--text)}
        .page-header p{color:var(--text-muted);font-size:0.9rem;margin-top:4px}
        .settings-card{background:var(--card);border-radius:20px;border:1px solid var(--card-border);margin-bottom:20px;overflow:hidden;transition:background 0.3s,border-color 0.3s}
        .card-header{padding:20px 28px;border-bottom:1px solid var(--card-border);display:flex;align-items:center;gap:12px}
        .card-header .icon{font-size:1.4rem}
        .card-header h2{font-size:1rem;font-weight:600;color:var(--text)}
        .card-header p{font-size:0.8rem;color:var(--text-muted);margin-top:2px}
        .setting-row{padding:18px 28px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid var(--card-border);transition:background 0.2s;gap:20px}
        .setting-row:last-child{border-bottom:none}
        .setting-row:hover{background:var(--section-bg)}
        .setting-info{flex:1}
        .setting-label{font-weight:500;font-size:0.92rem;color:var(--text);margin-bottom:3px}
        .setting-desc{font-size:0.78rem;color:var(--text-muted);line-height:1.5}
        .toggle{position:relative;width:52px;height:28px;flex-shrink:0}
        .toggle input{opacity:0;width:0;height:0}
        .slider{position:absolute;cursor:pointer;inset:0;background:#CBD5D1;border-radius:28px;transition:background 0.3s}
        .slider::before{content:'';position:absolute;width:22px;height:22px;left:3px;top:3px;background:#fff;border-radius:50%;transition:transform 0.3s;box-shadow:0 2px 6px rgba(0,0,0,0.15)}
        input:checked + .slider{background:var(--forest)}
        input:checked + .slider::before{transform:translateX(24px)}
        .setting-select{padding:9px 14px;border:1.5px solid var(--input-border);border-radius:9px;font-family:'DM Sans',sans-serif;font-size:0.88rem;color:var(--text);background:var(--input-bg);min-width:160px;cursor:pointer;transition:border-color 0.2s,background 0.3s}
        .setting-select:focus{outline:none;border-color:var(--forest)}
        .colour-options{display:flex;gap:10px;flex-wrap:wrap}
        .colour-swatch{width:30px;height:30px;border-radius:50%;cursor:pointer;border:3px solid transparent;transition:transform 0.2s,border-color 0.2s}
        .colour-swatch:hover{transform:scale(1.15)}
        .colour-swatch.active{border-color:var(--text)}
        .pass-row{padding:20px 28px}
        .form-group{margin-bottom:16px}
        .form-group label{font-size:0.82rem;font-weight:500;color:var(--text);margin-bottom:6px;display:block}
        .form-group input{width:100%;padding:11px 14px;border:1.5px solid var(--input-border);border-radius:9px;font-family:'DM Sans',sans-serif;font-size:0.9rem;color:var(--text);background:var(--input-bg);transition:border-color 0.2s,background 0.3s}
        .form-group input:focus{outline:none;border-color:var(--forest)}
        .btn-save{padding:13px 32px;background:var(--forest);color:#fff;border:none;border-radius:10px;font-family:'DM Sans',sans-serif;font-size:0.95rem;font-weight:500;cursor:pointer;transition:background 0.2s}
        .btn-save:hover{background:#1E3329}
        .danger-row{padding:18px 28px;display:flex;align-items:center;justify-content:space-between;gap:20px}
        .btn-danger{padding:10px 20px;background:transparent;color:var(--error);border:1.5px solid var(--error);border-radius:9px;font-family:'DM Sans',sans-serif;font-size:0.85rem;cursor:pointer;transition:all 0.2s}
        .btn-danger:hover{background:var(--error);color:#fff}
        .profile-row{padding:20px 28px;display:flex;align-items:center;gap:20px;flex-wrap:wrap}
        .avatar{width:72px;height:72px;border-radius:50%;background:var(--forest);display:flex;align-items:center;justify-content:center;font-size:1.8rem;color:#fff;flex-shrink:0}
        .profile-info strong{font-size:1rem;color:var(--text)}
        .profile-info span{font-size:0.82rem;color:var(--text-muted);display:block;margin-top:2px}
        .role-badge{display:inline-block;padding:3px 12px;border-radius:50px;font-size:0.72rem;font-weight:600;color:#fff;margin-top:6px}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:16px}
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
    <a href="Settings.aspx" class="nav-brand">Thrift<span>Hub</span></a>
    <div class="nav-links">
        <a href="javascript:history.back()">← Back</a>
    </div>
    <div class="nav-user">
        <span>⚙️ <asp:Literal ID="litName" runat="server"/></span>
        <a href="../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<form id="mainForm" runat="server">
<div class="page-wrap">

    <div class="page-header">
        <h1>Settings</h1>
        <p>Customise your ThriftHub experience</p>
    </div>

    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <%-- PROFILE --%>
    <div class="settings-card">
        <div class="card-header">
            <div class="icon">👤</div>
            <div><h2>Profile</h2><p>Your account information</p></div>
        </div>
        <div class="profile-row">
            <div class="avatar">
                <asp:Literal ID="litAvatar" runat="server">👤</asp:Literal>
            </div>
            <div class="profile-info">
                <strong><asp:Literal ID="litProfileName" runat="server"/></strong>
                <span><asp:Literal ID="litProfileEmail" runat="server"/></span>
                <asp:Literal ID="litProfileRole" runat="server"/>
            </div>
        </div>
    </div>

    <%-- APPEARANCE --%>
    <div class="settings-card">
        <div class="card-header">
            <div class="icon">🎨</div>
            <div><h2>Appearance</h2><p>Customise how ThriftHub looks</p></div>
        </div>

        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">🌙 Dark Mode</div>
                <div class="setting-desc">Switch between light and dark theme</div>
            </div>
            <label class="toggle">
                <input type="checkbox" id="toggleDark" onchange="applyDarkMode(this.checked)"/>
                <span class="slider"></span>
            </label>
        </div>

        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">🎨 Accent Colour</div>
                <div class="setting-desc">Choose your favourite highlight colour</div>
            </div>
            <div class="colour-options">
                <div class="colour-swatch active" data-colour="#2C4A3E" style="background:#2C4A3E" onclick="setAccent('#2C4A3E',this)" title="Forest"></div>
                <div class="colour-swatch" data-colour="#1A5276" style="background:#1A5276" onclick="setAccent('#1A5276',this)" title="Navy"></div>
                <div class="colour-swatch" data-colour="#6C3483" style="background:#6C3483" onclick="setAccent('#6C3483',this)" title="Purple"></div>
                <div class="colour-swatch" data-colour="#784212" style="background:#784212" onclick="setAccent('#784212',this)" title="Brown"></div>
                <div class="colour-swatch" data-colour="#1E8449" style="background:#1E8449" onclick="setAccent('#1E8449',this)" title="Green"></div>
                <div class="colour-swatch" data-colour="#C0392B" style="background:#C0392B" onclick="setAccent('#C0392B',this)" title="Red"></div>
            </div>
        </div>

        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">🔤 Font Size</div>
                <div class="setting-desc" id="fontSizeDesc">Current: Medium</div>
            </div>
            <select class="setting-select" id="fontSizeSelect" onchange="applyFontSize(this.value)">
                <option value="small">Small</option>
                <option value="medium" selected>Medium</option>
                <option value="large">Large</option>
                <option value="xlarge">Extra Large</option>
            </select>
        </div>

        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">📐 Compact Mode</div>
                <div class="setting-desc">Reduce spacing for more content on screen</div>
            </div>
            <label class="toggle">
                <input type="checkbox" id="toggleCompact" onchange="applyCompact(this.checked)"/>
                <span class="slider"></span>
            </label>
        </div>

        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">✨ Animations</div>
                <div class="setting-desc">Enable smooth transitions and hover effects</div>
            </div>
            <label class="toggle">
                <input type="checkbox" id="toggleAnimations" checked onchange="applyAnimations(this.checked)"/>
                <span class="slider"></span>
            </label>
        </div>
    </div>

    <%-- NOTIFICATIONS --%>
    <div class="settings-card">
        <div class="card-header">
            <div class="icon">🔔</div>
            <div><h2>Notifications</h2><p>Control what alerts you receive</p></div>
        </div>
        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">📦 Order Updates</div>
                <div class="setting-desc">Get notified when your order status changes</div>
            </div>
            <label class="toggle">
                <input type="checkbox" id="notifOrders" checked onchange="saveSetting('notif_orders',this.checked)"/>
                <span class="slider"></span>
            </label>
        </div>
        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">✅ Listing Approved</div>
                <div class="setting-desc">Get notified when your listing goes live</div>
            </div>
            <label class="toggle">
                <input type="checkbox" id="notifApproved" checked onchange="saveSetting('notif_approved',this.checked)"/>
                <span class="slider"></span>
            </label>
        </div>
        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">💰 Sales</div>
                <div class="setting-desc">Get notified when someone buys your item</div>
            </div>
            <label class="toggle">
                <input type="checkbox" id="notifSales" checked onchange="saveSetting('notif_sales',this.checked)"/>
                <span class="slider"></span>
            </label>
        </div>
        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">🎉 Promotions</div>
                <div class="setting-desc">Receive vouchers and special offers</div>
            </div>
            <label class="toggle">
                <input type="checkbox" id="notifPromos" onchange="saveSetting('notif_promos',this.checked)"/>
                <span class="slider"></span>
            </label>
        </div>
    </div>

    <%-- PRIVACY --%>
    <div class="settings-card">
        <div class="card-header">
            <div class="icon">🔒</div>
            <div><h2>Privacy</h2><p>Control your privacy preferences</p></div>
        </div>
        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">👁️ Show Profile to Buyers</div>
                <div class="setting-desc">Let buyers see your seller profile and reviews</div>
            </div>
            <label class="toggle">
                <input type="checkbox" id="privProfile" checked onchange="saveSetting('priv_profile',this.checked)"/>
                <span class="slider"></span>
            </label>
        </div>
        <div class="setting-row">
            <div class="setting-info">
                <div class="setting-label">📍 Show Location on Listings</div>
                <div class="setting-desc">Display your city on your item listings</div>
            </div>
            <label class="toggle">
                <input type="checkbox" id="privLocation" onchange="saveSetting('priv_location',this.checked)"/>
                <span class="slider"></span>
            </label>
        </div>
    </div>

    <%-- CHANGE PASSWORD --%>
    <div class="settings-card">
        <div class="card-header">
            <div class="icon">🔑</div>
            <div><h2>Change Password</h2><p>Keep your account secure</p></div>
        </div>
        <div class="pass-row">
            <div class="form-group">
                <label>Current Password</label>
                <asp:TextBox ID="txtCurrentPass" runat="server" TextMode="Password" placeholder="Enter your current password"/>
            </div>
            <div class="form-group">
                <label>New Password</label>
                <asp:TextBox ID="txtNewPass" runat="server" TextMode="Password" placeholder="At least 6 characters"/>
            </div>
            <div class="form-group">
                <label>Confirm New Password</label>
                <asp:TextBox ID="txtConfirmPass" runat="server" TextMode="Password" placeholder="Repeat new password"/>
            </div>
            <asp:Button ID="btnChangePass" runat="server" Text="Update Password"
                CssClass="btn-save" OnClick="BtnChangePass_Click" CausesValidation="false"/>
        </div>
    </div>

    <%-- DANGER ZONE --%>
    <div class="settings-card">
        <div class="card-header">
            <div class="icon">⚠️</div>
            <div><h2>Danger Zone</h2><p>Irreversible account actions</p></div>
        </div>
        <div class="danger-row">
            <div class="setting-info">
                <div class="setting-label">Clear Basket</div>
                <div class="setting-desc">Remove all items from your basket</div>
            </div>
            <asp:Button ID="btnClearBasket" runat="server" Text="Clear Basket"
                CssClass="btn-danger" OnClick="BtnClearBasket_Click"
                OnClientClick="return confirm('Clear all items from your basket?');"
                CausesValidation="false"/>
        </div>
        <div class="danger-row" style="border-top:1px solid var(--card-border)">
            <div class="setting-info">
                <div class="setting-label" style="color:var(--error)">Deactivate Account</div>
                <div class="setting-desc">Temporarily disable your account</div>
            </div>
            <asp:Button ID="btnDeactivate" runat="server" Text="Deactivate"
                CssClass="btn-danger" OnClick="BtnDeactivate_Click"
                OnClientClick="return confirm('Deactivate your account?');"
                CausesValidation="false"/>
        </div>
    </div>

</div>
</form>

<script type="text/javascript">

    // Restore all saved settings when page loads
    window.addEventListener('load', function () {

        // Dark mode
        var dark = localStorage.getItem('thrift_darkmode') === 'true';
        document.getElementById('toggleDark').checked = dark;
        if (dark) document.body.classList.add('dark-mode');

        // Accent colour
        var accent = localStorage.getItem('thrift_accent') || '#2C4A3E';
        applyAccentColour(accent);
        document.querySelectorAll('.colour-swatch').forEach(function (s) {
            s.classList.toggle('active', s.dataset.colour === accent);
        });

        // Font size
        var fontSize = localStorage.getItem('thrift_fontsize') || 'medium';
        document.getElementById('fontSizeSelect').value = fontSize;
        applyFontSize(fontSize);

        // Compact
        var compact = localStorage.getItem('thrift_compact') === 'true';
        document.getElementById('toggleCompact').checked = compact;
        if (compact) applyCompact(true);

        // Animations
        var anim = localStorage.getItem('thrift_animations') !== 'false';
        document.getElementById('toggleAnimations').checked = anim;
        if (!anim) applyAnimations(false);

        // Notification and privacy toggles
        restoreToggle('notifOrders', 'notif_orders', true);
        restoreToggle('notifApproved', 'notif_approved', true);
        restoreToggle('notifSales', 'notif_sales', true);
        restoreToggle('notifPromos', 'notif_promos', false);
        restoreToggle('privProfile', 'priv_profile', true);
        restoreToggle('privLocation', 'priv_location', false);
    });

    function restoreToggle(elementID, storageKey, defaultVal) {
        var stored = localStorage.getItem('thrift_' + storageKey);
        var val = stored !== null ? stored === 'true' : defaultVal;
        var el = document.getElementById(elementID);
        if (el) el.checked = val;
    }

    function applyDarkMode(enabled) {
        if (enabled) document.body.classList.add('dark-mode');
        else document.body.classList.remove('dark-mode');
        localStorage.setItem('thrift_darkmode', enabled);
        showToast('Theme updated!');
    }

    function setAccent(colour, el) {
        document.querySelectorAll('.colour-swatch').forEach(function (s) { s.classList.remove('active'); });
        el.classList.add('active');
        applyAccentColour(colour);
        localStorage.setItem('thrift_accent', colour);
        showToast('Accent colour updated!');
    }

    function applyAccentColour(colour) {
        document.documentElement.style.setProperty('--forest', colour);
    }

    function applyFontSize(size) {
        var sizes = { small: '13px', medium: '15px', large: '17px', xlarge: '19px' };
        var labels = { small: 'Small', medium: 'Medium', large: 'Large', xlarge: 'Extra Large' };
        document.body.style.fontSize = sizes[size] || '15px';
        var desc = document.getElementById('fontSizeDesc');
        if (desc) desc.textContent = 'Current: ' + (labels[size] || 'Medium');
        localStorage.setItem('thrift_fontsize', size);
    }

    function applyCompact(enabled) {
        document.querySelectorAll('.setting-row, .danger-row').forEach(function (r) {
            r.style.padding = enabled ? '10px 28px' : '18px 28px';
        });
        localStorage.setItem('thrift_compact', enabled);
        showToast('Compact mode ' + (enabled ? 'on' : 'off') + '!');
    }

    function applyAnimations(enabled) {
        var existing = document.getElementById('no-anim');
        if (!enabled && !existing) {
            var s = document.createElement('style');
            s.id = 'no-anim';
            s.textContent = '*{transition:none !important;animation:none !important}';
            document.head.appendChild(s);
        } else if (enabled && existing) {
            existing.remove();
        }
        localStorage.setItem('thrift_animations', enabled);
        showToast('Animations ' + (enabled ? 'enabled' : 'disabled') + '!');
    }

    function saveSetting(key, value) {
        localStorage.setItem('thrift_' + key, value);
        showToast('Setting saved!');
    }

    function showToast(msg) {
        var old = document.getElementById('sToast');
        if (old) old.remove();
        var t = document.createElement('div');
        t.id = 'sToast';
        t.textContent = '✅ ' + msg;
        t.style.cssText = 'position:fixed;bottom:24px;right:24px;background:#2C4A3E;color:#fff;padding:14px 24px;border-radius:12px;font-size:0.9rem;box-shadow:0 4px 20px rgba(0,0,0,0.15);z-index:9999;font-family:DM Sans,sans-serif';
        document.body.appendChild(t);
        setTimeout(function () { t.style.opacity = '0'; t.style.transition = 'opacity 0.3s'; setTimeout(function () { t.remove(); }, 300); }, 2500);
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
                <li><a href="Settings.aspx"               runat="server">Home</a></li>
                <li><a href="~../Logout.aspx"                 runat="server">Logout</a></li>
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