<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SetPassword.aspx.cs" Inherits="ThriftHub.SetPassword" %>
<!DOCTYPE html>
<html>
<head>
    <title>Set Password – Dev Only</title>
    <style>
        body  { font-family: sans-serif; max-width: 420px; margin: 60px auto; padding: 20px; }
        h2    { color: #2C4A3E; margin-bottom: 6px; }
        label { font-size: 0.85rem; font-weight: 600; color: #333; display: block; margin-top: 14px; margin-bottom: 4px; }
        input { width: 100%; padding: 10px 14px; border: 1.5px solid #DDD8CE; border-radius: 8px; font-size: 0.95rem; box-sizing: border-box; }
        input:focus { outline: none; border-color: #2C4A3E; }
        button, .btn { width: 100%; padding: 13px; background: #2C4A3E; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 1rem; margin-top: 18px; }
        button:hover { background: #1E3329; }
        .msg    { padding: 12px 16px; border-radius: 8px; margin-top: 14px; font-size: 0.88rem; }
        .ok     { background: #E9F7EF; color: #27AE60; border: 1px solid #A9DFBF; }
        .err    { background: #FDECEA; color: #C0392B; border: 1px solid #F5C6C2; }
        .warn   { background: #FEF3E2; color: #E67E22; border: 1px solid #FAD7A0; font-size: 0.82rem; padding: 10px 14px; border-radius: 8px; margin-bottom: 16px; }
    </style>
</head>
<body>

    <h2>🔧 Set Password</h2>
    <div class="warn">⚠️ This page is for development only. Delete it after use!</div>

    <form id="mainForm" runat="server">

        <label>Email Address</label>
        <asp:TextBox ID="txtEmail" runat="server" placeholder="e.g. admin@thrifthub.co.za" />

        <label>New Password</label>
        <asp:TextBox ID="txtPassword" runat="server" placeholder="e.g. Admin@123" />

        <asp:Button ID="btnSet" runat="server" Text="Set Password" OnClick="BtnSet_Click" />

        <asp:Literal ID="litMsg" runat="server"></asp:Literal>

    </form>

</body>
</html>
