// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.ObjectTranslator
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

namespace LuaInterface
{
    public class ObjectTranslator
    {
        public readonly Dictionary<object, int> objectsBackMap;
        public readonly LuaObjectPool objects;
        private List<ObjectTranslator.DelayGC> gcList;
        private Action<object, int> removeInvalidObject;
        private static ObjectTranslator _translator;
        public bool LogGC { get; set; }


        // RVA: 0x1F6DF44
        public ObjectTranslator()
        {
                        LogGC = false;
            #if !MULTI_STATE
                        _translator = this;
            #endif
                        removeInvalidObject = RemoveObject;
        }

        // RVA: 0x1F6E09C
        public int AddObject(object obj)
        {
                        int index = objects.Add(obj);

                        if (!TypeChecker.IsValueType(obj.GetType()))
                        {
                            objectsBackMap[obj] = index;
                        }

                        return index;
        }

        // RVA: 0x1F6E1BC
        public static ObjectTranslator Get(IntPtr L)
        {
            #if !MULTI_STATE
                        return mainState;
            #else

                        if (mainState != null && mainState.L == ptr)
                        {
                            return mainState;
                        }            

                        LuaState state = null;

                        if (stateMap.TryGetValue(ptr, out state))
                        {
                            return state;
                        }
                        else
                        {
                            return Get(LuaDLL.tolua_getmainstate(ptr));
                        }
            #endif
        }

        // RVA: 0x1F6E224
        private void RemoveObject(object o, int udata)
        {
                        int index = -1;

                        if (objectsBackMap.TryGetValue(o, out index) && index == udata)
                        {
                            objectsBackMap.Remove(o);
                        }
        }

        // RVA: 0x1F6E2D4
        public void RemoveObject(int udata)
        {
                        //只有lua gc才能移除
                        object o = objects.Remove(udata);

                        if (o != null)
                        {
                            if (!TypeChecker.IsValueType(o.GetType()))
                            {
                                RemoveObject(o, udata);
                            }

                            if (LogGC)
                            {
                                Debugger.Log("gc object {0}, id {1}", o, udata);
                            }
                        }
        }

        // RVA: 0x1F6E3F8
        public object GetObject(int udata)
        {
                        return objects.TryGetValue(udata);         
        }

        // RVA: 0x1F6E414
        public void Destroy(int udata)
        {
                        if (pos > 0 && pos < count)
                        {
                            object o = list[pos].obj;
                            list[pos].obj = null;
                            return o;
                        }

                        return null;
        }

        // RVA: 0x1F6E538
        public void DelayDestroy(int id, float time)
        {
                        UnityEngine.Object obj = (UnityEngine.Object)GetObject(id);

                        if (obj != null)
                        {
                            gcList.Add(new DelayGC(id, obj, time));
                        }            
        }

        // RVA: 0x1F6E6BC
        public bool Getudata(object o, out int index)
        {
                        index = -1;
                        return objectsBackMap.TryGetValue(o, out index);
        }

        // RVA: 0x1F6E734
        public void Destroyudata(int udata)
        {
                        objects.Destroy(udata);
        }

        // RVA: 0x1F6E750
        public void SetBack(int index, object o)
        {
                        objects.Replace(index, o);            
        }

        // RVA: 0x1F6E76C
        private bool RemoveFromGCList(int id)
        {
                        lock (gcList)
                        {                
                            for (int i = 0; i < gcList.Count; i++)
                            {
                                if (gcList[i].reference == reference)
                                {
                                    gcList.RemoveAt(i);
                                    break;
                                }
                            }
                        }
        }

        // RVA: 0x1F6E868
        private void DestroyUnityObject(int udata, Object obj)
        {
            object o = objects.TryGetValue(udata);
            if (object.ReferenceEquals(o, obj))
            {
                RemoveObject(o, udata);
                objects.Destroy(udata);
                if (LogGC)
                {
                    Debugger.Log("destroy object {0}, id {1}", o, udata);
                }
            }
            UnityEngine.Object.Destroy(obj);
        }

        // RVA: 0x1F6E998
        public void Collect()
        {
                        int count = gcList.Count;

                        if (count > 0)
                        {
                            lock (gcList)
                            {
                                for (int i = 0; i < gcList.Count; i++)
                                {
                                    int reference = gcList[i].reference;
                                    string name = gcList[i].name;
                                    Collect(reference, name, true);
                                }

                                gcList.Clear();
                                return count;
                            }
                        }

                        for (int i = 0; i < subList.Count; i++)
                        {
                            subList[i].Dispose();
                        }

                        subList.Clear();
                        translator.Collect();
                        return 0;
        }

        // RVA: 0x1F6EAF8
        public void StepCollect()
        {
                        translator.StepCollect();
        }

        // RVA: 0x1F6EB1C
        public void Dispose()
        {
                        --count;

                        if (count > 0)
                        {
                            return;
                        }

                        IsAlive = false;
                        Dispose(true);            
        }

        // RVA: 0x1F6EBB4
        static ObjectTranslator()
        {

        }
    }
}
