// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaDelegate
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Reflection;
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
    public class LuaDelegate
    {
        public LuaFunction func;
        public LuaTable self;
        public MethodInfo method;

        // RVA: 0x22928E4
        public LuaDelegate(LuaFunction func)
        {
                        this.func = func;
        }

        // RVA: 0x2292910
        public LuaDelegate(LuaFunction func, LuaTable self)
        {
                        this.func = func;
                        this.self = self;
        }

        // RVA: 0x2292948
        public virtual void Dispose()
        {
                        --count;

                        if (count > 0)
                        {
                            return;
                        }

                        IsAlive = false;
                        Dispose(true);            
        }

        // RVA: 0x22929D0
        public override bool Equals(object o)
        {
                        if (o == null) return reference <= 0;
                        LuaBaseRef lr = o as LuaBaseRef;      

                        if (lr == null || lr.reference != reference)
                        {
                            return false;
                        }

                        return reference > 0;
        }

        // RVA: 0x2292AE8
        private static bool CompareLuaDelegate(LuaDelegate a, LuaDelegate b)
        {
                        if (System.Object.ReferenceEquals(a, b))
                        {
                            return true;
                        }

                        object l = a;
                        object r = b;

                        if (l == null && r != null)
                        {
                            return b.func == null && b.self == null;
                        }

                        if (l != null && r == null)
                        {
                            return a.func == null && a.self == null;
                        }

                        if (a.func != b.func || a.self != b.self)
                        {
                            return false;
                        }

                        return a.func != null;
        }

        // RVA: 0x2292AE4
        public static bool op_Equality(LuaDelegate a, LuaDelegate b)
        {
            return CompareLuaDelegate(a, b);
        }

        // RVA: 0x2292BAC
        public static bool op_Inequality(LuaDelegate a, LuaDelegate b)
        {
            return !CompareLuaDelegate(a, b);
        }

        // RVA: 0x2292BC8
        public override int GetHashCode()
        {
                        return RuntimeHelpers.GetHashCode(this);            
        }
    }
}
