using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ThriftHub
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Handle logout
            if (Request.QueryString["logout"] == "1")
            {
                Session.Clear();
                Session.Abandon();
                Response.Redirect("Login.aspx");
                return;
            }

            // If logged in, redirect straight to their dashboard
            if (!IsPostBack && Session["UserID"] != null)
            {
                string role = Session["UserRole"].ToString();
                switch (role)
                {
                    case "Admin":
                        Response.Redirect("~/Pages/Admin/Dashboard.aspx");
                        break;
                    case "Moderator":
                        Response.Redirect("~/Pages/Moderator/PendingListings.aspx");
                        break;
                    case "Seller":
                        Response.Redirect("~/Pages/Seller/Dashboard.aspx");
                        break;
                    case "Buyer":
                        Response.Redirect("~/Pages/Buyer/Catalogue.aspx");
                        break;
                }
            }
        }
    }
}