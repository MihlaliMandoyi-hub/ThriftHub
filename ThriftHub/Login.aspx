<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ThriftHub.Login" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sign In – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet" />
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --cream: #F5F0E8;
            --forest: #2C4A3E;
            --rust: #C85C3A;
            --gold: #D4A853;
            --charcoal: #1A1A1A;
            --muted: #7A7A6E;
            --white: #FFFFFF;
            --border: #DDD8CE;
            --error: #C0392B;
            --success: #27AE60;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background-color: var(--cream);
            min-height: 100vh;
            display: flex;
            align-items: stretch;
        }

        /* Left panel */
        .panel-left {
            width: 420px;
            min-width: 420px;
            background-color: var(--forest);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 60px 50px;
            position: relative;
            overflow: hidden;
        }

        .panel-left::before {
            content: '';
            position: absolute;
            top: -80px; right: -80px;
            width: 300px; height: 300px;
            border-radius: 50%;
            background: rgba(212,168,83,0.12);
        }

        .panel-left::after {
            content: '';
            position: absolute;
            bottom: -60px; left: -60px;
            width: 250px; height: 250px;
            border-radius: 50%;
            background: rgba(200,92,58,0.10);
        }

        .brand { position: relative; z-index: 1; }

        .brand-logo {
            font-family: 'Playfair Display', serif;
            font-size: 2.2rem;
            color: var(--white);
            letter-spacing: -0.5px;
        }

        .brand-logo span { color: var(--gold); }

        .brand-tagline {
            color: rgba(255,255,255,0.55);
            font-size: 0.85rem;
            margin-top: 8px;
            font-weight: 300;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .panel-middle { position: relative; z-index: 1; }

        .panel-middle h2 {
            font-family: 'Playfair Display', serif;
            color: var(--white);
            font-size: 1.9rem;
            line-height: 1.3;
            margin-bottom: 16px;
        }

        .panel-middle p {
            color: rgba(255,255,255,0.6);
            font-size: 0.92rem;
            line-height: 1.7;
        }

        .sdg-badge {
            position: relative; z-index: 1;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 50px;
            padding: 10px 18px;
        }

        .sdg-badge .dot {
            width: 10px; height: 10px;
            border-radius: 50%;
            background: var(--gold);
        }

        .sdg-badge span {
            color: rgba(255,255,255,0.7);
            font-size: 0.78rem;
            letter-spacing: 0.5px;
        }

        /* Right panel */
        .panel-right {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 40px;
        }

        .form-container {
            width: 100%;
            max-width: 440px;
        }

        .form-header { margin-bottom: 36px; }

        .form-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2rem;
            color: var(--charcoal);
            margin-bottom: 8px;
        }

        .form-header p {
            color: var(--muted);
            font-size: 0.9rem;
        }

        .form-header p a {
            color: var(--forest);
            font-weight: 500;
            text-decoration: none;
        }

        .form-header p a:hover { text-decoration: underline; }

        .form-group {
            display: flex;
            flex-direction: column;
            margin-bottom: 20px;
        }

        label {
            font-size: 0.82rem;
            font-weight: 500;
            color: var(--charcoal);
            margin-bottom: 7px;
            letter-spacing: 0.3px;
        }

        .input-wrap { position: relative; }

        .input-wrap input {
            width: 100%;
            padding: 13px 16px;
            border: 1.5px solid var(--border);
            border-radius: 10px;
            font-family: 'DM Sans', sans-serif;
            font-size: 0.93rem;
            color: var(--charcoal);
            background: var(--white);
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .input-wrap input:focus {
            outline: none;
            border-color: var(--forest);
            box-shadow: 0 0 0 3px rgba(44,74,62,0.08);
        }

        .input-wrap .toggle-pw {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: var(--muted);
            font-size: 0.9rem;
            padding: 0;
        }

        .forgot-link {
            text-align: right;
            margin-top: -12px;
            margin-bottom: 20px;
        }

        .forgot-link a {
            font-size: 0.82rem;
            color: var(--forest);
            text-decoration: none;
        }

        .forgot-link a:hover { text-decoration: underline; }

        .server-message {
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 0.88rem;
            margin-bottom: 20px;
        }

        .server-message.error {
            background: #FDECEA;
            color: var(--error);
            border: 1px solid #F5C6C2;
        }

        .server-message.success {
            background: #E9F7EF;
            color: var(--success);
            border: 1px solid #A9DFBF;
        }

        .field-error {
            color: var(--error);
            font-size: 0.78rem;
            margin-top: 5px;
        }

        .btn-submit {
            width: 100%;
            padding: 15px;
            background: var(--forest);
            color: var(--white);
            border: none;
            border-radius: 12px;
            font-family: 'DM Sans', sans-serif;
            font-size: 0.97rem;
            font-weight: 500;
            cursor: pointer;
            letter-spacing: 0.3px;
            transition: background 0.2s, transform 0.15s;
            margin-top: 4px;
        }

        .btn-submit:hover { background: #1E3329; transform: translateY(-1px); }
        .btn-submit:active { transform: translateY(0); }

        .divider {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 24px 0;
        }

        .divider::before, .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border);
        }

        .divider span {
            color: var(--muted);
            font-size: 0.78rem;
        }

        .register-cta {
            text-align: center;
            padding: 16px;
            background: var(--white);
            border: 1.5px solid var(--border);
            border-radius: 12px;
        }

        .register-cta p {
            font-size: 0.88rem;
            color: var(--muted);
        }

        .register-cta a {
            color: var(--forest);
            font-weight: 600;
            text-decoration: none;
        }

        .register-cta a:hover { text-decoration: underline; }

        @media (max-width: 860px) {
            .panel-left { display: none; }
        }
    </style>
</head>
<body>

<div class="panel-left">
    <div class="brand">
        <div class="brand-logo">Thrift<span>Hub</span></div>
        <div class="brand-tagline">Pre-owned. Loved again.</div>
    </div>
    <div class="panel-middle">
        <h2>Welcome back to ThriftHub</h2>
        <p>Sign in to browse listings, manage your items, or track your orders.</p>
    </div>
    <div class="sdg-badge">
        <div class="dot"></div>
        <span>Supporting UN SDG 12 – Responsible Consumption</span>
        <span>GROUP 6</span>
    </div>
</div>

<div class="panel-right">
    <div class="form-container">

        <div class="form-header">
            <h1>Sign in</h1>
            <p>New to ThriftHub? <a href="Register.aspx">Create an account</a></p>
        </div>

        <form id="loginForm" runat="server">

            <asp:Literal ID="litMessage" runat="server"></asp:Literal>

            <!-- Email -->
            <div class="form-group">
                <label for="txtEmail">Email Address</label>
                <div class="input-wrap">
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="you@email.com" />
                </div>
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ErrorMessage="Email is required."
                    CssClass="field-error"
                    Display="Dynamic" />
            </div>

            <!-- Password -->
            <div class="form-group">
                <label for="txtPassword">Password</label>
                <div class="input-wrap">
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Your password" />
                    <button type="button" class="toggle-pw" onclick="togglePw(this)">👁</button>
                </div>
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword"
                    ErrorMessage="Password is required."
                    CssClass="field-error"
                    Display="Dynamic" />
            </div>

            <!-- Forgot password -->
            <div class="forgot-link">
                <a href="#">Forgot your password?</a>
            </div>

            <!-- Submit -->
            <asp:Button ID="btnLogin" runat="server" Text="Sign In"
                CssClass="btn-submit" OnClick="BtnLogin_Click" />

            <div class="divider"><span>or</span></div>

            <div class="register-cta">
                <p>Don't have an account? <a href="Register.aspx">Register for free</a></p>
            </div>

        </form>
    </div>
</div>

<script>
    function togglePw(btn) {
        const input = document.getElementById('<%= txtPassword.ClientID %>');
        input.type = input.type === 'password' ? 'text' : 'password';
        btn.textContent = input.type === 'password' ? '👁' : '🔒';
    }
</script>

</body>
</html>