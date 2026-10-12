using System;
using System.Web.UI;

namespace ThriftHub
{
    public partial class Logout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Clear everything from the session
            Session.Clear();
            Session.Abandon();

            // Also clear the session cookie for extra security
            if (Request.Cookies["ASP.NET_SessionId"] != null)
            {
                Response.Cookies["ASP.NET_SessionId"].Value = "";
                Response.Cookies["ASP.NET_SessionId"].Expires = DateTime.Now.AddYears(-1);
            }
        }
    }
}