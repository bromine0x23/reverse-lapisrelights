// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.IntervalScheduler
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

namespace Jackpot
{
    public class IntervalScheduler : SchedulerBase
    {
        public static readonly string DefaultName;
        public static readonly bool DefaultIsFollowTimeScale;
        public TimeSpan Interval { get; private set; }
        public float Seconds
        {
            get { return (float)Interval.TotalSeconds; }
            set { Interval = TimeSpan.FromSeconds(value); }
        }
        public float StackTime { get; private set; }


        // RVA: 0x19F312C


        // RVA: 0x19F312C
        public IntervalScheduler(float seconds, Action action)
            : this(DefaultName, TimeSpan.FromSeconds(seconds), delegate { action(); }, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x19F3298
        public IntervalScheduler(float seconds, Action action, bool isFollowTimeScale)
            : this(DefaultName, TimeSpan.FromSeconds(seconds), delegate { action(); }, isFollowTimeScale)
        {
        }

        // RVA: 0x19F3330
        public IntervalScheduler(float seconds, Action<IScheduler> action)
            : this(DefaultName, TimeSpan.FromSeconds(seconds), action, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x19F347C
        public IntervalScheduler(float seconds, Action<IScheduler> action, bool isFollowTimeScale)
            : this(DefaultName, TimeSpan.FromSeconds(seconds), action, isFollowTimeScale)
        {
        }

        // RVA: 0x19F3514
        public IntervalScheduler(string name, float seconds, Action action)
            : this(name, TimeSpan.FromSeconds(seconds), delegate { action(); }, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x19F31C0
        public IntervalScheduler(string name, float seconds, Action action, bool isFollowTimeScale)
            : this(name, TimeSpan.FromSeconds(seconds), delegate { action(); }, isFollowTimeScale)
        {
        }

        // RVA: 0x19F3618
        public IntervalScheduler(string name, float seconds, Action<IScheduler> action)
            : this(name, TimeSpan.FromSeconds(seconds), action, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x19F33C4
        public IntervalScheduler(string name, float seconds, Action<IScheduler> action, bool isFollowTimeScale)
            : this(name, TimeSpan.FromSeconds(seconds), action, isFollowTimeScale)
        {
        }

        // RVA: 0x19F36B0
        public IntervalScheduler(TimeSpan interval, Action action)
            : this(DefaultName, interval, delegate { action(); }, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x19F380C
        public IntervalScheduler(TimeSpan interval, Action action, bool isFollowTimeScale)
            : this(DefaultName, interval, delegate { action(); }, isFollowTimeScale)
        {
        }

        // RVA: 0x19F38A4
        public IntervalScheduler(TimeSpan interval, Action<IScheduler> action)
            : this(DefaultName, interval, action, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x19F39D4
        public IntervalScheduler(TimeSpan interval, Action<IScheduler> action, bool isFollowTimeScale)
            : this(DefaultName, interval, action, isFollowTimeScale)
        {
        }

        // RVA: 0x19F3A6C
        public IntervalScheduler(string name, TimeSpan interval, Action action)
            : this(name, interval, delegate { action(); }, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x19F373C
        public IntervalScheduler(string name, TimeSpan interval, Action action, bool isFollowTimeScale)
            : this(name, interval, delegate { action(); }, isFollowTimeScale)
        {
        }

        // RVA: 0x19F3B70
        public IntervalScheduler(string name, TimeSpan interval, Action<IScheduler> action)
            : this(name, interval, action, DefaultIsFollowTimeScale)
        {
        }

        // RVA: 0x19F3930
        public IntervalScheduler(string name, TimeSpan interval, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        Name = name;
                        this.action = action;
                        Interval = interval;
                        IsFollowTimeScale = isFollowTimeScale;
                        State = SchedulerState.Working;
        }

        // RVA: 0x19F3C08
        protected override void Reset()
        {
                        StackTime = 0f;
        }

        // RVA: 0x19F3C10
        protected override void Work(float delta)
        {
                        StackTime += delta;
                        if (StackTime >= Interval.TotalSeconds)
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

                            StackTime -= Interval.TotalSeconds;
                        }
        }

        // RVA: 0x19F3D6C
        static IntervalScheduler()
        {
                        DefaultName = "Scheduler Schedule";
                        DefaultIsFollowTimeScale = false;
        }
    }
}
