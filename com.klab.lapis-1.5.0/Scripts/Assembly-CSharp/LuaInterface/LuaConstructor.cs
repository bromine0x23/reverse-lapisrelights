// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaConstructor
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
    public sealed class LuaConstructor
    {
        private ConstructorInfo method;
        private List<Type> list;

        // RVA: 0x22893E8
        [NoToLua]
        public LuaConstructor(ConstructorInfo func, Type[] types)
        {
                        method = func;            

                        if (types != null)
                        {
                            list = new List<Type>(types);
                        }
        }

        // RVA: 0x2289478
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

        // RVA: 0x2289730
        public void Destroy()
        {
                        method = null;
                        list.Clear();
        }
    }
}
