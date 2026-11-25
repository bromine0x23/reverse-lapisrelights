// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.Delegatable.DelegatableList
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：已还原 List/Count/Get/Set/Contains/Contains(Callback)/Clear/构造。
//        Execute/Execute<T>/Contains(target,method)/Add×4/Remove×4 依赖
//        DelegatableObject 的 Execute/SetEvent/Equals，待后续还原。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Jigbox.Delegatable
{
    public class DelegatableList
    {
        private List<DelegatableObject> delegatableList; // 0x10

        public List<DelegatableObject> List
        {
            // RVA: 0x1CAA7C0
            get { return delegatableList; }
        }

        public int Count
        {
            // RVA: 0x1CA2388
            get { return delegatableList.Count; }
        }

        // RVA: 0x1CAAA90
        public DelegatableObject Get(int index)
        {
            return delegatableList[index];
        }

        // RVA: 0x1CAAB08
        public void Set(int index, DelegatableObject delegatable)
        {
            delegatableList[index] = delegatable;
        }

        // RVA: 0x1CAAB78
        public bool Contains(DelegatableObject del)
        {
            return delegatableList.Contains(del);
        }

        // RVA: 0x1CAABE0
        public bool Contains(DelegatableObject.Callback callback)
        {
            if (callback == null)
            {
                return false;
            }

            for (int i = 0; i < delegatableList.Count; i++)
            {
                if (delegatableList[i].Equals(callback))
                {
                    return true;
                }
            }

            return false;
        }

        // RVA: 0x1CAAC98
        public bool Contains(MonoBehaviour target, string methodName)
        {
            if (target == null || string.IsNullOrEmpty(methodName))
            {
                return false;
            }

            DelegatableObject del = new DelegatableObject();
            del.SetEvent(target, methodName, null);

            for (int i = 0; i < delegatableList.Count; i++)
            {
                if (delegatableList[i].Equals(del))
                {
                    return true;
                }
            }

            return false;
        }

        // RVA: 0x1CAB054
        public bool Add(DelegatableObject del)
        {
            if (del != null && (del.Target != null || del.IsValid))
            {
                delegatableList.Add(del);
                return true;
            }

            return false;
        }

        // RVA: 0x1CAB1D8
        public bool Add(DelegatableObject.Callback callback)
        {
            if (callback == null)
            {
                return false;
            }

            DelegatableObject del = new DelegatableObject();
            del.SetEvent(callback);

            if (!del.IsValid)
            {
                return false;
            }

            delegatableList.Add(del);
            return true;
        }

        // RVA: 0x1CAB368
        public bool Add(Object target, string methodName, object[] args)
        {
            if (target == null || string.IsNullOrEmpty(methodName))
            {
                return false;
            }

            DelegatableObject del = new DelegatableObject();
            del.SetEvent(target, methodName, args);

            if (!del.IsValid)
            {
                return false;
            }

            delegatableList.Add(del);
            return true;
        }

        // RVA: 0x1CA347C
        public bool Add(IEventDelegate eventDelegate)
        {
            DelegatableObject del = new DelegatableObject();
            del.SetEvent(eventDelegate);

            if (!del.IsValid)
            {
                return false;
            }

            delegatableList.Add(del);
            return true;
        }

        // RVA: 0x1CAB474
        public bool Remove(DelegatableObject delegatable)
        {
            if (delegatable != null && delegatableList.Contains(delegatable))
            {
                delegatableList.Remove(delegatable);
                return true;
            }

            return false;
        }

        // RVA: 0x1CAB510
        public bool Remove(DelegatableObject.Callback callback)
        {
            if (callback == null)
            {
                return false;
            }

            for (int i = 0; i < delegatableList.Count; i++)
            {
                if (delegatableList[i].Equals(callback))
                {
                    delegatableList.RemoveAt(i);
                    return true;
                }
            }

            return false;
        }

        // RVA: 0x1CAB60C
        public bool Remove(MonoBehaviour target, string methodName, object[] args)
        {
            if (target == null || string.IsNullOrEmpty(methodName))
            {
                return false;
            }

            DelegatableObject del = new DelegatableObject();
            del.SetEvent(target, methodName, args);

            for (int i = 0; i < delegatableList.Count; i++)
            {
                if (delegatableList[i].Equals(del))
                {
                    delegatableList.RemoveAt(i);
                    return true;
                }
            }

            return false;
        }

        // RVA: 0x1CAB784
        public bool Remove(IEventDelegate eventDelegate)
        {
            for (int i = 0; i < delegatableList.Count; i++)
            {
                if (delegatableList[i].Equals(eventDelegate))
                {
                    delegatableList.RemoveAt(i);
                    return true;
                }
            }

            return false;
        }

        // RVA: 0x1CAA7C8
        public void Execute()
        {
            DelegatableObject.Executes(delegatableList);
        }

        // RVA: 0x146C4B4 (Execute<T> shared implementation)
        public void Execute<T>(T parameter)
        {
            DelegatableObject.Executes(delegatableList, parameter);
        }

        // RVA: 0x1CAA91C
        public void Execute(object[] args)
        {
            DelegatableObject.Executes(delegatableList, args);
        }

        // RVA: 0x1CAB87C
        public void Clear()
        {
            delegatableList.Clear();
        }

        // RVA: 0x1CA372C
        public DelegatableList()
        {
            delegatableList = new List<DelegatableObject>();
        }
    }
}
