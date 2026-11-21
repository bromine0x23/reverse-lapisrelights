// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaMethod
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
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
    public sealed class LuaMethod
    {
        private MethodInfo method;
        private List<Type> list;
        private Type kclass;

        // RVA: 0x229AD38
        [NoToLua]
        public LuaMethod(MethodInfo md, Type t, Type[] types)
        {
                        method = md;
                        kclass = t;            

                        if (types != null)
                        {
                            list.AddRange(types);
                        }
        }

        // RVA: 0x229AE04
        public int Call(IntPtr L)
        {
                        object[] args = null;
                        ToLua.CheckArgsCount(L, list.Count + 1);

                        if (list.Count > 0)
                        {
                            args = new object[list.Count];

                            for (int i = 0; i < list.Count; i++)
                            {
                                bool isRef = list[i].IsByRef;
                                Type t0 = isRef ? list[i].GetElementType() : list[i];
                                object o = ToLua.CheckVarObject(L, i + 2, t0);
                                args[i] = o;
                            }
                        }

                        object ret = method.Invoke(args);
                        int count = 1;
                        ToLua.Push(L, ret);

                        for (int i = 0; i < list.Count; i++)
                        {
                            if (list[i].IsByRef)
                            {
                                ++count;
                                ToLua.Push(L, args[i]);
                            }
                        }

                        return count;
        }

        // RVA: 0x229B19C
        public void Destroy()
        {
                        method = null;
                        list.Clear();
        }
    }
}
