public class NavHelper
{
    public static string GetRole()
    {
        return System.Web.HttpContext.Current.Session["UserRole"]?.ToString() ?? "";
    }

    public static int GetUserID()
    {
        var val = System.Web.HttpContext.Current.Session["UserID"];
        return val != null ? (int)val : 0;
    }

    public static string GetFullName()
    {
        return System.Web.HttpContext.Current.Session["FullName"]?.ToString() ?? "";
    }

    public static bool IsLoggedIn()
    {
        return GetUserID() > 0;
    }

    public static void RequireLogin()
    {
        if (!IsLoggedIn())
            System.Web.HttpContext.Current.Response.Redirect("~/Login.aspx");
    }

    public static void RequireRole(string role)
    {
        RequireLogin();
        if (GetRole() != role)
            System.Web.HttpContext.Current.Response.Redirect("~/Default.aspx");
    }
}