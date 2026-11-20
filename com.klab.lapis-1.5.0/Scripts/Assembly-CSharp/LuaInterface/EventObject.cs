// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.EventObject
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

namespace LuaInterface
{
    public class EventObject
    {
        [NoToLua]
        public EventOp op;
        [NoToLua]
        public Delegate func;
        [NoToLua]
        public Type type;

        // RVA: 0x22882AC
        [NoToLua]
        public EventObject(Type t)
        {
                        type = t;
        }

        // RVA: 0x22882D8
        public static EventObject op_Addition(EventObject a, Delegate b)
        {
            a.op = EventOp.Add;
            a.func = b;
            return a;
        }

        // RVA: 0x22882F8
        public static EventObject op_Subtraction(EventObject a, Delegate b)
        {
            a.op = EventOp.Sub;
            a.func = b;
            return a;
        }
    }
}
