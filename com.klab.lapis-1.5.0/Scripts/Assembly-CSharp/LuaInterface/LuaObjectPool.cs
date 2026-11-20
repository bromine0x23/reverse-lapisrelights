// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaObjectPool
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
    public class LuaObjectPool
    {
        private List<LuaObjectPool.PoolNode> list;
        private LuaObjectPool.PoolNode head;
        private int count;
        private int collectStep;
        private int collectedIndex;
        public object Item { get; }

        // RVA: 0x229CCCC
        public LuaObjectPool()
        {
                        list = new List<PoolNode>(1024);
                        head = new PoolNode(0, null);
                        list.Add(head);
                        list.Add(new PoolNode(1, null));
                        count = list.Count;
        }

        // RVA: 0x229CE24
        public object get_Item(int i)
        {
            if (i < 1 || i >= count)
            {
                return null;
            }
            return list[i].obj;
        }

        // RVA: 0x229CEC0
        public void Clear()
        {
                        //_call = null;
                        _add = null;
                        _remove = null;
                        self = null;            
                        luaState = null;
        }

        // RVA: 0x229CF24
        public int Add(object obj)
        {
                        int pos = -1;

                        if (head.index != 0)
                        {
                            pos = head.index;
                            list[pos].obj = obj;
                            head.index = list[pos].index;
                        }
                        else
                        {
                            pos = list.Count;
                            list.Add(new PoolNode(pos, obj));
                            count = pos + 1;
                        }

                        return pos;
        }

        // RVA: 0x229D050
        public object TryGetValue(int index)
        {
                        if (index > 0 && index < count)
                        {
                            return list[index].obj;                
                        }

                        return null;
        }

        // RVA: 0x229D0EC
        public object Remove(int pos)
        {
                        if (pos > 0 && pos < count)
                        {
                            object o = list[pos].obj;
                            list[pos].obj = null;                
                            list[pos].index = head.index;
                            head.index = pos;

                            return o;
                        }

                        return null;
        }

        // RVA: 0x229D210
        public object Destroy(int pos)
        {
                        if (pos > 0 && pos < count)
                        {
                            object o = list[pos].obj;
                            list[pos].obj = null;
                            return o;
                        }

                        return null;
        }

        // RVA: 0x229D2E4
        public void StepCollect(Action<object, int> collectListener)
        {
                        ++collectedIndex;
                        for (int i = 0; i < collectStep; ++i)
                        {
                            collectedIndex += i;
                            if (collectedIndex >= count)
                            {
                                collectedIndex = -1;
                                return;
                            }

                            var node = list[collectedIndex];
                            object o = node.obj;
                            if (o != null && o.Equals(null))
                            {
                                node.obj = null;
                                if (collectListener != null)
                                {
                                    collectListener(o, collectedIndex);
                                }
                            }
                        }
        }

        // RVA: 0x229D420
        public object Replace(int pos, object o)
        {
                        if (pos > 0 && pos < count)
                        {
                            object obj = list[pos].obj;
                            list[pos].obj = o;
                            return obj;
                        }

                        return null;
        }
    }
}
