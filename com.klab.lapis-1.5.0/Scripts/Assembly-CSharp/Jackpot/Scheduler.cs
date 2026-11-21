// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Scheduler
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
    public class Scheduler : MonoBehaviour
    {
        private List<IScheduler> workers;
        private List<IScheduler> addWorkers;
        private static Scheduler instance;
        private static object syncRoot;
        private static Scheduler Instance { get { return get_Instance(); } }
        // RVA: 0x1EA21A0
        private static Scheduler get_Instance()
        {
            if (instance == null)
            {
                lock (syncRoot)
                {
                    if (instance == null)
                    {
                        instance = new GameObject("Scheduler").AddComponent<Scheduler>();
                        UnityEngine.Object.DontDestroyOnLoad(instance.gameObject);
                    }
                }
            }

            return instance;
        }

        // RVA: 0x1EA242C
        public static void Clear()
        {
                        if (Instance != null)
                        {
                            Instance.workers.Clear();
                            Instance.addWorkers.Clear();
                            UnityEngine.Object.Destroy(Instance.gameObject);
                            Instance = null;
                        }
        }

        // RVA: 0x1EA259C
        private void Update()
        {
                        float deltaTime = Time.deltaTime;
                        float unscaledDeltaTime = Time.unscaledDeltaTime;
                        workers.RemoveAll((IScheduler worker) => ((SchedulerBase)worker).Update(deltaTime, unscaledDeltaTime));
        }

        // RVA: 0x1EA2678
        private void LateUpdate()
        {
                        workers.AddRange(addWorkers);
                        addWorkers.Clear();
        }

        // RVA: 0x1EA26EC
        public static IScheduler DelayMilliSeconds(int milliSeconds, Action action)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(milliSeconds, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA27A8
        public static IScheduler DelayMilliSeconds(int milliSeconds, Action action, bool isFollowTimeScale)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(milliSeconds, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA286C
        public static IScheduler DelayMilliSeconds(int milliSeconds, Action<IScheduler> action)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(milliSeconds, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA2928
        public static IScheduler DelayMilliSeconds(int milliSeconds, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(milliSeconds, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA29EC
        public static IScheduler DelayMilliSeconds(string name, int milliSeconds, Action action)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(name, milliSeconds, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA2AB0
        public static IScheduler DelayMilliSeconds(string name, int milliSeconds, Action action, bool isFollowTimeScale)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(name, milliSeconds, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA2B84
        public static IScheduler DelayMilliSeconds(string name, int milliSeconds, Action<IScheduler> action)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(name, milliSeconds, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA2C48
        public static IScheduler DelayMilliSeconds(string name, int milliSeconds, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(name, milliSeconds, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA2D1C
        public static IScheduler DelaySeconds(float seconds, Action action)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(seconds, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA2DD8
        public static IScheduler DelaySeconds(float seconds, Action action, bool isFollowTimeScale)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(seconds, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA2EA4
        public static IScheduler DelaySeconds(float seconds, Action<IScheduler> action)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(seconds, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA2F60
        public static IScheduler DelaySeconds(float seconds, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(seconds, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA302C
        public static IScheduler DelaySeconds(string name, float seconds, Action action)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(name, seconds, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA30F8
        public static IScheduler DelaySeconds(string name, float seconds, Action action, bool isFollowTimeScale)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(name, seconds, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA31CC
        public static IScheduler DelaySeconds(string name, float seconds, Action<IScheduler> action)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(name, seconds, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3298
        public static IScheduler DelaySeconds(string name, float seconds, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        TimeoutScheduler scheduler = new TimeoutScheduler(name, seconds, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA336C
        public static IScheduler DelayFrame(Action action)
        {
                        DelayFrameScheduler scheduler = new DelayFrameScheduler(action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3418
        public static IScheduler DelayFrame(Action<IScheduler> action)
        {
                        DelayFrameScheduler scheduler = new DelayFrameScheduler(action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA34C4
        public static IScheduler DelayFrame(int frameCount, Action action)
        {
                        DelayFrameScheduler scheduler = new DelayFrameScheduler(frameCount, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3580
        public static IScheduler DelayFrame(int frameCount, Action<IScheduler> action)
        {
                        DelayFrameScheduler scheduler = new DelayFrameScheduler(frameCount, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA363C
        public static IScheduler DelayFrame(string name, Action action)
        {
                        DelayFrameScheduler scheduler = new DelayFrameScheduler(name, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA36F8
        public static IScheduler DelayFrame(string name, Action<IScheduler> action)
        {
                        DelayFrameScheduler scheduler = new DelayFrameScheduler(name, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA37B4
        public static IScheduler DelayFrame(string name, int frameCount, Action action)
        {
                        DelayFrameScheduler scheduler = new DelayFrameScheduler(name, frameCount, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3878
        public static IScheduler DelayFrame(string name, int frameCount, Action<IScheduler> action)
        {
                        DelayFrameScheduler scheduler = new DelayFrameScheduler(name, frameCount, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA393C
        public static IScheduler Schedule(float interval, Action action)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(interval, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA39F8
        public static IScheduler Schedule(float interval, Action action, bool isFollowTimeScale)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(interval, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3AC4
        public static IScheduler Schedule(float interval, Action<IScheduler> action)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(interval, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3B80
        public static IScheduler Schedule(float interval, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(interval, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3C4C
        public static IScheduler Schedule(string name, float interval, Action action)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(name, interval, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3D18
        public static IScheduler Schedule(string name, float interval, Action action, bool isFollowTimeScale)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(name, interval, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3DEC
        public static IScheduler Schedule(string name, float interval, Action<IScheduler> action)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(name, interval, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3EB8
        public static IScheduler Schedule(string name, float interval, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(name, interval, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA3F8C
        public static IScheduler Schedule(TimeSpan interval, Action action)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(interval, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA4048
        public static IScheduler Schedule(TimeSpan interval, Action action, bool isFollowTimeScale)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(interval, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA410C
        public static IScheduler Schedule(TimeSpan interval, Action<IScheduler> action)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(interval, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA41C8
        public static IScheduler Schedule(TimeSpan interval, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(interval, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA428C
        public static IScheduler Schedule(string name, TimeSpan interval, Action action)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(name, interval, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA4350
        public static IScheduler Schedule(string name, TimeSpan interval, Action action, bool isFollowTimeScale)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(name, interval, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA4424
        public static IScheduler Schedule(string name, TimeSpan interval, Action<IScheduler> action)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(name, interval, action);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA44E8
        public static IScheduler Schedule(string name, TimeSpan interval, Action<IScheduler> action, bool isFollowTimeScale)
        {
                        IntervalScheduler scheduler = new IntervalScheduler(name, interval, action, isFollowTimeScale);
                        Instance.addWorkers.Add(scheduler);
                        return scheduler;
        }

        // RVA: 0x1EA45BC
        public Scheduler()
        {
                        workers = new List<IScheduler>();
                        addWorkers = new List<IScheduler>();
        }

        // RVA: 0x1EA464C
        static Scheduler()
        {
                        syncRoot = new object();
        }
    }
}
