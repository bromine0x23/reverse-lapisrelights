// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.Lua_Debug
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace LuaInterface
{
    public struct Lua_Debug
    {
        public int eventcode;
        public IntPtr _name;
        public IntPtr _namewhat;
        public IntPtr _what;
        public IntPtr _source;
        public int currentline;
        public int nups;
        public int linedefined;
        public int lastlinedefined;
        public byte[] _short_src;
        public int i_ci;
        public string namewhat { get; }
        public string name { get; }
        public string what { get; }
        public string source { get; }
        public string short_src { get; }

        // RVA: 0x1F6DD5C
        private string tostring(IntPtr p)
        {
            if (p != IntPtr.Zero)
            {
                return LuaDLL.lua_ptrtostring(p, LuaDLL.tolua_strlen(p));
            }
            return string.Empty;
        }

        // RVA: 0x1F6DE08
        public string get_namewhat()
        {
            return tostring(_namewhat);
        }

        // RVA: 0x1F6DE10
        public string get_name()
        {
            return tostring(_name);
        }

        // RVA: 0x1F6DE18
        public string get_what()
        {
            return tostring(_what);
        }

        // RVA: 0x1F6DE20
        public string get_source()
        {
            return tostring(_source);
        }

        // RVA: 0x1F6DE28
        private int GetShortSrcLen(byte[] str)
        {
            for (int i = 0; i < str.Length && i < 0x7F; i++)
            {
                if (str[i] == 0)
                {
                    return i;
                }
            }
            return str.Length < 0x7F ? str.Length : 0x7F;
        }

        // RVA: 0x1F6DE80
        public string get_short_src()
        {
            if (_short_src == null)
            {
                return string.Empty;
            }
            return Encoding.UTF8.GetString(_short_src, 0, GetShortSrcLen(_short_src));
        }
    }
}
