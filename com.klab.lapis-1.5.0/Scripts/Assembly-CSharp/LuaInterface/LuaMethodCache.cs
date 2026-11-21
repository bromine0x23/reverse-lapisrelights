// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaMethodCache
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
    public static class LuaMethodCache
    {
        public static Dictionary<Type, Dictionary<string, List<MethodInfo>>> dict;

        // RVA: 0x229B1F8
        private static MethodInfo GetMethod(Type t, string name, Type[] ts)
        {
                        Dictionary<string, List<MethodInfo>> map = null;
                        List<MethodInfo> list = null;

                        if (!dict.TryGetValue(t, out map))
                        {
                            map = new Dictionary<string, List<MethodInfo>>();
                            dict.Add(t, map);
                        }

                        if (!map.TryGetValue(name, out list))
                        {
                            list = new List<MethodInfo>();
                            MethodInfo[] mds = t.GetMethods();

                            for (int i = 0; i < mds.Length; i++)
                            {
                                if (mds[i].Name == name)
                                {
                                    list.Add(mds[i]);
                                }
                            }

                            map.Add(name, list);
                        }

                        if (list.Count == 1)
                        {
                            return list[0];
                        }

                        for (int i = 0; i < list.Count; i++)
                        {
                            ParameterInfo[] pis = list[i].GetParameters();
                            bool flag = true;

                            if (pis.Length == 0 && (ts == null || ts.Length == 0))
                            {
                                return list[i];
                            }
                            else if (pis.Length == ts.Length)
                            {
                                for (int j = 0; j < ts.Length; j++)
                                {
                                    if (pis[j].ParameterType != ts[j])
                                    {
                                        flag = false;
                                        break;
                                    }
                                }

                                if (flag)
                                {
                                    return list[i];
                                }
                            }
                        }

                        return null;
        }

        // RVA: 0x229B594
        public static object CallSingleMethod(string name, object obj, object[] args)
        {
                        MethodInfo md = GetMethod(obj.GetType(), name, null);
                        return md.Invoke(obj, args);
        }

        // RVA: 0x229B640
        public static object CallMethod(string name, object obj, object[] args)
        {
                        Type[] ts = new Type[args.Length];

                        for (int i = 0; i < args.Length; i++)
                        {
                            ts[i] = args[i].GetType();
                        }

                        MethodInfo md = GetMethod(obj.GetType(), name, ts);
                        return md.Invoke(obj, args);
        }

        // RVA: 0x229B7A0
        static LuaMethodCache()
        {
            dict = new Dictionary<Type, Dictionary<string, List<MethodInfo>>>();
        }
    }
}
