// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.AnimationEventListener
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;

namespace Oz.Framework
{
    /// <summary>
    /// 动画事件分发器：Animator 上的 AnimationEvent 调用 <see cref="Exec"/> /
    /// <see cref="ExecString"/>，再按枚举或字符串 ID 分发给 C# / Lua 回调。
    /// </summary>
    public class AnimationEventListener : MonoBehaviour
    {
        public class TriggerEvent : UnityEvent
        {
            // RVA: 0x13F80E8
            public TriggerEvent()
            {
            }
        }

        public class CTriggerEvent : TriggerEvent
        {
            public UnityAction callback;

            // RVA: 0x13F80E0
            public CTriggerEvent()
            {
            }

            // RVA: 0x13F7528
            public CTriggerEvent(UnityAction callback)
            {
                this.callback = callback;
                AddListener(Callback);
            }

            // RVA: 0x13F80F0
            private void Callback()
            {
                if (callback != null)
                {
                    callback();
                }
            }
        }

        public class LuaTriggerEvent : TriggerEvent
        {
            public LuaFunction luaFunc;
            public LuaTable luaObject;

            // RVA: 0x13F810C
            public LuaTriggerEvent()
            {
            }

            // RVA: 0x13F7968
            public LuaTriggerEvent(LuaFunction luaFunc, LuaTable luaObject)
            {
                this.luaFunc = luaFunc;
                this.luaObject = luaObject;
                AddListener(Callback);
            }

            // RVA: 0x13F8114
            private void Callback()
            {
                luaFunc.Call(luaObject);
            }
        }

        public class EntryEnum
        {
            public eAnimEventType eventID;

            // RVA: 0x13F74B8
            public EntryEnum()
            {
            }
        }

        public class EntryString
        {

            // RVA: 0x13F766C
            public EntryString()
            {
            }
        }

        // 元数据中另有 [FormerlySerializedAs]，其原字段名保存在特性 blob 中，无法从 libil2cpp.so 还原
        [SerializeField]
        private List<EntryEnum> m_DelegatesForEnum;
        [SerializeField]
        private List<EntryString> m_DelegatesForString;

        // RVA: 0x13F70B8
        private void Awake()
        {
            Animator animator = GetComponent<Animator>();
            if (animator != null)
            {
                animator.fireEvents = true;
            }
        }

        public List<EntryEnum> triggersForEnum
        {
            // RVA: 0x13F7168
            get
            {
                if (m_DelegatesForEnum == null)
                {
                    m_DelegatesForEnum = new List<EntryEnum>();
                }
                return m_DelegatesForEnum;
            }
            // RVA: 0x13F71DC
            set { m_DelegatesForEnum = value; }
        }

        public List<EntryString> triggersForString
        {
            // RVA: 0x13F71E4
            get
            {
                if (m_DelegatesForString == null)
                {
                    m_DelegatesForString = new List<EntryString>();
                }
                return m_DelegatesForString;
            }
            // RVA: 0x13F7258
            set { m_DelegatesForString = value; }
        }

        /// <summary>由 AnimationEvent 调用：按枚举 ID 分发。</summary>
        // RVA: 0x13F7260
        public void Exec(eAnimEventType id)
        {
            int count = triggersForEnum.Count;
            for (int i = 0; i < count; i++)
            {
                EntryEnum entry = triggersForEnum[i];
                if (entry.eventID == id)
                {
                    entry.callback.Invoke();
                }
            }
        }

        /// <summary>由 AnimationEvent 调用：按字符串 ID 分发。</summary>
        // RVA: 0x13F7330
        public void ExecString(string id)
        {
            int count = triggersForString.Count;
            for (int i = 0; i < count; i++)
            {
                EntryString entry = triggersForString[i];
                if (entry.eventID == id)
                {
                    entry.callback.Invoke();
                }
            }
        }

        // RVA: 0x13F7408
        public void RegisterTrigger(eAnimEventType evenID, UnityAction callback)
        {
            EntryEnum entry = new EntryEnum();
            entry.eventID = evenID;
            entry.callback = new CTriggerEvent(callback);
            triggersForEnum.Add(entry);
        }

        // RVA: 0x13F75BC
        public void RegisterTrigger(string evenID, UnityAction callback)
        {
            EntryString entry = new EntryString();
            entry.eventID = evenID;
            entry.callback = new CTriggerEvent(callback);
            triggersForString.Add(entry);
        }

        // RVA: 0x13F76EC（lambda: 0x13F7CF0）
        public void UnregisterTrigger(eAnimEventType evenID, UnityAction callback)
        {
            triggersForEnum.RemoveAll(e =>
            {
                CTriggerEvent triggerEvent = e.callback as CTriggerEvent;
                return triggerEvent != null && e.eventID == evenID && triggerEvent.callback == callback;
            });
        }

        // RVA: 0x13F77CC（lambda: 0x13F7DC8）
        public void UnregisterTrigger(string evenID, UnityAction callback)
        {
            triggersForString.RemoveAll(e =>
            {
                CTriggerEvent triggerEvent = e.callback as CTriggerEvent;
                return triggerEvent != null && e.eventID == evenID && triggerEvent.callback == callback;
            });
        }

        // RVA: 0x13F78A8
        public void RegisterTriggerLua(eAnimEventType evenID, LuaTable luaObject, LuaFunction luaFunc)
        {
            EntryEnum entry = new EntryEnum();
            entry.eventID = evenID;
            entry.callback = new LuaTriggerEvent(luaFunc, luaObject);
            triggersForEnum.Add(entry);
        }

        // RVA: 0x13F7A00
        public void RegisterTriggerLua(string evenID, LuaTable luaObject, LuaFunction luaFunc)
        {
            EntryString entry = new EntryString();
            entry.eventID = evenID;
            entry.callback = new LuaTriggerEvent(luaFunc, luaObject);
            triggersForString.Add(entry);
        }

        // RVA: 0x13F7AC0（lambda: 0x13F7EA0）
        public void UnregisterTriggerLua(eAnimEventType evenID, LuaTable luaObject, LuaFunction luaFunc)
        {
            triggersForEnum.RemoveAll(e =>
            {
                LuaTriggerEvent triggerEvent = e.callback as LuaTriggerEvent;
                if (triggerEvent != null && e.eventID == evenID
                    && triggerEvent.luaFunc == luaFunc && triggerEvent.luaObject == luaObject)
                {
                    // 命中后释放条目内持有的 Lua 引用（RemoveAll 谓词内的两次 Dispose 虚调用已由反汇编确认）
                    triggerEvent.luaFunc.Dispose();
                    triggerEvent.luaObject.Dispose();
                    return true;
                }
                return false;
            });
            // 传入的 Lua 引用同样被释放（RemoveAll 之后对 luaFunc/luaObject 的 Dispose 已由反汇编确认）
            luaFunc.Dispose();
            luaObject.Dispose();
        }

        // RVA: 0x13F7BD4（lambda: 0x13F7FBC）
        public void UnregisterTriggerLua(string evenID, LuaTable luaObject, LuaFunction luaFunc)
        {
            triggersForString.RemoveAll(e =>
            {
                LuaTriggerEvent triggerEvent = e.callback as LuaTriggerEvent;
                if (triggerEvent != null && e.eventID == evenID
                    && triggerEvent.luaFunc == luaFunc && triggerEvent.luaObject == luaObject)
                {
                    // 命中后释放条目内持有的 Lua 引用（RemoveAll 谓词内的两次 Dispose 虚调用已由反汇编确认）
                    triggerEvent.luaFunc.Dispose();
                    triggerEvent.luaObject.Dispose();
                    return true;
                }
                return false;
            });
            // 传入的 Lua 引用同样被释放（RemoveAll 之后对 luaFunc/luaObject 的 Dispose 已由反汇编确认）
            luaFunc.Dispose();
            luaObject.Dispose();
        }

        // RVA: 0x13F7CE8
        public AnimationEventListener()
        {
        }
    }
}
