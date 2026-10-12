<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ThriftHub._Default" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>ThriftHub – Home</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet" />
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --cream: #F5F0E8; --forest: #2C4A3E; --gold: #D4A853;
            --charcoal: #1A1A1A; --muted: #7A7A6E; --white: #FFFFFF;
            --border: #DDD8CE; --error: #C0392B; --success: #27AE60;
        }
        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--cream);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
        }
        .card {
            background: var(--white);
            border-radius: 24px;
            padding: 60px 50px;
            text-align: center;
            max-width: 580px;
            width: 100%;
            box-shadow: 0 8px 40px rgba(0,0,0,0.08);
        }
        .logo {
            font-family: 'Playfair Display', serif;
            font-size: 2.8rem;
            color: var(--forest);
            margin-bottom: 6px;
        }
        .logo span { color: var(--gold); }
        .tagline {
            color: var(--muted);
            font-size: 0.88rem;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-bottom: 36px;
        }
        .welcome-box {
            background: #EFF5F3;
            border-radius: 14px;
            padding: 20px 24px;
            margin-bottom: 28px;
            text-align: left;
        }
        .welcome-box .hi {
            font-size: 1rem;
            color: var(--forest);
            font-weight: 500;
            margin-bottom: 6px;
        }
        .role-badge {
            display: inline-block;
            background: var(--forest);
            color: var(--white);
            font-size: 0.75rem;
            padding: 4px 14px;
            border-radius: 50px;
            margin-top: 4px;
        }
        .desc {
            color: var(--muted);
            font-size: 0.93rem;
            line-height: 1.7;
            margin-bottom: 32px;
        }
        .btn-group {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }
        .btn {
            display: inline-block;
            padding: 13px 28px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.92rem;
            transition: transform 0.15s, background 0.2s;
            cursor: pointer;
            border: none;
            font-family: 'DM Sans', sans-serif;
        }
        .btn:hover { transform: translateY(-2px); }
        .btn-primary   { background: var(--forest); color: var(--white); }
        .btn-primary:hover { background: #1E3329; }
        .btn-gold      { background: var(--gold); color: var(--charcoal); }
        .btn-gold:hover { background: #C49A45; }
        .btn-outline   { border: 2px solid var(--forest); color: var(--forest); background: transparent; }
        .btn-danger    { border: 2px solid var(--error); color: var(--error); background: transparent; }
        .btn-danger:hover { background: #FDECEA; }
        .nav-links {
            display: flex;
            gap: 16px;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid var(--border);
        }
        .nav-links a {
            color: var(--forest);
            font-size: 0.88rem;
            text-decoration: none;
            font-weight: 500;
            padding: 8px 16px;
            border-radius: 8px;
            transition: background 0.2s;
        }
        .nav-links a:hover { background: #EFF5F3; }
        .sdg-note {
            margin-top: 28px;
            font-size: 0.78rem;
            color: var(--muted);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .sdg-dot {
            width: 8px; height: 8px;
            border-radius: 50%;
            background: var(--gold);
            display: inline-block;
        }
    </style>
</head>
<body>
<div class="card">

    <div class="logo">Thrift<span>Hub</span></div>
    <div class="tagline">Pre-owned. Loved again.</div>

    <% if (Session["UserID"] != null) { %>

        <div class="welcome-box">
            <div class="hi">👋 Welcome back, <strong><%= Session["FullName"] %></strong>!</div>
            <div style="color:#7A7A6E; font-size:0.85rem;">You are signed in as:</div>
            <span class="role-badge"><%= Session["UserRole"] %></span>
        </div>

        <div class="btn-group">
            <!-- Buyer links -->
            <% if (Session["UserRole"].ToString() == "Buyer") { %>
                <a href="~/Pages/Buyer/Catalogue.aspx" class="btn btn-primary">Browse Catalogue</a>
                <a href="~/Pages/Buyer/Basket.aspx" class="btn btn-outline">My Basket</a>
            <% } %>

            <!-- Seller links -->
            <% if (Session["UserRole"].ToString() == "Seller") { %>
                <a href="~/Pages/Seller/Dashboard.aspx" class="btn btn-primary">Seller Dashboard</a>
                <a href="~/Pages/Seller/ListItem.aspx" class="btn btn-gold">+ List Item</a>
            <% } %>

            <!-- Moderator links -->
            <% if (Session["UserRole"].ToString() == "Moderator") { %>
                <a href="~/Pages/Moderator/PendingListings.aspx" class="btn btn-primary">Moderator Panel</a>
            <% } %>

            <!-- Admin links -->
            <% if (Session["UserRole"].ToString() == "Admin") { %>
                <a href="~/Pages/Admin/Dashboard.aspx" class="btn btn-primary">Admin Dashboard</a>
            <% } %>
        </div>

        <div class="btn-group">
            <a href="Logout.aspx" class="btn-logout">Sign Out</a>
        </div>

        <!-- Extra nav for all logged-in users -->
        <div class="nav-links">
            <% if (Session["UserRole"].ToString() != "Moderator" && Session["UserRole"].ToString() != "Admin") { %>
                <a href="~/Pages/Buyer/Catalogue.aspx">🛍️ Catalogue</a>
            <% } %>
            <% if (Session["UserRole"].ToString() == "Buyer") { %>
                <a href="~/Pages/Buyer/OrderTracking.aspx">📦 My Orders</a>
            <% } %>
            <% if (Session["UserRole"].ToString() == "Seller") { %>
                <a href="~/Pages/Seller/MyListings.aspx">📋 My Listings</a>
            <% } %>
        </div>

    <% } else { %>

        <p class="desc">
            A peer-to-peer marketplace for pre-owned clothing.<br/>
            Buy affordable, sell sustainably, track every order.
        </p>

        <div class="btn-group">
            <a href="Login.aspx" class="btn btn-primary">Sign In</a>
            <a href="Register.aspx" class="btn btn-outline">Register Free</a>
            <a href="Pages/Settings.aspx">⚙️ Settings</a>
        </div>

    <% } %>

    <div class="sdg-note">
        <span class="sdg-dot"></span>
        Supporting UN SDG 12 – Responsible Consumption & Production
    </div>

</div>
</body>
</html>