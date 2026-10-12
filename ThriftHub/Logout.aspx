<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="ThriftHub.Logout" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Signing Out – ThriftHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;--charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;--border:#DDD8CE}
        body{font-family:'DM Sans',sans-serif;background:var(--cream);min-height:100vh;display:flex;align-items:center;justify-content:center}
        .card{background:var(--white);border-radius:24px;padding:60px 50px;text-align:center;max-width:440px;width:100%;box-shadow:0 8px 40px rgba(0,0,0,0.08)}
        .logo{font-family:'Playfair Display',serif;font-size:2.2rem;color:var(--forest);margin-bottom:6px}
        .logo span{color:var(--gold)}
        .icon{font-size:3.5rem;margin:24px 0 16px}
        h2{font-family:'Playfair Display',serif;font-size:1.5rem;color:var(--charcoal);margin-bottom:10px}
        p{color:var(--muted);font-size:0.92rem;line-height:1.7;margin-bottom:32px}
        .btn-group{display:flex;flex-direction:column;gap:12px}
        .btn{display:block;padding:14px 28px;border-radius:12px;text-decoration:none;font-weight:500;font-size:0.95rem;transition:transform 0.15s,background 0.2s;text-align:center}
        .btn:hover{transform:translateY(-2px)}
        .btn-primary{background:var(--forest);color:var(--white)}
        .btn-primary:hover{background:#1E3329}
        .btn-outline{border:2px solid var(--forest);color:var(--forest);background:transparent}
        .btn-outline:hover{background:#EFF5F3}
        .divider{display:flex;align-items:center;gap:12px;margin:8px 0}
        .divider::before,.divider::after{content:'';flex:1;height:1px;background:var(--border)}
        .divider span{color:var(--muted);font-size:0.78rem}
        .countdown{font-size:0.82rem;color:var(--muted);margin-top:20px}
        .countdown strong{color:var(--forest)}
    </style>
</head>
<body>
<div class="card">
    <div class="logo">Thrift<span>Hub</span></div>
    <div class="icon">🤭</div>
    <h2>You've been signed out</h2>
    <p>Thank you for using ThriftHub. Your session has been ended safely.</p>

    <div class="btn-group">
        <a href="Register.aspx" class="btn btn-primary">Create an Account</a>
        <div class="divider"><span>or</span></div>
        <a href="Login.aspx" class="btn btn-outline">Sign Back In</a>
    </div>

    <div class="countdown">
        Redirecting to Register in <strong id="timer">0</strong> seconds...
    </div>
</div>

<script type="text/javascript">
    // Countdown timer — redirects to Register.aspx after 5 seconds
    var seconds = 3;
    var timerEl = document.getElementById('timer');

    var countdown = setInterval(function () {
        seconds--;
        timerEl.textContent = seconds;
        if (seconds <= 0) {
            clearInterval(countdown);
            window.location.href = 'Register.aspx';
        }
    }, 1000);
</script>
</body>
</html>
