// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Sqlite.SQLiteStatement
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
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
    public class SQLiteStatement : IDisposable
    {
        private IntPtr handle;
        private bool disposed;
        public IntPtr Handle { get { return handle; } }
        // RVA: 0x16BAA58
        public SQLiteStatement(IntPtr handle)
        {
            this.handle = handle;
        }

        // RVA: 0x16BBE24
        ~SQLiteStatement()
        {
            Dispose(false);
        }

        // RVA: 0x16BBE98
        public IntPtr get_Handle()
        {
            return handle;
        }

        // RVA: 0x16BB950
        public int ColumnCount()
        {
            ThrowIfDisposed();
            return SQLite.sqlite3_column_count(handle);
        }

        // RVA: 0x16BB9C0
        public string ColumnName(int i)
        {
            ThrowIfDisposed();
            return SQLiteUtil.ReadUTF8String(SQLite.sqlite3_column_name(handle, i), -1);
        }

        // RVA: 0x16BBA48
        public int ColumnType(int i)
        {
            ThrowIfDisposed();
            return SQLite.sqlite3_column_type(handle, i);
        }

        // RVA: 0x16BAFD8
        public void BindNull(int i)
        {
            ThrowIfDisposed();
            int num = SQLite.sqlite3_bind_null(handle, i);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BB074
        public void BindInt(int i, int value)
        {
            ThrowIfDisposed();
            int num = SQLite.sqlite3_bind_int(handle, i, value);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BB118
        public void BindInt64(int i, long value)
        {
            ThrowIfDisposed();
            int num = SQLite.sqlite3_bind_int64(handle, i, value);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BB1BC
        public void BindDouble(int i, double value)
        {
            ThrowIfDisposed();
            int num = SQLite.sqlite3_bind_double(handle, i, value);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BB268
        public void BindText(int i, string value)
        {
            ThrowIfDisposed();
            byte[] value2 = SQLiteUtil.ToUtf8(value, false);
            int num = SQLite.sqlite3_bind_text(handle, i, value2, value2.Length, SQLite.SQLITE_TRANSIENT);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BB334
        public void BindBlob(int i, byte[] value)
        {
            ThrowIfDisposed();
            int num = SQLite.sqlite3_bind_blob(handle, i, value, value.Length, SQLite.SQLITE_TRANSIENT);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BBD08
        public bool Step()
        {
            ThrowIfDisposed();
            int num = SQLite.sqlite3_step(handle);
            if (num == 100)
            {
                return true;
            }

            if (num == 101)
            {
                return false;
            }

            throw SQLiteException.Create(num);
        }

        // RVA: 0x16BC098
        public int GetInt(int i)
        {
            ThrowIfDisposed();
            return SQLite.sqlite3_column_int(handle, i);
        }

        // RVA: 0x16BC118
        public Nullable<int> GetNullableInt(int i)
        {
            ThrowIfDisposed();
            if (ColumnType(i) == 5)
            {
                return null;
            }

            return SQLite.sqlite3_column_int(handle, i);
        }

        // RVA: 0x16BBAC8
        public long GetInt64(int i)
        {
            ThrowIfDisposed();
            return SQLite.sqlite3_column_int64(handle, i);
        }

        // RVA: 0x16BC1DC
        public Nullable<long> GetNullableInt64(int i)
        {
            ThrowIfDisposed();
            if (ColumnType(i) == 5)
            {
                return null;
            }

            return SQLite.sqlite3_column_int64(handle, i);
        }

        // RVA: 0x16BBB48
        public double GetDouble(int i)
        {
            ThrowIfDisposed();
            return SQLite.sqlite3_column_double(handle, i);
        }

        // RVA: 0x16BC2A4
        public Nullable<double> GetNullableDouble(int i)
        {
            ThrowIfDisposed();
            if (ColumnType(i) == 5)
            {
                return null;
            }

            return SQLite.sqlite3_column_double(handle, i);
        }

        // RVA: 0x16BBBC8
        public string GetText(int i)
        {
            ThrowIfDisposed();
            IntPtr ptr = SQLite.sqlite3_column_text(handle, i);
            int len = SQLite.sqlite3_column_bytes(handle, i);
            return SQLiteUtil.ReadUTF8String(ptr, len);
        }

        // RVA: 0x16BBC68
        public byte[] GetBlob(int i)
        {
            ThrowIfDisposed();
            IntPtr ptr = SQLite.sqlite3_column_blob(handle, i);
            int len = SQLite.sqlite3_column_bytes(handle, i);
            return SQLiteUtil.ReadByteArray(ptr, len);
        }

        // RVA: 0x16BC43C
        public void Reset()
        {
            ThrowIfDisposed();
            int num = SQLite.sqlite3_reset(handle);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BC4C8
        public void ClearBindings()
        {
            ThrowIfDisposed();
            int num = SQLite.sqlite3_clear_bindings(handle);
            if (num != 0)
            {
                throw SQLiteException.Create(num);
            }
        }

        // RVA: 0x16BAF4C
        public void FinalizeHandle()
        {
            IntPtr intPtr = handle;
            handle = IntPtr.Zero;
            if (intPtr != IntPtr.Zero)
            {
                SQLite.sqlite3_finalize(intPtr);
            }
        }

        // RVA: 0x16BC554
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        // RVA: 0x16BC5D0
        protected virtual void Dispose(bool disposing)
        {
            if (disposed)
            {
                return;
            }

            FinalizeHandle();
            disposed = true;
        }

        // RVA: 0x16BBEA0
        private void ThrowIfDisposed()
        {
            if (disposed)
            {
                throw new ObjectDisposedException(GetType().Name);
            }
        }
    }
}
