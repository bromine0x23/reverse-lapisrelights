// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Sqlite.SQLite
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Runtime.InteropServices;
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
    public static class SQLite
    {
        public const int SQLITE_OK = 0;
        public const int SQLITE_ERROR = 1;
        public const int SQLITE_INTERNAL = 2;
        public const int SQLITE_PERM = 3;
        public const int SQLITE_ABORT = 4;
        public const int SQLITE_BUSY = 5;
        public const int SQLITE_LOCKED = 6;
        public const int SQLITE_NOMEM = 7;
        public const int SQLITE_READONLY = 8;
        public const int SQLITE_INTERRUPT = 9;
        public const int SQLITE_IOERR = 10;
        public const int SQLITE_CORRUPT = 11;
        public const int SQLITE_NOTFOUND = 12;
        public const int SQLITE_FULL = 13;
        public const int SQLITE_CANTOPEN = 14;
        public const int SQLITE_PROTOCOL = 15;
        public const int SQLITE_EMPTY = 16;
        public const int SQLITE_SCHEMA = 17;
        public const int SQLITE_TOOBIG = 18;
        public const int SQLITE_CONSTRAINT = 19;
        public const int SQLITE_MISMATCH = 20;
        public const int SQLITE_MISUSE = 21;
        public const int SQLITE_NOLFS = 22;
        public const int SQLITE_AUTH = 23;
        public const int SQLITE_FORMAT = 24;
        public const int SQLITE_RANGE = 25;
        public const int SQLITE_NOTADB = 26;
        public const int SQLITE_NOTICE = 27;
        public const int SQLITE_WARNING = 28;
        public const int SQLITE_ROW = 100;
        public const int SQLITE_DONE = 101;
        public static readonly string[] ErrorMessage;
        public static readonly IntPtr SQLITE_STATIC;
        public static readonly IntPtr SQLITE_TRANSIENT;
        public const int SQLITE_INTEGER = 1;
        public const int SQLITE_FLOAT = 2;
        public const int SQLITE_TEXT = 3;
        public const int SQLITE_BLOB = 4;
        public const int SQLITE_NULL = 5;
        public const int SQLITE_OPEN_READONLY = 1;
        public const int SQLITE_OPEN_READWRITE = 2;
        public const int SQLITE_OPEN_CREATE = 4;
        public const int SQLITE_OPEN_URI = 64;
        public const int SQLITE_OPEN_MEMORY = 128;
        public const int SQLITE_OPEN_NOMUTEX = 32768;
        public const int SQLITE_OPEN_FULLMUTEX = 65536;
        public const int SQLITE_OPEN_SHAREDCACHE = 131072;
        public const int SQLITE_OPEN_PRIVATECACHE = 262144;
        private const string dllimport = "klbsqlite3";

        // RVA: 0x16B8D38
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_open(byte[] filename, out IntPtr db);

        // RVA: 0x16B8DD0
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_open_v2(byte[] filename, out IntPtr db, int flags, byte[] zVfs);

        // RVA: 0x16B8E88
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_close(IntPtr db);

        // RVA: 0x16B8F08
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_exec(IntPtr db, byte[] sql, IntPtr cb1, IntPtr cb2, ref IntPtr errMsg);

        // RVA: 0x16B8FC0
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_prepare_v2(IntPtr db, byte[] zSql, int nByte, out IntPtr ppStmt, out IntPtr pzTail);

        // RVA: 0x16B9078
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_step(IntPtr pStmt);

        // RVA: 0x16B90F8
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_reset(IntPtr pStmt);

        // RVA: 0x16B9178
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_clear_bindings(IntPtr pStmt);

        // RVA: 0x16B91F8
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_errcode(IntPtr db);

        // RVA: 0x16B9278
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_extended_errcode(IntPtr db);

        // RVA: 0x16B92F8
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_changes(IntPtr db);

        // RVA: 0x16B9378
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_finalize(IntPtr pStmt);

        // RVA: 0x16B93F8
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr sqlite3_errmsg(IntPtr db);

        // RVA: 0x16B9478
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_column_count(IntPtr pStmt);

        // RVA: 0x16B94F8
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr sqlite3_column_name(IntPtr pStmt, int iCol);

        // RVA: 0x16B9588
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_column_type(IntPtr pStmt, int iCol);

        // RVA: 0x16B9618
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_column_int(IntPtr pStmt, int iCol);

        // RVA: 0x16B96A8
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern long sqlite3_column_int64(IntPtr pStmt, int iCol);

        // RVA: 0x16B9738
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr sqlite3_column_text(IntPtr pStmt, int iCol);

        // RVA: 0x16B97C8
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern double sqlite3_column_double(IntPtr pStmt, int iCol);

        // RVA: 0x16B9858
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr sqlite3_column_blob(IntPtr pStmt, int iCol);

        // RVA: 0x16B98E8
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_column_bytes(IntPtr pStmt, int iCol);

        // RVA: 0x16B9978
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_bind_null(IntPtr pStmt, int n);

        // RVA: 0x16B9A08
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_bind_int(IntPtr pStmt, int n, int value);

        // RVA: 0x16B9A9C
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_bind_int64(IntPtr pStmt, int n, long value);

        // RVA: 0x16B9B34
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_bind_text(IntPtr pStmt, int n, byte[] value, int length, IntPtr freetype);

        // RVA: 0x16B9BEC
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_bind_double(IntPtr pStmt, int n, double value);

        // RVA: 0x16B9C8C
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_bind_blob(IntPtr pStmt, int n, byte[] value, int length, IntPtr freetype);

        // RVA: 0x16B9D44
        [DllImport(dllimport, CallingConvention = CallingConvention.Cdecl)]
        public static extern int sqlite3_key(IntPtr db, byte[] key, int len);

        // RVA: 0x16B9DE4
        static SQLite()
        {
                        ErrorMessage = new string[]
                        {
                            "Successful result",
                            "SQL error or missing database",
                            "Internal logic error in SQLite",
                            "Access permission denied",
                            "Callback routine requested an abort",
                            "The database file is locked",
                            "A table in the database is locked",
                            "A malloc() failed",
                            "Attempt to write a readonly database",
                            "Operation terminated by sqlite3_interrupt(",
                            "Some kind of disk I/O error occurred",
                            "The database disk image is malformed",
                            "Unknown opcode in sqlite3_file_control()",
                            "Insertion failed because database is full",
                            "Unable to open the database file",
                            "Database lock protocol error",
                            "Database is empty",
                            "The database schema changed",
                            "String or BLOB exceeds size limit",
                            "Abort due to constraint violation",
                            "Data type mismatch",
                            "Library used incorrectly",
                            "Uses OS features not supported on host",
                            "Authorization denied",
                            "Auxiliary database format error",
                            "2nd parameter to sqlite3_bind out of range",
                            "File opened that is not a database file",
                            "Notifications from sqlite3_log()",
                            "Warnings from sqlite3_log()"
                        };
        }
    }
}
