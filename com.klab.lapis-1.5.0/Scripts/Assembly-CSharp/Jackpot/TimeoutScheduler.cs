// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.TimeoutScheduler
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

namespace Jackpot
{
    public class TimeoutScheduler : SchedulerBase
    {
        public static readonly string DefaultName;
        public static readonly bool DefaultIsFollowTimeScale;
        public float Delay { get; private set; }
        public float TotalDeltaTime { get; private set; }




        // RVA: 0x16BC67C
        public TimeoutScheduler(float seconds, Action action)
            : this(DefaultName, seconds, delegate { action(); }, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x16BC7E8
        public TimeoutScheduler(float seconds, Action action, bool isFollowTimeScale)
            : this(DefaultName, seconds, delegate { action(); }, isFollowTimeScale)
        {
        }

        // RVA: 0x16BC880
        public TimeoutScheduler(float seconds, Action<IScheduler> action)
            : this(DefaultName, seconds, action, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x16BC9C0
        public TimeoutScheduler(float seconds, Action<IScheduler> action, bool isFollowTimeScale)
            : this(DefaultName, seconds, action, isFollowTimeScale)
        {
        }

        // RVA: 0x16BCA58
        public TimeoutScheduler(string name, float seconds, Action action)
            : this(name, seconds, delegate { action(); }, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x16BC710
        public TimeoutScheduler(string name, float seconds, Action action, bool isFollowTimeScale)
            : this(name, seconds, delegate { action(); }, isFollowTimeScale)
        {
        }

        // RVA: 0x16BCB5C
        public TimeoutScheduler(string name, float seconds, Action<IScheduler> action)
            : this(name, seconds, action, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x16BC914
        public TimeoutScheduler(string name, float seconds, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        Name = name;
                        this.action = action;
                        Delay = seconds;
                        IsFollowTimeScale = isFollowTimeScale;
                        State = SchedulerState.Working;
        }

        // RVA: 0x16BCBF4
        public TimeoutScheduler(int milliSeconds, Action action)
            : this(DefaultName, milliSeconds / 1000f, delegate { action(); }, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x16BCD5C
        public TimeoutScheduler(int milliSeconds, Action action, bool isFollowTimeScale)
            : this(DefaultName, milliSeconds / 1000f, delegate { action(); }, isFollowTimeScale)
        {
        }

        // RVA: 0x16BCDF4
        public TimeoutScheduler(int milliSeconds, Action<IScheduler> action)
            : this(DefaultName, milliSeconds / 1000f, action, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x16BCEAC
        public TimeoutScheduler(int milliSeconds, Action<IScheduler> action, bool isFollowTimeScale)
            : this(DefaultName, milliSeconds / 1000f, action, isFollowTimeScale)
        {
        }

        // RVA: 0x16BCF50
        public TimeoutScheduler(string name, int milliSeconds, Action action)
            : this(name, milliSeconds / 1000f, delegate { action(); }, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x16BCC80
        public TimeoutScheduler(string name, int milliSeconds, Action action, bool isFollowTimeScale)
            : this(name, milliSeconds / 1000f, delegate { action(); }, isFollowTimeScale)
        {
        }

        // RVA: 0x16BD060
        public TimeoutScheduler(string name, int milliSeconds, Action<IScheduler> action)
            : this(name, milliSeconds / 1000f, action, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x16BCE8C
        public TimeoutScheduler(string name, int milliSeconds, Action<IScheduler> action, bool isFollowTimeScale)
            : this(name, milliSeconds / 1000f, action, isFollowTimeScale)
        {
        }

        // RVA: 0x16BD104
        protected override void Reset()
        {
                        TotalDeltaTime = 0f;
        }

        // RVA: 0x16BD10C
        protected override void Work(float delta)
        {
                        TotalDeltaTime += delta;
                        if (TotalDeltaTime >= Delay)
                        {
                            try
                            {
                                action?.Invoke(this);
                            }
                            catch (Exception e)
                            {
                                if (ExceptionCallback != null)
                                {
                                    ExceptionCallback(e);
                                }
                            }

                            Finish();
                        }
        }

        // RVA: 0x16BD240
        static TimeoutScheduler()
        {
                        DefaultName = "Scheduler Delay by Time";
                        DefaultIsFollowTimeScale = false;
        }
    }
}
