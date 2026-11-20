// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.TimelineListener
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Playables;

namespace Oz.Framework
{
    /// <summary>
    /// 监听 PlayableDirector 的播放/暂停/停止事件，并按 <see cref="ePlayableDirectorEvent"/>
    /// 分发给 C# 或 Lua 回调。停止事件会延迟一帧（等待 Timeline 收尾）再分发。
    /// </summary>
    public class TimelineListener : MonoBehaviour
    {
        public class PlayableDirectorTriggerEvent : UnityEvent<PlayableDirector>
        {
            // RVA: 0x2EE86EC
            public PlayableDirectorTriggerEvent()
            {
            }
        }

        public class CPlayableDirectorTriggerEvent : PlayableDirectorTriggerEvent
        {
            public UnityAction<PlayableDirector> callback;

            // RVA: 0x2EE86E8
            public CPlayableDirectorTriggerEvent()
            {
            }

            // RVA: 0x2EE7F50
            public CPlayableDirectorTriggerEvent(UnityAction<PlayableDirector> callback)
            {
                this.callback = callback;
                AddListener(Callback);
            }

            // RVA: 0x2EE873C
            private void Callback(PlayableDirector playableDirector)
            {
                if (callback != null)
                {
                    callback(playableDirector);
                }
            }
        }

        public class LuaPlayableDirectorTriggerEvent : PlayableDirectorTriggerEvent
        {
            public LuaFunction luaFunc;
            public LuaTable luaObject;

            // RVA: 0x2EE87A4
            public LuaPlayableDirectorTriggerEvent()
            {
            }

            // RVA: 0x2EE8190
            public LuaPlayableDirectorTriggerEvent(LuaFunction luaFunc, LuaTable luaObject)
            {
                this.luaFunc = luaFunc;
                this.luaObject = luaObject;
                AddListener(Callback);
            }

            // RVA: 0x2EE87A8
            private void Callback(PlayableDirector playableDirector)
            {
                luaFunc.Call(luaObject, playableDirector);
            }
        }

        public class PlayableDirectorEntry
        {
            public ePlayableDirectorEvent eventID;
            public PlayableDirectorTriggerEvent callback;

            // RVA: 0x2EE7EEC
            public PlayableDirectorEntry()
            {
            }
        }

        [SerializeField]
        private List<PlayableDirectorEntry> m_PlayableDirectorDelegates;
        private PlayableDirector _playableDirector;

        public List<PlayableDirectorEntry> playableDirectorTriggers
        {
            // RVA: 0x2EE76F8
            get
            {
                if (m_PlayableDirectorDelegates == null)
                {
                    m_PlayableDirectorDelegates = new List<PlayableDirectorEntry>();
                }
                return m_PlayableDirectorDelegates;
            }
            // RVA: 0x2EE776C
            set { m_PlayableDirectorDelegates = value; }
        }

        // RVA: 0x2EE7774
        private void Awake()
        {
            _playableDirector = GetComponent<PlayableDirector>();
            _playableDirector.played += OnPlayed;
            _playableDirector.paused += OnPaused;
            _playableDirector.stopped += OnStopped;
        }

        // RVA: 0x2EE78A0
        private void OnDestroy()
        {
            _playableDirector.played -= OnPlayed;
            _playableDirector.paused -= OnPaused;
            _playableDirector.stopped -= OnStopped;
        }

        // RVA: 0x2EE79B4
        private void OnApplicationQuit()
        {
            _playableDirector.played -= OnPlayed;
            _playableDirector.paused -= OnPaused;
            _playableDirector.stopped -= OnStopped;
        }

        // RVA: 0x2EE7AC8
        private void OnPlayed(PlayableDirector playableDirector)
        {
            Dispatch(ePlayableDirectorEvent.OnPlayed, playableDirector);
        }

        // RVA: 0x2EE7BA0
        private void OnPaused(PlayableDirector playableDirector)
        {
            Dispatch(ePlayableDirectorEvent.OnPaused, playableDirector);
        }

        // RVA: 0x2EE7C7C
        private void OnStopped(PlayableDirector playableDirector)
        {
            // 组件处于激活状态时延迟一帧分发，避免与 Timeline 自身的收尾逻辑竞争
            if (isActiveAndEnabled)
            {
                StartCoroutine(_OnStopped(playableDirector));
                return;
            }
            Dispatch(ePlayableDirectorEvent.OnStopped, playableDirector);
        }

        // RVA: 0x2EE7D94（状态机 MoveNext: 0x2EE8548）
        private IEnumerator _OnStopped(PlayableDirector playableDirector)
        {
            yield return new WaitForEndOfFrame();
            Dispatch(ePlayableDirectorEvent.OnStopped, playableDirector);
        }

        private void Dispatch(ePlayableDirectorEvent eventID, PlayableDirector playableDirector)
        {
            int count = playableDirectorTriggers.Count;
            for (int i = 0; i < count; i++)
            {
                PlayableDirectorEntry entry = playableDirectorTriggers[i];
                if (entry.eventID == eventID)
                {
                    entry.callback.Invoke(playableDirector);
                }
            }
        }

        // RVA: 0x2EE7E3C
        public void RegisterTrigger(ePlayableDirectorEvent evenID, UnityAction<PlayableDirector> callback)
        {
            PlayableDirectorEntry entry = new PlayableDirectorEntry();
            entry.eventID = evenID;
            entry.callback = new CPlayableDirectorTriggerEvent(callback);
            playableDirectorTriggers.Add(entry);
        }

        // RVA: 0x2EE7FF0（lambda: 0x2EE8350）
        public void UnregisterTrigger(ePlayableDirectorEvent evenID, UnityAction<PlayableDirector> callback)
        {
            playableDirectorTriggers.RemoveAll(e =>
            {
                CPlayableDirectorTriggerEvent triggerEvent = e.callback as CPlayableDirectorTriggerEvent;
                return triggerEvent != null && e.eventID == evenID && triggerEvent.callback == callback;
            });
        }

        // RVA: 0x2EE80D0
        public void RegisterTriggerLua(ePlayableDirectorEvent evenID, LuaTable luaObject, LuaFunction luaFunc)
        {
            PlayableDirectorEntry entry = new PlayableDirectorEntry();
            entry.eventID = evenID;
            entry.callback = new LuaPlayableDirectorTriggerEvent(luaFunc, luaObject);
            playableDirectorTriggers.Add(entry);
        }

        // RVA: 0x2EE8234（lambda: 0x2EE8428）
        public void UnregisterTriggerLua(ePlayableDirectorEvent evenID, LuaTable luaObject, LuaFunction luaFunc)
        {
            playableDirectorTriggers.RemoveAll(e =>
            {
                LuaPlayableDirectorTriggerEvent triggerEvent = e.callback as LuaPlayableDirectorTriggerEvent;
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

        // RVA: 0x2EE8348
        public TimelineListener()
        {
        }
    }
}
