// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  TimeLine.Event
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  Timeline 全局信号中心：暂停等待、恢复、片段播放/暂停事件。
// =============================================================================

using System.Collections.Generic;
using UnityEngine.Playables;
using SeanLib.Core.Event;

namespace TimeLine
{
    public class Event
    {
        private static Event m_Instace;
        public Signal<Behaviour.Context> OnAwait;
        public Signal<Behaviour.Context> OnResume;
        public Signal<Behaviour.Context> OnClipPlay;
        public Signal<Behaviour.Context> OnClipPause;
        public Dictionary<string, Signal<Behaviour.Context>> CustomEvents;
        public HashSet<Behaviour.Context> Awaittings;

        public static Event Instace
        {
            // RVA: 0x144CE0C
            get
            {
                if (m_Instace == null)
                {
                    m_Instace = new Event();
                }
                return m_Instace;
            }
        }

        // RVA: 0x144D74C
        public Event()
        {
            OnAwait = new Signal<Behaviour.Context>();
            OnResume = new Signal<Behaviour.Context>();
            OnClipPlay = new Signal<Behaviour.Context>();
            OnClipPause = new Signal<Behaviour.Context>();
            CustomEvents = new Dictionary<string, Signal<Behaviour.Context>>();
            Awaittings = new HashSet<Behaviour.Context>();
            OnResume.AddEventListener(DefaultResume);
            OnAwait.AddEventListener(DefaultAwait);
        }

        // RVA: 0x144D8F8
        public void ResumeAll()
        {
            foreach (Behaviour.Context context in Awaittings)
            {
                OnResume.Dispatch(context);
            }
            Awaittings.Clear();
        }

        // RVA: 0x144DA1C
        public void ResumeAwaiting(Behaviour.Context waitingObj)
        {
            if (Awaittings.Contains(waitingObj))
            {
                OnResume.Dispatch(waitingObj);
                Awaittings.Remove(waitingObj);
            }
        }

        // RVA: 0x144DAD0
        private void DefaultAwait(Behaviour.Context obj)
        {
            Awaittings.Add(obj);
            obj.director.Pause();
        }

        // RVA: 0x144DB4C
        private void DefaultResume(Behaviour.Context obj)
        {
            if (obj.director != null && obj.director.state == PlayState.Paused)
            {
                obj.director.Resume();
            }
        }
    }
}
