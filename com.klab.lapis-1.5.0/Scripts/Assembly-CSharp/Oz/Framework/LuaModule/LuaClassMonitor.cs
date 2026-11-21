// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.LuaModule.LuaClassMonitor
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

namespace Oz.Framework.LuaModule
{
    public static class LuaClassMonitor
    {
        public static HashSet<string> AliveLuaClass { get; set; }


        // RVA: 0x1400EA8
        static LuaClassMonitor()
        {
            AliveLuaClass = new HashSet<string>();
        }

        // RVA: 0x1400F58
        public static void Clear()
        {
            AliveLuaClass.Clear();
        }

        // RVA: 0x1401010
        public static void AddWatch(string key)
        {
            AliveLuaClass.Add(key);
        }

        // RVA: 0x14010D8
        public static void RemoveWatch(string key)
        {
            AliveLuaClass.Remove(key);
        }
    }
}
