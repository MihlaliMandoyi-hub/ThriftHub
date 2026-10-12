<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="ThriftHub.Pages.Admin.Reports" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Reports – ThriftHub Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        :root{--cream:#F5F0E8;--forest:#2C4A3E;--gold:#D4A853;--charcoal:#1A1A1A;--muted:#7A7A6E;--white:#FFFFFF;--border:#DDD8CE;--error:#C0392B;--success:#27AE60}
        body{font-family:'DM Sans',sans-serif;background:var(--cream);min-height:100vh}
        nav{background:var(--charcoal);padding:0 40px;display:flex;align-items:center;justify-content:space-between;height:64px;position:sticky;top:0;z-index:100}
        .nav-brand{font-family:'Playfair Display',serif;font-size:1.5rem;color:var(--white);text-decoration:none}
        .nav-brand span{color:var(--gold)}
        .nav-links{display:flex;gap:8px}
        .nav-links a{color:rgba(255,255,255,0.75);text-decoration:none;padding:8px 16px;border-radius:8px;font-size:0.88rem}
        .nav-links a:hover,.nav-links a.active{background:rgba(255,255,255,0.12);color:var(--white)}
        .nav-user{display:flex;align-items:center;gap:12px}
        .nav-user span{color:rgba(255,255,255,0.7);font-size:0.85rem}
        .btn-logout{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:var(--white);padding:7px 16px;border-radius:8px;font-size:0.82rem;text-decoration:none}
        .page-wrap{max-width:1150px;margin:0 auto;padding:40px 24px}
        .page-header{margin-bottom:28px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:16px}
        .page-header h1{font-family:'Playfair Display',serif;font-size:1.8rem;color:var(--charcoal)}
        .page-header p{color:var(--muted);font-size:0.9rem;margin-top:4px}
        .filter-bar{background:var(--white);border-radius:16px;border:1px solid var(--border);padding:24px;margin-bottom:28px;display:flex;gap:16px;flex-wrap:wrap;align-items:flex-end}
        .filter-group{display:flex;flex-direction:column;gap:6px;flex:1;min-width:160px}
        .filter-group label{font-size:0.78rem;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px}
        .filter-group select,.filter-group input[type=date]{padding:10px 14px;border:1.5px solid var(--border);border-radius:9px;font-family:'DM Sans',sans-serif;font-size:0.88rem;color:var(--charcoal);background:var(--white)}
        .filter-group select:focus,.filter-group input:focus{outline:none;border-color:var(--forest)}
        .btn-generate{padding:11px 28px;background:var(--forest);color:var(--white);border:none;border-radius:10px;font-family:'DM Sans',sans-serif;font-weight:500;font-size:0.92rem;cursor:pointer;white-space:nowrap}
        .btn-generate:hover{background:#1E3329}
        .btn-export{padding:11px 24px;background:var(--gold);color:var(--charcoal);border:none;border-radius:10px;font-family:'DM Sans',sans-serif;font-weight:600;font-size:0.88rem;cursor:pointer;white-space:nowrap}
        .btn-export:hover{background:#C49A43}
        .stats-row{display:grid;grid-template-columns:repeat(auto-fill,minmax(175px,1fr));gap:16px;margin-bottom:28px}
        .stat-card{background:var(--white);border-radius:16px;border:1px solid var(--border);padding:22px;text-align:center}
        .stat-card .s-icon{font-size:1.8rem;margin-bottom:8px}
        .stat-card .s-value{font-family:'Playfair Display',serif;font-size:1.65rem;color:var(--charcoal);margin-bottom:4px}
        .stat-card .s-label{font-size:0.73rem;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px}
        .stat-card.hl .s-value{color:var(--forest)}
        .section-card{background:var(--white);border-radius:16px;border:1px solid var(--border);margin-bottom:24px;overflow:hidden}
        .section-head{padding:18px 24px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between}
        .section-head h2{font-size:1rem;font-weight:600;color:var(--charcoal)}
        .section-head span{font-size:0.82rem;color:var(--muted)}
        .grid-wrap{overflow-x:auto}
        .grid-wrap table{width:100%;border-collapse:collapse}
        .grid-wrap table th{padding:12px 18px;text-align:left;font-size:0.74rem;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px;background:#FAFAF8;border-bottom:1px solid var(--border);white-space:nowrap}
        .grid-wrap table td{padding:13px 18px;font-size:0.87rem;color:var(--charcoal);border-bottom:1px solid var(--border)}
        .grid-wrap table tr:last-child td{border-bottom:none}
        .grid-wrap table tr:hover td{background:#FAFAF8}
        .grid-wrap table tr.pager td{text-align:center;padding:10px;background:#FAFAF8}
        .grid-wrap table tr.pager td a,.grid-wrap table tr.pager td span{padding:5px 12px;border-radius:6px;font-size:0.82rem;text-decoration:none;color:var(--forest);border:1px solid var(--border);margin:0 3px;display:inline-block}
        .grid-wrap table tr.pager td span{background:var(--forest);color:var(--white);border-color:var(--forest)}
        .badge{display:inline-block;padding:4px 12px;border-radius:50px;font-size:0.72rem;font-weight:500}
        .b-green{background:#E9F7EF;color:#27AE60}
        .b-orange{background:#FEF3E2;color:#E67E22}
        .b-red{background:#FDECEA;color:#C0392B}
        .b-blue{background:#EBF5FB;color:#2980B9}
        .b-purple{background:#F4ECF7;color:#8E44AD}
        .bar-wrap{display:flex;align-items:center;gap:8px;min-width:110px}
        .bar-bg{flex:1;height:7px;background:#F0EBE0;border-radius:4px;overflow:hidden}
        .bar-fill{height:100%;background:var(--forest);border-radius:4px}
        .server-message{padding:12px 16px;border-radius:10px;font-size:0.88rem;margin-bottom:20px}
        .server-message.info{background:#EBF5FB;color:#2980B9;border:1px solid #AED6F1}
        @media print{nav,.filter-bar,.btn-export,.btn-generate{display:none!important}body{background:#fff}.page-wrap{padding:0

    </style>
</head>
<body>

<nav>
    <a href="Dashboard.aspx" class="nav-brand">Thrift<span>Hub</span></a>
    <div class="nav-links">
        <a href="Dashboard.aspx">Dashboard</a>
        <a href="ManageOrders.aspx">📦 Orders</a>
        <a href="Reports.aspx" class="active">📊 Reports</a>
        <a href="../Moderator/PendingListings.aspx">Pending Listings</a>
        <a href="../Settings.aspx">⚙️ Settings</a>
    </div>
    <div class="nav-user">
        <span>🛡️ <asp:Literal ID="litName" runat="server"/></span>
        <a href="../../Logout.aspx" class="btn-logout">Sign Out</a>
    </div>
</nav>

<form id="mainForm" runat="server">
<div class="page-wrap">

    <div class="page-header">
        <div>
            <h1>📊 Reports</h1>
            <p>Generate, view and export business reports</p>
        </div>
        <div style="display:flex;gap:10px;flex-wrap:wrap">
            <button type="button" class="btn-export" onclick="window.print()">🖨️ Print</button>
            <asp:Button ID="btnExportCSV" runat="server" Text="⬇️ Export CSV"
                CssClass="btn-export" OnClick="BtnExportCSV_Click" CausesValidation="false"/>
        </div>
    </div>

    <%-- FILTER BAR --%>
    <div class="filter-bar">
        <div class="filter-group">
            <label>Report Type</label>
            <asp:DropDownList ID="ddlReportType" runat="server">
                <asp:ListItem Value="overview"  Text="📈 Business Overview"/>
                <asp:ListItem Value="orders"    Text="📦 Orders"/>
                <asp:ListItem Value="revenue"   Text="💰 Revenue by Day"/>
                <asp:ListItem Value="sellers"   Text="🏪 Top Sellers"/>
                <asp:ListItem Value="listings"  Text="👗 Listings"/>
                <asp:ListItem Value="buyers"    Text="👥 Buyers"/>
                <asp:ListItem Value="reviews"   Text="⭐ Reviews"/>
            </asp:DropDownList>
        </div>
        <div class="filter-group">
            <label>Date From</label>
            <asp:TextBox ID="txtDateFrom" runat="server" TextMode="Date"/>
        </div>
        <div class="filter-group">
            <label>Date To</label>
            <asp:TextBox ID="txtDateTo" runat="server" TextMode="Date"/>
        </div>
        <asp:Button ID="btnGenerate" runat="server" Text="Generate Report"
            CssClass="btn-generate" OnClick="BtnGenerate_Click" CausesValidation="false"/>
    </div>

    <%-- PERIOD LABEL --%>
    <asp:Panel ID="pnlPeriod" runat="server" Visible="false">
        <div class="server-message info">
            <asp:Literal ID="litPeriodLabel" runat="server"/>
        </div>
    </asp:Panel>

    <%-- OVERVIEW STATS --%>
    <asp:Panel ID="pnlStats" runat="server" Visible="false">
        <div class="stats-row">
            <div class="stat-card">
                <div class="s-icon">📦</div>
                <div class="s-value"><asp:Literal ID="litStatOrders"   runat="server"/></div>
                <div class="s-label">Orders</div>
            </div>
            <div class="stat-card hl">
                <div class="s-icon">💰</div>
                <div class="s-value">R <asp:Literal ID="litStatRevenue" runat="server"/></div>
                <div class="s-label">Revenue</div>
            </div>
            <div class="stat-card">
                <div class="s-icon">🏦</div>
                <div class="s-value">R <asp:Literal ID="litStatComm"   runat="server"/></div>
                <div class="s-label">Commission (5%)</div>
            </div>
            <div class="stat-card">
                <div class="s-icon">👥</div>
                <div class="s-value"><asp:Literal ID="litStatUsers"    runat="server"/></div>
                <div class="s-label">New Users</div>
            </div>
            <div class="stat-card">
                <div class="s-icon">👗</div>
                <div class="s-value"><asp:Literal ID="litStatListings" runat="server"/></div>
                <div class="s-label">New Listings</div>
            </div>
            <div class="stat-card">
                <div class="s-icon">⭐</div>
                <div class="s-value"><asp:Literal ID="litStatRating"   runat="server"/></div>
                <div class="s-label">Avg Rating</div>
            </div>
        </div>
    </asp:Panel>

    <%-- ORDERS GRIDVIEW --%>
    <asp:Panel ID="pnlOrders" runat="server" Visible="false">
        <div class="section-card">
            <div class="section-head">
                <h2>📦 Orders</h2>
                <span><asp:Literal ID="litOrdersCount" runat="server"/></span>
            </div>
            <div class="grid-wrap">
                <asp:GridView ID="gvOrders" runat="server"
                    AutoGenerateColumns="false" GridLines="None"
                    AllowPaging="true" PageSize="15"
                    OnPageIndexChanging="gvOrders_PageIndexChanging"
                    PagerStyle-CssClass="pager">
                    <Columns>
                        <asp:BoundField    DataField="OrderID"       HeaderText="Order #"/>
                        <asp:BoundField    DataField="BuyerName"     HeaderText="Buyer"/>
                        <asp:BoundField    DataField="OrderDate"     HeaderText="Date"       DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate><%# StatusBadge(Eval("OrderStatus").ToString()) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField    DataField="PaymentMethod" HeaderText="Payment"/>
                        <asp:BoundField    DataField="FinalAmount"   HeaderText="Amount (R)" DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"/>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <%-- REVENUE GRIDVIEW --%>
    <asp:Panel ID="pnlRevenue" runat="server" Visible="false">
        <div class="section-card">
            <div class="section-head">
                <h2>💰 Revenue by Day</h2>
                <span><asp:Literal ID="litRevenueCount" runat="server"/></span>
            </div>
            <div class="grid-wrap">
                <asp:GridView ID="gvRevenue" runat="server"
                    AutoGenerateColumns="false" GridLines="None"
                    AllowPaging="true" PageSize="15"
                    OnPageIndexChanging="gvRevenue_PageIndexChanging"
                    PagerStyle-CssClass="pager">
                    <Columns>
                        <asp:BoundField    DataField="Day"        HeaderText="Date"          DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:BoundField    DataField="OrderCount" HeaderText="Orders"
                            ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"/>
                        <asp:BoundField    DataField="Revenue"    HeaderText="Revenue (R)"   DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"/>
                        <asp:BoundField    DataField="Commission" HeaderText="Commission (R)" DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"/>
                        <asp:TemplateField HeaderText="Chart">
                            <ItemTemplate>
                                <div class="bar-wrap">
                                    <div class="bar-bg">
                                        <div class="bar-fill" style='<%# "width:" + Eval("Pct") + "%" %>'></div>
                                    </div>
                                    <span style="font-size:0.75rem;color:var(--muted)"><%# Eval("Pct") %>%</span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <%-- TOP SELLERS GRIDVIEW --%>
    <asp:Panel ID="pnlSellers" runat="server" Visible="false">
        <div class="section-card">
            <div class="section-head">
                <h2>🏪 Top Sellers</h2>
                <span><asp:Literal ID="litSellersCount" runat="server"/></span>
            </div>
            <div class="grid-wrap">
                <asp:GridView ID="gvSellers" runat="server"
                    AutoGenerateColumns="false" GridLines="None"
                    AllowPaging="true" PageSize="15"
                    OnPageIndexChanging="gvSellers_PageIndexChanging"
                    PagerStyle-CssClass="pager">
                    <Columns>
                        <asp:TemplateField HeaderText="#">
                            <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="FullName"      HeaderText="Seller"/>
                        <asp:BoundField DataField="Email"         HeaderText="Email"/>
                        <asp:BoundField DataField="TotalListings" HeaderText="Listings"
                            ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"/>
                        <asp:BoundField DataField="ItemsSold"     HeaderText="Sold"
                            ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"/>
                        <asp:TemplateField HeaderText="Avg Rating">
                            <ItemTemplate><%# Convert.ToDecimal(Eval("AvgRating")) > 0 ? string.Format("⭐ {0:F1}", Eval("AvgRating")) : "—" %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TotalSales"    HeaderText="Sales (R)"    DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"/>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <%-- LISTINGS GRIDVIEW --%>
    <asp:Panel ID="pnlListings" runat="server" Visible="false">
        <div class="section-card">
            <div class="section-head">
                <h2>👗 Listings</h2>
                <span><asp:Literal ID="litListingsCount" runat="server"/></span>
            </div>
            <div class="grid-wrap">
                <asp:GridView ID="gvListings" runat="server"
                    AutoGenerateColumns="false" GridLines="None"
                    AllowPaging="true" PageSize="15"
                    OnPageIndexChanging="gvListings_PageIndexChanging"
                    PagerStyle-CssClass="pager">
                    <Columns>
                        <asp:BoundField    DataField="Title"      HeaderText="Title"/>
                        <asp:BoundField    DataField="Seller"     HeaderText="Seller"/>
                        <asp:BoundField    DataField="Category"   HeaderText="Category"/>
                        <asp:BoundField    DataField="Condition"  HeaderText="Condition"/>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate><%# ListingBadge(Eval("Status").ToString()) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField    DataField="DateListed" HeaderText="Listed"        DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:BoundField    DataField="Price"      HeaderText="Price (R)"     DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"/>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <%-- BUYERS GRIDVIEW --%>
    <asp:Panel ID="pnlBuyers" runat="server" Visible="false">
        <div class="section-card">
            <div class="section-head">
                <h2>👥 Buyers</h2>
                <span><asp:Literal ID="litBuyersCount" runat="server"/></span>
            </div>
            <div class="grid-wrap">
                <asp:GridView ID="gvBuyers" runat="server"
                    AutoGenerateColumns="false" GridLines="None"
                    AllowPaging="true" PageSize="15"
                    OnPageIndexChanging="gvBuyers_PageIndexChanging"
                    PagerStyle-CssClass="pager">
                    <Columns>
                        <asp:BoundField DataField="FullName"    HeaderText="Name"/>
                        <asp:BoundField DataField="Email"       HeaderText="Email"/>
                        <asp:BoundField DataField="DateJoined"  HeaderText="Member Since"   DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:BoundField DataField="TotalOrders" HeaderText="Orders"
                            ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"/>
                        <asp:BoundField DataField="TotalSpent"  HeaderText="Spent (R)"      DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"/>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <%-- REVIEWS GRIDVIEW --%>
    <asp:Panel ID="pnlReviews" runat="server" Visible="false">
        <div class="section-card">
            <div class="section-head">
                <h2>⭐ Reviews</h2>
                <span><asp:Literal ID="litReviewsCount" runat="server"/></span>
            </div>
            <div class="grid-wrap">
                <asp:GridView ID="gvReviews" runat="server"
                    AutoGenerateColumns="false" GridLines="None"
                    AllowPaging="true" PageSize="15"
                    OnPageIndexChanging="gvReviews_PageIndexChanging"
                    PagerStyle-CssClass="pager">
                    <Columns>
                        <asp:BoundField    DataField="Buyer"      HeaderText="Buyer"/>
                        <asp:BoundField    DataField="Seller"     HeaderText="Seller"/>
                        <asp:BoundField    DataField="Item"       HeaderText="Item"/>
                        <asp:TemplateField HeaderText="Rating">
                            <ItemTemplate>
                                <span style="color:var(--gold)"><%# new string('★', Convert.ToInt32(Eval("Rating"))) %></span><span style="color:#DDD8CE"><%# new string('★', 5 - Convert.ToInt32(Eval("Rating"))) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField    DataField="Comment"    HeaderText="Comment"/>
                        <asp:BoundField    DataField="DatePosted" HeaderText="Date"          DataFormatString="{0:dd MMM yyyy}"/>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <%-- REPORT HISTORY GRIDVIEW --%>
    <div class="section-card" style="margin-top:8px">
        <div class="section-head">
            <h2>🗂️ Report History</h2>
            <span>All previously generated reports</span>
        </div>
        <div class="grid-wrap">
            <asp:GridView ID="gvHistory" runat="server"
                AutoGenerateColumns="false" GridLines="None"
                AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvHistory_PageIndexChanging"
                PagerStyle-CssClass="pager"
                EmptyDataText="No reports generated yet.">
                <EmptyDataRowStyle CssClass="empty-msg"/>
                <Columns>
                    <asp:BoundField DataField="ReportID"        HeaderText="#"             ItemStyle-Width="50px"/>
                    <asp:BoundField DataField="ReportType"      HeaderText="Type"/>
                    <asp:BoundField DataField="DateFrom"        HeaderText="From"          DataFormatString="{0:dd MMM yyyy}"/>
                    <asp:BoundField DataField="DateTo"          HeaderText="To"            DataFormatString="{0:dd MMM yyyy}"/>
                    <asp:BoundField DataField="GeneratedByName" HeaderText="Admin"/>
                    <asp:BoundField DataField="GeneratedAt"     HeaderText="Generated At"  DataFormatString="{0:dd MMM yyyy HH:mm}"/>
                    <asp:BoundField DataField="TotalOrders"     HeaderText="Orders"
                        ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"/>
                    <asp:BoundField DataField="TotalRevenue"    HeaderText="Revenue (R)"   DataFormatString="{0:N2}"
                        ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"/>
                    <asp:BoundField DataField="TotalCommission" HeaderText="Commission (R)" DataFormatString="{0:N2}"
                        ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"/>
                </Columns>
            </asp:GridView>
        </div>
    </div>

</div>
</form>
</body>
</html>