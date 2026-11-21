// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.SchedulerBase
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
    public class SchedulerBase : IScheduler
    {
        private static readonly Action<Exception> DefaultExceptionCallback;
        protected Action<IScheduler> action;
        private long timeTicks;
        public SchedulerState State { get; protected set; }
        public bool IsFollowTimeScale { get; protected set; }
        public string Name { get; protected set; }
        protected Action<Exception> ExceptionCallback { get; set; }

        // RVA: 0x1EA4900
        public SchedulerBase()
        {
                        ExceptionCallback = DefaultExceptionCallback;
                        timeTicks = DateTime.Now.Ticks;
        }

        // RVA: 0x1EA4748
        public bool Update(float delta, float unscaled)
        {
                        if (timeTicks >= 1)
                        {
                            long num = DateTime.Now.Ticks - timeTicks;
                            timeTicks = 0L;
                            float num2 = (float)num / 10000000f;
                            delta += num2;
                            unscaled += num2;
                        }

                        if (State == SchedulerState.Working)
                        {
                            Work(IsFollowTimeScale ? unscaled : delta);
                        }

                        return State == SchedulerState.Done;
        }

        // RVA: 0x1EA49C4
        public void Pause()
        {
                        if (State != SchedulerState.Done)
                        {
                            State = SchedulerState.Waiting;
                        }
        }

        // RVA: 0x1EA49D8
        public void Resume()
        {
                        if (State != SchedulerState.Done)
                        {
                            State = SchedulerState.Working;
                        }
        }

        // RVA: 0x1EA49F0
        public void Restart()
        {
                        if (State == SchedulerState.Done)
                        {
                            return;
                        }

                        Reset();
                        State = SchedulerState.Working;
        }

        // RVA: 0x1EA4A30
        public void Finish()
        {
                        action = null;
                        State = SchedulerState.Done;
        }

        // RVA: 0x1EA4A40
        public void FinishWithAction()
        {
                        try
                        {
                            if (action != null && State != SchedulerState.Done)
                            {
                                action(this);
                            }
                        }
                        catch (Exception e)
                        {
                            if (ExceptionCallback != null)
                            {
                                ExceptionCallback(e);
                            }
                        }

                        State = SchedulerState.Done;
                        action = null;
        }

        // RVA: 0x1EA4B4C
        protected virtual void Reset()
        {
                        throw new NotImplementedException();
        }

        // RVA: 0x1EA4BAC
        protected virtual void Work(float delta)
        {
                        throw new NotImplementedException();
        }

        // RVA: 0x1EA4C0C
        static SchedulerBase()
        {
                        DefaultExceptionCallback = delegate(Exception e)
                        {
                            Logger.Get<SchedulerBase>().Error(e, Array.Empty<object>());
                        };
        }
    }
}
