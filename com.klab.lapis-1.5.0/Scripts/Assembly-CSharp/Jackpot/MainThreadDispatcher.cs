// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.MainThreadDispatcher
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
    public class MainThreadDispatcher : MonoBehaviour
    {
        private static readonly Action<Exception> DefaultExceptionCallback;
        private static readonly object lifecycleLock;
        private static Action<Exception> exceptionCallback;
        private static MainThreadDispatcher instance;
        private static bool initialized;
        private static bool quitting;
        private static int mainThreadId;
        private ActionQueue queue;
        private static Action<Exception> ExceptionCallback { get { Initialize(); return exceptionCallback; } set { Initialize(); exceptionCallback = value ?? DefaultExceptionCallback; } }
        public static bool IsMainThread { get { Initialize(); return Thread.CurrentThread.ManagedThreadId == mainThreadId; } }
        private static MainThreadDispatcher Instance { get { Initialize(); return instance; } }
        // RVA: 0x19F5570
        private static Action<Exception> get_ExceptionCallback()
        {
            Initialize();
            return exceptionCallback;
        }

        // RVA: 0x19F5AAC
        public static void set_ExceptionCallback(Action<Exception> value)
        {
            Initialize();
            exceptionCallback = value ?? DefaultExceptionCallback;
        }

        // RVA: 0x19F3EC0
        public static bool get_IsMainThread()
        {
            Initialize();
            return Thread.CurrentThread.ManagedThreadId == mainThreadId;
        }

        // RVA: 0x19F5B58
        private static MainThreadDispatcher get_Instance()
        {
            Initialize();
            return instance;
        }

        // RVA: 0x19F5BC4
        private void Update()
        {
                        if (queue != null)
                        {
                            queue.ProcessAll(ExceptionCallback);
                        }
        }

        // RVA: 0x19F5C48
        private void OnDestroy()
        {
                        lock (lifecycleLock)
                        {
                            instance = null;
                            mainThreadId = 0;
                            initialized = false;
                        }
        }

        // RVA: 0x19F5D48
        private void OnApplicationQuit()
        {
                        quitting = true;
        }

        // RVA: 0x19F55DC
        public static void Initialize()
        {
                        if (quitting)
                        {
                            return;
                        }

                        lock (lifecycleLock)
                        {
                            if (initialized)
                            {
                                return;
                            }

                            try
                            {
                                GameObject gameObject = new GameObject("MainThreadDispatcher");
                                UnityEngine.Object.DontDestroyOnLoad(gameObject);
                                instance = gameObject.AddComponent<MainThreadDispatcher>();
                                mainThreadId = Thread.CurrentThread.ManagedThreadId;
                                initialized = true;
                            }
                            catch
                            {
                                if (instance != null)
                                {
                                    UnityEngine.Object.Destroy(instance);
                                }

                                instance = null;
                                Logger.Get<MainThreadDispatcher>().Error(new Exception("Require a MainThreadDispatcher component create on main thread."), Array.Empty<object>());
                                throw;
                            }
                        }
        }

        // RVA: 0x19F5DB4
        public static void Post(Action action)
        {
                        Action capturedAction = action;
                        string stackTrace = Environment.StackTrace;
                        if (quitting)
                        {
                            return;
                        }

                        Instance.queue.Enqueue(delegate
                        {
                            try
                            {
                                capturedAction();
                            }
                            catch (Exception e)
                            {
                                throw new MainThreadDispatcherException(stackTrace, e);
                            }
                        });
        }

        // RVA: 0x19F5ED4
        public static void Post(IEnumerator enumerator)
        {
                        IEnumerator capturedEnumerator = enumerator;
                        if (quitting)
                        {
                            return;
                        }

                        Instance.queue.Enqueue(delegate
                        {
                            Instance.StartCoroutine(capturedEnumerator);
                        });
        }

        // RVA: 0x19F5FE8
        public static void Send(Action action)
        {
                        if (action == null || quitting)
                        {
                            return;
                        }

                        if (IsMainThread)
                        {
                            try
                            {
                                action();
                            }
                            catch (Exception e)
                            {
                                ExceptionCallback?.Invoke(e);
                            }

                            return;
                        }

                        Post(action);
        }

        // RVA: 0x19F6168
        public static Coroutine Send(IEnumerator enumerator)
        {
                        if (enumerator == null || quitting)
                        {
                            return null;
                        }

                        if (IsMainThread)
                        {
                            return Instance.StartCoroutine(enumerator);
                        }

                        Post(enumerator);
                        return null;
        }

        // RVA: 0x19F625C
        public static void SendAndWait(Action action)
        {
                        if (quitting || action == null)
                        {
                            return;
                        }

                        if (IsMainThread)
                        {
                            action();
                            return;
                        }

                        Action capturedAction = action;
                        using (ManualResetEvent manualResetEvent = new ManualResetEvent(false))
                        {
                            Post(delegate
                            {
                                capturedAction();
                                manualResetEvent.Set();
                            });
                            manualResetEvent.WaitOne();
                        }
        }

        // RVA: 0x19F6548
        public MainThreadDispatcher()
        {
                        queue = new ActionQueue();
        }

        // RVA: 0x19F65B0
        static MainThreadDispatcher()
        {
                        DefaultExceptionCallback = delegate(Exception e)
                        {
                            Logger.Get<MainThreadDispatcher>().Error(e, Array.Empty<object>());
                        };
                        lifecycleLock = new object();
                        exceptionCallback = DefaultExceptionCallback;
        }
    }
}
