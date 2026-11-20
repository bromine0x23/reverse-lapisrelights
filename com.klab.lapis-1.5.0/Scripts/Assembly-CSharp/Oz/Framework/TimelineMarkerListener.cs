// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.TimelineMarkerListener
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using LuaInterface;
using Oz.Timeline;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Framework
{
    /// <summary>
    /// 接收 Timeline 的 <see cref="EventMarker"/> 通知，按事件名分发给已注册的
    /// C# 或 Lua 回调。
    /// </summary>
    public class TimelineMarkerListener : MonoBehaviour, INotificationReceiver
    {
        /// <summary>Timeline 事件回调载体（UnityEvent，便于在 Inspector 中配置）。</summary>
        public class MarkerTriggerEvent : UnityEvent<Playable, EventData>
        {
            // RVA: 0x2EE9180
            public MarkerTriggerEvent()
            {
            }
        }

        /// <summary>C# 委托形式的事件回调。</summary>
        public class CMarkerTriggerEvent : MarkerTriggerEvent
        {
            public UnityAction<Playable, EventData> callback;

            // RVA: 0x2EE917C
            public CMarkerTriggerEvent()
            {
            }

            // RVA: 0x2EE8B84
            public CMarkerTriggerEvent(UnityAction<Playable, EventData> callback)
            {
                this.callback = callback;
                AddListener(Callback);
            }

            // RVA: 0x2EE91D0
            private void Callback(Playable playable, EventData data)
            {
                if (callback != null)
                {
                    callback(playable, data);
                }
            }
        }

        /// <summary>Lua 函数形式的事件回调。</summary>
        public class LuaMarkerTriggerEvent : MarkerTriggerEvent
        {
            public LuaFunction luaFunc;
            public LuaTable luaObject;

            // RVA: 0x2EE9250
            public LuaMarkerTriggerEvent()
            {
            }

            // RVA: 0x2EE8DC0
            public LuaMarkerTriggerEvent(LuaFunction luaFunc, LuaTable luaObject)
            {
                this.luaFunc = luaFunc;
                this.luaObject = luaObject;
                AddListener(Callback);
            }

            // RVA: 0x2EE9254
            private void Callback(Playable playable, EventData data)
            {
                luaFunc.Call(luaObject, playable, data);
            }
        }

        public class EventMarkerEntry
        {
            public string eventID;
            public MarkerTriggerEvent callback;

            // RVA: 0x2EE8B08
            public EventMarkerEntry()
            {
            }
        }

        [SerializeField]
        private List<EventMarkerEntry> m_PlayableClipDelegates;

        public List<EventMarkerEntry> eventMarkerTriggers
        {
            // RVA: 0x2EE8814
            get
            {
                if (m_PlayableClipDelegates == null)
                {
                    m_PlayableClipDelegates = new List<EventMarkerEntry>();
                }
                return m_PlayableClipDelegates;
            }
            // RVA: 0x2EE8888
            set { m_PlayableClipDelegates = value; }
        }

        // RVA: 0x2EE8890
        public void OnNotify(Playable origin, INotification notification, object context)
        {
            EventMarker marker = notification as EventMarker;
            if (marker == null)
            {
                return;
            }

            PlayableGraph graph = origin.GetGraph();
            marker.EventData.ResolveEventArgs(graph.GetResolver());

            int count = eventMarkerTriggers.Count;
            for (int i = 0; i < count; i++)
            {
                EventMarkerEntry entry = eventMarkerTriggers[i];
                if (entry.eventID == marker.EventName)
                {
                    entry.callback.Invoke(origin, marker.EventData);
                }
            }
        }

        // RVA: 0x2EE8A58
        public void RegisterTrigger(string eventName, UnityAction<Playable, EventData> callback)
        {
            EventMarkerEntry entry = new EventMarkerEntry();
            entry.eventID = eventName;
            entry.callback = new CMarkerTriggerEvent(callback);
            eventMarkerTriggers.Add(entry);
        }

        // RVA: 0x2EE8C24（lambda: 0x2EE8F80）
        public void UnregisterTrigger(string evenName, UnityAction<Playable, EventData> callback)
        {
            eventMarkerTriggers.RemoveAll(e =>
            {
                CMarkerTriggerEvent markerEvent = e.callback as CMarkerTriggerEvent;
                return markerEvent != null && e.eventID == evenName && markerEvent.callback == callback;
            });
        }

        // RVA: 0x2EE8D00
        public void RegisterTriggerLua(string evenName, LuaTable luaObject, LuaFunction luaFunc)
        {
            EventMarkerEntry entry = new EventMarkerEntry();
            entry.eventID = evenName;
            entry.callback = new LuaMarkerTriggerEvent(luaFunc, luaObject);
            eventMarkerTriggers.Add(entry);
        }

        // RVA: 0x2EE8E64（lambda: 0x2EE9058）
        public void UnregisterTriggerLua(string evenName, LuaTable luaObject, LuaFunction luaFunc)
        {
            eventMarkerTriggers.RemoveAll(e =>
            {
                LuaMarkerTriggerEvent markerEvent = e.callback as LuaMarkerTriggerEvent;
                if (markerEvent != null && e.eventID == evenName
                    && markerEvent.luaFunc == luaFunc && markerEvent.luaObject == luaObject)
                {
                    // 命中后释放条目内持有的 Lua 引用（RemoveAll 谓词内的两次 Dispose 虚调用已由反汇编确认）
                    markerEvent.luaFunc.Dispose();
                    markerEvent.luaObject.Dispose();
                    return true;
                }
                return false;
            });
            // 传入的 Lua 引用同样被释放（RemoveAll 之后对 luaFunc/luaObject 的 Dispose 已由反汇编确认）
            luaFunc.Dispose();
            luaObject.Dispose();
        }

        // RVA: 0x2EE8F78
        public TimelineMarkerListener()
        {
        }
    }
}
