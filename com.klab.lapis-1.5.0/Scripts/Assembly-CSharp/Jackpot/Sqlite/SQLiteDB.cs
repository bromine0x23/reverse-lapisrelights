// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Sqlite.SQLiteDB
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.Sqlite
{
    public class SQLiteDB
    {
        private IntPtr handle;
        public bool IsConnectionOpen { get { return handle != IntPtr.Zero; } }
        public IntPtr Handle { get { return handle; } }
        // RVA: 0x16BA488
        public SQLiteDB(IntPtr handle)
        {
        }

        // RVA: 0x16BA4B4
        public SQLiteDB()
        {
            handle = IntPtr.Zero;
        }

        // RVA: 0x16BA558
        public void OpenReadOnly(string path)
        {
            Open(path, 6, null);
        }

        // RVA: 0x16BA564
        public void Open(string path, int flags = 6, string zVfs)
        {
            byte[] filename = SQLiteUtil.ToUtf8(path, true);
            byte[] zVfs2 = SQLiteUtil.ToUtf8(zVfs, true);
            int num = SQLite.sqlite3_open_v2(filename, out handle, flags, zVfs2);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BA81C
        public void Close()
        {
            IntPtr intPtr = handle;
            handle = IntPtr.Zero;
            if (intPtr != IntPtr.Zero)
            {
                SQLite.sqlite3_close(intPtr);
            }
        }

        // RVA: 0x16BA8A8
        public void Key(string key)
        {
            if (string.IsNullOrEmpty(key))
            {
                return;
            }

            byte[] key2 = SQLiteUtil.ToUtf8(key, false);
            int num = SQLite.sqlite3_key(handle, key2, key2.Length);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BA968
        public SQLiteStatement Prepare(string query)
        {
            byte[] zSql = SQLiteUtil.ToUtf8(query, false);
            IntPtr intPtr;
            IntPtr intPtr2;
            int num = SQLite.sqlite3_prepare_v2(handle, zSql, zSql.Length, out intPtr, out intPtr2);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }

            return new SQLiteStatement(intPtr);
        }

        // RVA: 0x16BAA84
        public void Execute(string query)
        {
            IntPtr intPtr = IntPtr.Zero;
            int num = SQLite.sqlite3_exec(handle, SQLiteUtil.ToUtf8(query, true), IntPtr.Zero, IntPtr.Zero, ref intPtr);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BAB3C
        public SQLiteStatement Query(string query, object[] args)
        {
            SQLiteStatement sQLiteStatement = Prepare(query);
            try
            {
                applyBind(sQLiteStatement, args);
            }
            catch
            {
                sQLiteStatement.FinalizeHandle();
                throw;
            }

            return sQLiteStatement;
        }

        // RVA: 0x16BAC44
        private void applyBind(SQLiteStatement stmt, object[] args)
        {
            if (args == null || args.Length < 1)
            {
                return;
            }

            for (int i = 0; i < args.Length; i++)
            {
                object obj = args[i];
                if (obj == null)
                {
                    stmt.BindNull(i + 1);
                }
                else if (obj is int)
                {
                    stmt.BindInt(i + 1, (int)obj);
                }
                else if (obj is long)
                {
                    stmt.BindInt64(i + 1, (long)obj);
                }
                else if (obj is double)
                {
                    stmt.BindDouble(i + 1, (double)obj);
                }
                else if (obj is float)
                {
                    stmt.BindDouble(i + 1, Convert.ToDouble((float)obj));
                }
                else if (obj is string)
                {
                    stmt.BindText(i + 1, (string)obj);
                }
                else
                {
                    stmt.BindBlob(i + 1, obj as byte[]);
                }
            }
        }

        // RVA: 0x16BB468
        public List<DataRow> QueryRows(string query, object[] args)
        {
            SQLiteStatement sQLiteStatement = Query(query, args);
            int count = sQLiteStatement.ColumnCount();
            List<DataRow> list = new List<DataRow>();
            Dictionary<string, int> dictionary = new Dictionary<string, int>(count);
            for (int i = 0; i < count; i++)
            {
                dictionary[sQLiteStatement.ColumnName(i)] = i;
            }

            while (sQLiteStatement.Step())
            {
                object[] array = new object[count];
                for (int j = 0; j < count; j++)
                {
                    switch (sQLiteStatement.ColumnType(j))
                    {
                        case 1:
                            array[j] = sQLiteStatement.GetInt64(j);
                            break;
                        case 2:
                            array[j] = sQLiteStatement.GetDouble(j);
                            break;
                        case 3:
                            array[j] = sQLiteStatement.GetText(j);
                            break;
                        case 4:
                            array[j] = sQLiteStatement.GetBlob(j);
                            break;
                        case 5:
                            array[j] = null;
                            break;
                    }
                }

                list.Add(new DataRow(array, dictionary));
            }

            return list;
        }

        // RVA: 0x16BBDA4
        public DataRow QueryRow(string query, object[] args)
        {
            List<DataRow> list = QueryRows(query, args);
            if (list.Count <= 0)
            {
                return null;
            }

            return list[0];
        }
    }
}
