using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;

public class SessionHelper
{
    public static int UserID => (int)(HttpContext.Current.Session["UserID"] ?? 0);
    public static string UserRole => (string)(HttpContext.Current.Session["UserRole"] ?? "");
    public static string FullName => (string)(HttpContext.Current.Session["FullName"] ?? "");
    public static bool IsLoggedIn => UserID > 0;

    public static void SetUser(int id, string role, string name)
    {
        HttpContext.Current.Session["UserID"] = id;
        HttpContext.Current.Session["UserRole"] = role;
        HttpContext.Current.Session["FullName"] = name;
    }

    public static void Clear() => HttpContext.Current.Session.Clear();
}