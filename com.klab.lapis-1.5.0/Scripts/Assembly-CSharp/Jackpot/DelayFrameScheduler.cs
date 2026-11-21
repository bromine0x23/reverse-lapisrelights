// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.DelayFrameScheduler
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
    public class DelayFrameScheduler : SchedulerBase
    {
        public static readonly string DefaultName;
        public int Delay { get; private set; }
        public int FrameCount { get; private set; }




        // RVA: 0x19E261C
        public DelayFrameScheduler(Action action)
            : this(1, action)
        {
        }

        // RVA: 0x19E26B0
        public DelayFrameScheduler(Action<IScheduler> action)
            : this(1, action)
        {
        }

        // RVA: 0x19E2628
        public DelayFrameScheduler(int frameCount, Action action)
            : this(DefaultName, frameCount, delegate { action(); })
        {
        }

        // RVA: 0x19E26BC
        public DelayFrameScheduler(int frameCount, Action<IScheduler> action)
            : this(DefaultName, frameCount, action)
        {
        }

        // RVA: 0x19E28A4
        public DelayFrameScheduler(string name, Action action)
            : this(name, 1, delegate { action(); })
        {
        }

        // RVA: 0x19E28B0
        public DelayFrameScheduler(string name, Action<IScheduler> action)
            : this(name, 1, action)
        {
        }

        // RVA: 0x19E2744
        public DelayFrameScheduler(string name, int frameCount, Action action)
            : this(name, frameCount, delegate { action(); })
        {
        }

        // RVA: 0x19E280C
        public DelayFrameScheduler(string name, int frameCount, Action<IScheduler> action)
        {
                        Name = name;
                        this.action = action;
                        Delay = frameCount;
                        State = SchedulerState.Working;
        }

        // RVA: 0x19E28C4
        protected override void Reset()
        {
                        FrameCount = 0;
        }

        // RVA: 0x19E28CC
        protected override void Work(float delta)
        {
                        int frameCount = FrameCount + 1;
                        FrameCount = frameCount;
                        if (frameCount >= Delay)
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

        // RVA: 0x19E29F0
        static DelayFrameScheduler()
        {
                        DefaultName = "Scheduler Delay by FrameCount";
        }
    }
}
