// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Sqlite.SQLiteUtil
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.Sqlite
{
    public static class SQLiteUtil
    {

        // RVA: 0x16BC368
        public static byte[] ReadByteArray(IntPtr ptr, int len)
        {
            if (len == 0 || ptr == IntPtr.Zero)
            {
                return new byte[0];
            }

            byte[] array = new byte[len];
            Marshal.Copy(ptr, array, 0, len);
            return array;
        }

        // RVA: 0x16BBF4C
        public static string ReadUTF8String(IntPtr ptr, int len)
        {
            if (len == 0 || ptr == IntPtr.Zero)
            {
                return string.Empty;
            }

            if (len < 0)
            {
                int i = -1;
                while (Marshal.ReadByte(ptr, ++i) != 0)
                {
                }

                len = i;
                if (len == 0)
                {
                    return string.Empty;
                }
            }

            byte[] array = new byte[len];
            Marshal.Copy(ptr, array, 0, len);
            return Encoding.UTF8.GetString(array, 0, len);
        }

        // RVA: 0x16BA634
        public static byte[] ToUtf8(string str, bool nullTerminate)
        {
            if (str == null)
            {
                return null;
            }

            Encoding utf8 = Encoding.UTF8;
            if (nullTerminate)
            {
                str += "\0";
            }

            return utf8.GetBytes(str);
        }
    }
}
