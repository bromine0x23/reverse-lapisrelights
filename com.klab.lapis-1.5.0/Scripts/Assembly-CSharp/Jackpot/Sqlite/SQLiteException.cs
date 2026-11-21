// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Sqlite.SQLiteException
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
    public class SQLiteException : Exception
    {

        // RVA: 0x16BA6EC
        public static SQLiteException Create(int err)
        {
            if (err < SQLite.ErrorMessage.Length)
            {
                return new SQLiteException(SQLite.ErrorMessage[err]);
            }

            return new SQLiteException("SQLITE_ERROR:" + err.ToString());
        }

        // RVA: 0x16BB3F0
        public SQLiteException(string message)
            : base(message)
        {
        }
    }
}
