// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  KlabVfs
//  来源：Il2CppDumper 元数据 + 反汇编（0x1330DC0 起）
// =============================================================================

using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using Kc.Config;
using Oz.GameFramework.Runtime;
using UnityEngine;

/// <summary>Klab 加密 SQLite 的 VFS 注册与数据库文件加密。</summary>
public class KlabVfs
{
    public static string MASTER_KEY;
    public static string MASTER_LANG_KEY;
    private const string dllimport = "klbsqlite3";

    [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
    public static extern int klbvfs_register();

    [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
    public static extern int sqlite3_libversion_number();

    /// <summary>用 LCG 流加密 SQLite 文件，并把密钥记录到 PlayerPrefs。</summary>
    public static void Deflate(string tmpFile, uint[] keyDataList, string savedKey)
    {
        byte[] masterKey = GetSqliteMasterKey();
        byte[] buffer = new byte[0x2000];
        string tmpPath = tmpFile + "_";
        uint[] rawKey = GetRawSqliteKey(tmpFile, masterKey);

        using (FileStream output = new FileStream(tmpPath, FileMode.Create, FileAccess.ReadWrite, FileShare.None, 0x2000))
        using (FileStream input = new FileStream(tmpFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        {
            LCGStream stream = new LCGStream(
                input,
                keyDataList[0] ^ KcAppSetting.SqliteKey1,
                keyDataList[1] ^ KcAppSetting.SqliteKey2,
                keyDataList[2] ^ KcAppSetting.SqliteKey3);
            LCGStream crypt = new LCGStream(stream, rawKey[0], rawKey[1], rawKey[2]);

            int read;
            while ((read = crypt.Read(buffer, 0, buffer.Length)) > 0)
            {
                output.Write(buffer, 0, read);
            }
        }

        PlayerPrefs.SetString(savedKey, string.Format("{0}.{1}.{2}", keyDataList[0], keyDataList[1], keyDataList[2]));
        File.Delete(tmpFile);
        File.Move(tmpPath, tmpFile);
        File.Delete(tmpPath);
    }

    private static byte[] GetSqliteMasterKey()
    {
        if (PlayerPrefs.HasKey("SQ"))
        {
            return Convert.FromBase64String(PlayerPrefs.GetString("SQ"));
        }

        byte[] key = CryptoUtility.RandomBytes(0x20);
        PlayerPrefs.SetString("SQ", Convert.ToBase64String(key));
        return key;
    }

    private static uint[] GetRawSqliteKey(string fileName, byte[] masterKey)
    {
        byte[] data = Encoding.UTF8.GetBytes(fileName);
        byte[] hash = CryptoUtility.HmacSha1(data, masterKey);
        uint[] key = new uint[3];

        for (int i = 0; i < 3; i++)
        {
            key[i] = (uint)((hash[i * 4] << 24) | (hash[i * 4 + 1] << 16) | (hash[i * 4 + 2] << 8) | hash[i * 4 + 3]);
        }

        return key;
    }

    public KlabVfs()
    {
    }

    static KlabVfs()
    {
        MASTER_KEY = "SQL-CLIENT-KEY";
        MASTER_LANG_KEY = "SQL-CLIENT-LANG-KEY";
    }
}
