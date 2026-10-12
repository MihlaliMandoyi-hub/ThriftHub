using System.Configuration;
using System.Data.SqlClient;

/// <summary>
/// Provides database connection for ThriftHub
/// </summary>
public class DBHelper
{
    public static SqlConnection GetConnection()
    {
        string connStr = ConfigurationManager
            .ConnectionStrings["ThriftHubDB"].ConnectionString;
        return new SqlConnection(connStr);
    }
}