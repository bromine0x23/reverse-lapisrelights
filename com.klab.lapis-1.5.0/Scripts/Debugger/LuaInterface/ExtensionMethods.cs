// =============================================================================
//  Lapis Re:Lights 1.5.0 — Debugger.dll
//  LuaInterface.ExtensionMethods
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
    public static class ExtensionMethods
    {

        // RVA: 0x2ED47F4
        [Extension]
        public static void AppendLineEx(StringBuilder sb, string str = "")
        {
            sb.Append(str).Append("\r\n");
        }
    }
}
