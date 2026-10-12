<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="ThriftHub.Register" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Register – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet" />
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --cream: #F5F0E8; --forest: #2C4A3E; --gold: #D4A853;
            --charcoal: #1A1A1A; --muted: #7A7A6E; --white: #FFFFFF;
            --border: #DDD8CE; --error: #C0392B; --success: #27AE60;
        }
        body { font-family: 'DM Sans', sans-serif; background-color: var(--cream); min-height: 100vh; display: flex; align-items: stretch; }

        /* ── Left panel ── */
        .panel-left { width: 420px; min-width: 420px; background-color: var(--forest); display: flex; flex-direction: column; justify-content: space-between; padding: 60px 50px; position: relative; overflow: hidden; }
        .panel-left::before { content: ''; position: absolute; top: -80px; right: -80px; width: 300px; height: 300px; border-radius: 50%; background: rgba(212,168,83,0.12); }
        .panel-left::after  { content: ''; position: absolute; bottom: -60px; left: -60px; width: 250px; height: 250px; border-radius: 50%; background: rgba(200,92,58,0.10); }
        .brand { position: relative; z-index: 1; }
        .brand-logo { font-family: 'Playfair Display', serif; font-size: 2.2rem; color: var(--white); letter-spacing: -0.5px; }
        .brand-logo span { color: var(--gold); }
        .brand-tagline { color: rgba(255,255,255,0.55); font-size: 0.85rem; margin-top: 8px; font-weight: 300; letter-spacing: 1px; text-transform: uppercase; }
        .panel-middle { position: relative; z-index: 1; }
        .panel-middle h2 { font-family: 'Playfair Display', serif; color: var(--white); font-size: 1.9rem; line-height: 1.3; margin-bottom: 16px; }
        .panel-middle p { color: rgba(255,255,255,0.6); font-size: 0.92rem; line-height: 1.7; }
        .sdg-badge { position: relative; z-index: 1; display: inline-flex; align-items: center; gap: 10px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 50px; padding: 10px 18px; }
        .sdg-badge .dot { width: 10px; height: 10px; border-radius: 50%; background: var(--gold); }
        .sdg-badge span { color: rgba(255,255,255,0.7); font-size: 0.78rem; letter-spacing: 0.5px; }

        /* ── Right panel ── */
        .panel-right { flex: 1; display: flex; align-items: center; justify-content: center; padding: 60px 40px; }
        .form-container { width: 100%; max-width: 520px; }
        .form-header { margin-bottom: 36px; }
        .form-header h1 { font-family: 'Playfair Display', serif; font-size: 2rem; color: var(--charcoal); margin-bottom: 8px; }
        .form-header p { color: var(--muted); font-size: 0.9rem; }
        .form-header p a { color: var(--forest); font-weight: 500; text-decoration: none; }
        .form-header p a:hover { text-decoration: underline; }

        /* Role selector */
        .role-selector { display: flex; gap: 12px; margin-bottom: 28px; }
        .role-option { flex: 1; text-align: center; padding: 14px 10px; border: 2px solid var(--border); border-radius: 12px; cursor: pointer; transition: all 0.2s; background: var(--white); position: relative; }
        .role-option input[type=radio] { position: absolute; opacity: 0; width: 0; }
        .role-option .icon { font-size: 1.4rem; display: block; margin-bottom: 4px; }
        .role-option .label { font-size: 0.82rem; font-weight: 500; color: var(--muted); }
        .role-option:has(input:checked) { border-color: var(--forest); background: #EFF5F3; }
        .role-option:has(input:checked) .label { color: var(--forest); }

        /* Form fields */
        .form-row { display: flex; gap: 16px; margin-bottom: 18px; }
        .form-group { flex: 1; display: flex; flex-direction: column; margin-bottom: 18px; }
        .form-row .form-group { margin-bottom: 0; }
        label { font-size: 0.82rem; font-weight: 500; color: var(--charcoal); margin-bottom: 7px; letter-spacing: 0.3px; }
        .input-wrap { position: relative; }
        .input-wrap input, .input-wrap select { width: 100%; padding: 12px 16px; border: 1.5px solid var(--border); border-radius: 10px; font-family: 'DM Sans', sans-serif; font-size: 0.93rem; color: var(--charcoal); background: var(--white); transition: border-color 0.2s, box-shadow 0.2s; appearance: none; }
        .input-wrap input:focus, .input-wrap select:focus { outline: none; border-color: var(--forest); box-shadow: 0 0 0 3px rgba(44,74,62,0.08); }
        .input-wrap .toggle-pw { position: absolute; right: 14px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: var(--muted); font-size: 0.9rem; padding: 0; }
        .field-error { color: var(--error); font-size: 0.78rem; margin-top: 5px; }
        .strength-bar { height: 3px; background: var(--border); border-radius: 4px; margin-top: 7px; overflow: hidden; }
        .strength-fill { height: 100%; width: 0%; border-radius: 4px; transition: width 0.3s, background 0.3s; }
        .server-message { padding: 12px 16px; border-radius: 10px; font-size: 0.88rem; margin-bottom: 20px; }
        .server-message.error   { background: #FDECEA; color: var(--error);   border: 1px solid #F5C6C2; }
        .server-message.success { background: #E9F7EF; color: var(--success); border: 1px solid #A9DFBF; }

        /* ===== TERMS & CONDITIONS BOX ===== */
        .terms-box {
            background: var(--white);
            border: 1.5px solid var(--border);
            border-radius: 14px;
            padding: 20px;
            margin-bottom: 20px;
            transition: border-color 0.2s;
        }

        .terms-box.terms-error {
            border-color: var(--error);
            background: #FFFBFB;
        }

        .terms-box-title {
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--muted);
            margin-bottom: 12px;
        }

        .terms-scroll {
            background: var(--cream);
            border-radius: 8px;
            padding: 14px 16px;
            font-size: 0.78rem;
            color: var(--muted);
            line-height: 1.7;
            max-height: 100px;
            overflow-y: auto;
            margin-bottom: 16px;
            border: 1px solid var(--border);
        }

        .terms-scroll::-webkit-scrollbar { width: 4px; }
        .terms-scroll::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }

        /* The checkbox row */
        .terms-check-row {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            cursor: pointer;
        }

        /* Hide the default ASP.NET checkbox but keep it functional */
        .terms-check-row input[type="checkbox"] {
            display: none;
        }

        /* Custom styled checkbox */
        .custom-checkbox {
            width: 20px;
            height: 20px;
            min-width: 20px;
            border: 2px solid var(--border);
            border-radius: 5px;
            background: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            margin-top: 1px;
            cursor: pointer;
        }

        .custom-checkbox .check-icon {
            color: var(--white);
            font-size: 0.75rem;
            display: none;
        }

        /* Checked state — driven by JS */
        .custom-checkbox.checked {
            background: var(--forest);
            border-color: var(--forest);
        }

        .custom-checkbox.checked .check-icon { display: block; }

        .terms-check-label {
            font-size: 0.85rem;
            color: var(--charcoal);
            line-height: 1.55;
            cursor: pointer;
        }

        .terms-check-label a {
            color: var(--forest);
            font-weight: 600;
            text-decoration: none;
        }

        .terms-check-label a:hover { text-decoration: underline; }

        .terms-error-msg {
            color: var(--error);
            font-size: 0.78rem;
            margin-top: 10px;
            display: none;
            align-items: center;
            gap: 5px;
        }

        .terms-error-msg.visible { display: flex; }
        /* ===================================== */

        .btn-submit { width: 100%; padding: 15px; background: var(--forest); color: var(--white); border: none; border-radius: 12px; font-family: 'DM Sans', sans-serif; font-size: 0.97rem; font-weight: 500; cursor: pointer; letter-spacing: 0.3px; transition: background 0.2s, transform 0.15s; margin-top: 4px; }
        .btn-submit:hover { background: #1E3329; transform: translateY(-1px); }
        .btn-submit:disabled { background: #ccc; cursor: not-allowed; transform: none; }
        .divider { text-align: center; color: var(--muted); font-size: 0.8rem; margin: 10px 0 18px; position: relative; }
        .divider::before, .divider::after { content: ''; position: absolute; top: 50%; width: 42%; height: 1px; background: var(--border); }
        .divider::before { left: 0; } .divider::after { right: 0; }

        @media (max-width: 860px) { .panel-left { display: none; } }
    </style>
</head>
<body>

<div class="panel-left">
    <div class="brand">
        <div class="brand-logo">Thrift<span>Hub</span></div>
        <div class="brand-tagline">Pre-owned. Loved again.</div>
    </div>
    <div class="panel-middle">
        <h2>Give clothes a second chance</h2>
        <p>Join a community of conscious shoppers and sellers. Buy affordable, sell sustainably, track every order.</p>
    </div>
    <div class="sdg-badge">
        <div class="dot"></div>
        <span>Supporting UN SDG 12 – Responsible Consumption</span>
    </div>
</div>

<div class="panel-right">
    <div class="form-container">
        <div class="form-header">
            <h1>Create account</h1>
            <p>Already have an account? <a href="Login.aspx">Sign in</a></p>
        </div>

        <form id="registerForm" runat="server">
            <asp:Literal ID="litMessage" runat="server"></asp:Literal>

            <%-- Role selector --%>
            <div class="role-selector">
                <label class="role-option">
                    <asp:RadioButton ID="rbBuyer" runat="server" GroupName="Role" Checked="true" />
                    <span class="label">🛍️ Buyer</span>
                </label>
                <label class="role-option">
                    <asp:RadioButton ID="rbSeller" runat="server" GroupName="Role" />
                    <span class="label">🏪 Seller</span>
                </label>
            </div>

            <%-- Full Name --%>
            <div class="form-group">
                <label>Full Name</label>
                <div class="input-wrap">
                    <asp:TextBox ID="txtFullName" runat="server" placeholder="e.g. Sipho Dlamini" />
                </div>
                <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName"
                    ErrorMessage="Full name is required." CssClass="field-error" Display="Dynamic" />
            </div>

            <%-- Email & Phone --%>
            <div class="form-row">
                <div class="form-group">
                    <label>Email Address</label>
                    <div class="input-wrap">
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="you@email.com" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                        ErrorMessage="Email is required." CssClass="field-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                        ErrorMessage="Enter a valid email." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="form-group">
                    <label>Phone Number</label>
                    <div class="input-wrap">
                        <asp:TextBox ID="txtPhone" runat="server" placeholder="e.g. 0821234567" />
                    </div>
                    <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone"
                        ValidationExpression="^[0-9]{10}$"
                        ErrorMessage="10-digit number required." CssClass="field-error" Display="Dynamic" />
                </div>
            </div>

            <%-- Password --%>
            <div class="form-group">
                <label>Password</label>
                <div class="input-wrap">
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Min. 8 characters" />
                    <button type="button" class="toggle-pw" onclick="togglePw('pw', this)">👁</button>
                </div>
                <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                    ErrorMessage="Password is required." CssClass="field-error" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword"
                    ValidationExpression="^.{8,}$" ErrorMessage="Minimum 8 characters." CssClass="field-error" Display="Dynamic" />
            </div>

            <%-- Confirm Password --%>
            <div class="form-group">
                <label>Confirm Password</label>
                <div class="input-wrap">
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" placeholder="Repeat password" />
                    <button type="button" class="toggle-pw" onclick="togglePw('cpw', this)">👁</button>
                </div>
                <asp:RequiredFieldValidator ID="rfvConfirm" runat="server" ControlToValidate="txtConfirmPassword"
                    ErrorMessage="Please confirm your password." CssClass="field-error" Display="Dynamic" />
                <asp:CompareValidator ID="cvPassword" runat="server" ControlToValidate="txtConfirmPassword"
                    ControlToCompare="txtPassword" ErrorMessage="Passwords do not match."
                    CssClass="field-error" Display="Dynamic" />
            </div>

            <div class="divider">Address (optional)</div>

            <div class="form-group">
                <label>Street Address</label>
                <div class="input-wrap">
                    <asp:TextBox ID="txtAddress1" runat="server" placeholder="e.g. 12 Main Street" />
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>City</label>
                    <div class="input-wrap">
                        <asp:TextBox ID="txtCity" runat="server" placeholder="e.g. Cape Town" />
                    </div>
                </div>
                <div class="form-group">
                    <label>Province</label>
                    <div class="input-wrap">
                        <asp:DropDownList ID="ddlProvince" runat="server">
                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                            <asp:ListItem>Eastern Cape</asp:ListItem>
                            <asp:ListItem>Free State</asp:ListItem>
                            <asp:ListItem>Gauteng</asp:ListItem>
                            <asp:ListItem>KwaZulu-Natal</asp:ListItem>
                            <asp:ListItem>Limpopo</asp:ListItem>
                            <asp:ListItem>Mpumalanga</asp:ListItem>
                            <asp:ListItem>North West</asp:ListItem>
                            <asp:ListItem>Northern Cape</asp:ListItem>
                            <asp:ListItem>Western Cape</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="form-group">
                    <label>Postal Code</label>
                    <div class="input-wrap">
                        <asp:TextBox ID="txtPostal" runat="server" placeholder="e.g. 8001" />
                    </div>
                </div>
            </div>

            <%-- ===== TERMS & CONDITIONS ===== --%>
            <div class="terms-box" id="termsBox">
                <div class="terms-box-title">📋 Terms &amp; Conditions</div>

                <%-- Scrollable T&C summary --%>
                <div class="terms-scroll">
                    By creating a ThriftHub account you agree to the following:
                    <br/><br/>
                    <strong>1. Eligibility:</strong> You must be 18 years or older to register and use ThriftHub.
                    <br/><br/>
                    <strong>2. Listings:</strong> Sellers are responsible for accurate descriptions. Misleading listings may result in account suspension.
                    <br/><br/>
                    <strong>3. Transactions:</strong> ThriftHub facilitates transactions between buyers and sellers. All sales are final unless the item significantly differs from its description.
                    <br/><br/>
                    <strong>4. Privacy:</strong> Your personal data is handled in accordance with our Privacy Policy and POPIA regulations.
                    <br/><br/>
                    <strong>5. Conduct:</strong> Any abusive, fraudulent, or dishonest behaviour will result in immediate account suspension or ban.
                    <br/><br/>
                    <strong>6. Commission:</strong> ThriftHub charges a 5% commission on completed sales. Sellers agree to this fee upon listing.
                </div>

                <%-- Custom checkbox row --%>
                <div class="terms-check-row" onclick="toggleTerms()" id="termsCheckRow">
                    <%-- Hidden ASP.NET CheckBox — its value is what the server reads --%>
                    <asp:CheckBox ID="chkTerms" runat="server" style="display:none;" />
                    <%-- Custom visual checkbox --%>
                    <div class="custom-checkbox" id="customCheck">
                        <span class="check-icon">✓</span>
                    </div>
                    <span class="terms-check-label">
                        I have read and agree to the
                        <a href="#" onclick="return false;">Terms &amp; Conditions</a>
                        and
                        <a href="#" onclick="return false;">Privacy Policy</a>.
                        I confirm I am 18 years or older.
                    </span>
                </div>

                <%-- Client-side error message --%>
                <div class="terms-error-msg" id="termsErrMsg">
                    ⚠️ You must agree to the Terms &amp; Conditions to register.
                </div>
            </div>
            <%-- ================================ --%>

            <asp:Button ID="btnRegister" runat="server" Text="Create My Account"
                CssClass="btn-submit" OnClick="BtnRegister_Click"
                OnClientClick="return validateTerms();" />

        </form>
    </div>
</div>

<script>
    // ── Password toggle ──
    function togglePw(field, btn) {
        var input = field === 'pw'
            ? document.getElementById('<%= txtPassword.ClientID %>')
            : document.getElementById('<%= txtConfirmPassword.ClientID %>');
        input.type = input.type === 'password' ? 'text' : 'password';
        btn.textContent = input.type === 'password' ? '👁' : '🔒';
    }

    // ── Password strength ──
    var pwInput = document.getElementById('<%= txtPassword.ClientID %>');
    var fill = document.getElementById('strengthFill');
    pwInput.addEventListener('input', function () {
        var val = this.value, score = 0;
        if (val.length >= 8) score++;
        if (/[A-Z]/.test(val)) score++;
        if (/[0-9]/.test(val)) score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;
        var colors = ['#E74C3C', '#E67E22', '#F1C40F', '#27AE60'];
        var widths = ['25%', '50%', '75%', '100%'];
        fill.style.width = score > 0 ? widths[score - 1] : '0%';
        fill.style.background = score > 0 ? colors[score - 1] : 'transparent';
    });

    // ── Terms checkbox toggle ──
    // Syncs the custom visual checkbox with the hidden ASP.NET CheckBox
    var chkTerms = document.getElementById('<%= chkTerms.ClientID %>');
    var customChk = document.getElementById('customCheck');
    var termsBox = document.getElementById('termsBox');
    var termsErr = document.getElementById('termsErrMsg');

    function toggleTerms() {
        // Toggle the real checkbox
        chkTerms.checked = !chkTerms.checked;
        // Update visual
        customChk.classList.toggle('checked', chkTerms.checked);
        // Clear error state when user checks it
        if (chkTerms.checked) {
            termsBox.classList.remove('terms-error');
            termsErr.classList.remove('visible');
        }
    }

    // ── Client-side guard before form submits ──
    function validateTerms() {
        if (!chkTerms.checked) {
            termsBox.classList.add('terms-error');
            termsErr.classList.add('visible');
            termsBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
            return false;  // stops the postback
        }
        return true;  // allows the postback
    }
</script>

</body>
</html>
