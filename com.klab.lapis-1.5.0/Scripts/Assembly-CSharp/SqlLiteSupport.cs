// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  SqlLiteSupport
//  来源：Il2CppDumper 元数据 + 反汇编（0x1D73DA0 起）
// =============================================================================

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Jackpot.Sqlite;
using UnityEngine;

/// <summary>MasterData SQLite 的打开、查询与懒加载缓存。</summary>
public class SqlLiteSupport
{
    public static string MasterTableName;
    public static string MasterTableLangName;
    private static List<string> LangTableContent;
    private static Dictionary<string, SQLiteDB> dbDic;
    private static Dictionary<string, List<string>> dbCache;
    private static bool klbvfs_registered;

    public static void OpenDB(string key, string path, bool useVfs)
    {
        if (dbDic.ContainsKey(key))
        {
            dbDic[key].Close();
            dbDic.Remove(key);
        }

        dbDic[key] = new SQLiteDB();

        if (!klbvfs_registered && useVfs)
        {
            klbvfs_registered = true;
            KlabVfs.klbvfs_register();
        }

        try
        {
            if (useVfs)
            {
                dbDic[key].Open(path, 6, "klb_vfs");
            }
            else
            {
                dbDic[key].Open(path, 6, null);
            }
        }
        catch (FileNotFoundException)
        {
            Debug.LogError("FileNotFoundException");
            dbDic.Remove(key);
        }
        catch (SQLiteException e)
        {
            Debug.LogError("SqliteException:" + e.Message);
            dbDic[key].Close();
            dbDic.Remove(key);
        }
    }

    private static void OnLazyError(string msg)
    {
        Debug.LogError(msg);
    }

    public static void LazyCacheData(string tableKey, string query, Action onComplete)
    {
        SqlLiteThreadMgr.Instance.AddLazyFunc(() =>
        {
            dbCache.Add(tableKey, ExecuteQuery(tableKey, query));
            return onComplete;
        }, OnLazyError);
    }

    public static List<string> GetCacheData(string tableKey)
    {
        List<string> data = dbCache[tableKey];
        dbCache.Remove(tableKey);
        return data;
    }

    public static string ExecuteQueryOne(string tableKey, string query)
    {
        SQLiteDB db = GetSqlDb(tableKey);
        if (db == null)
        {
            Debug.LogError("DB has not opened");
            return null;
        }

        try
        {
            DataRow row = db.QueryRow(query, Array.Empty<object>());
            return row != null ? row.StrWord : null;
        }
        catch (Exception e)
        {
            Debug.LogErrorFormat("Query [{0}] has some error {1}", query, e.Message);
            return null;
        }
    }

    private static string MakeRowToString(DataRow rowInfo)
    {
        string[] names = rowInfo.GetColumnNames();
        Dictionary<string, object> dict = new Dictionary<string, object>();

        for (int i = 0; i < names.Length; i++)
        {
            dict[names[i]] = rowInfo[names[i]];
        }

        return MiniJSON.Json.Serialize(dict);
    }

    public static List<string> ExecuteQuery(string tableKey, string query)
    {
        SQLiteDB db = GetSqlDb(tableKey);
        if (db == null)
        {
            Debug.LogError("DB has not opened");
            return null;
        }

        try
        {
            return db.QueryRows(query, Array.Empty<object>()).Select(t => t.StrWord).ToList();
        }
        catch (SQLiteException e)
        {
            Debug.LogErrorFormat("Error Message :{0}, Sql: {1}", e.Message, query);
            return new List<string>();
        }
    }

    private static SQLiteDB GetSqlDb(string tableKey)
    {
        if (LangTableContent.Contains(tableKey))
        {
            return dbDic[MasterTableLangName];
        }

        return dbDic[MasterTableName];
    }

    public static void CloseAll()
    {
        foreach (SQLiteDB db in dbDic.Values)
        {
            db.Close();
        }

        dbDic.Clear();
    }

    public SqlLiteSupport()
    {
    }

    static SqlLiteSupport()
    {
        MasterTableName = "MASTERDATA";
        MasterTableLangName = "MASTERDATA_LANG";
        LangTableContent = new List<string> { "Terms", "Language" };
        dbDic = new Dictionary<string, SQLiteDB>();
        dbCache = new Dictionary<string, List<string>>();
        klbvfs_registered = false;
    }
}
