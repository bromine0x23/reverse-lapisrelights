// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.JniAttachSection
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
    public class JniAttachSection : IDisposable
    {
        private static Dictionary<int, int> threadTable;
        private static object lockObject;
        private readonly bool mainThread;
        private bool disposed;

        // RVA: 0x19F3E44
        public JniAttachSection()
        {
                        mainThread = MainThreadDispatcher.IsMainThread;
                        AcquireSection();
        }

        // RVA: 0x19F4154
        ~JniAttachSection()
        {
                        Dispose(false);
        }

        // RVA: 0x19F41C8
        public void Dispose()
        {
                        Dispose(true);
                        GC.SuppressFinalize(this);
        }

        // RVA: 0x19F4244
        protected virtual void Dispose(bool disposing)
        {
                        if (disposed)
                        {
                            return;
                        }

                        ReleaseSection();
                        disposed = true;
        }

        // RVA: 0x19F3F4C
        private void AcquireSection()
        {
                        if (mainThread)
                        {
                            return;
                        }

                        int managedThreadId = Thread.CurrentThread.ManagedThreadId;
                        lock (lockObject)
                        {
                            if (threadTable.ContainsKey(managedThreadId))
                            {
                                threadTable[managedThreadId]++;
                            }
                            else
                            {
                                threadTable.Add(managedThreadId, 1);
                                AndroidJNI.AttachCurrentThread();
                            }
                        }
        }

        // RVA: 0x19F4278
        private void ReleaseSection()
        {
                        if (mainThread)
                        {
                            return;
                        }

                        int managedThreadId = Thread.CurrentThread.ManagedThreadId;
                        lock (lockObject)
                        {
                            if (!threadTable.ContainsKey(managedThreadId))
                            {
                                throw new InvalidOperationException("Section to release does not exist.");
                            }

                            int num = threadTable[managedThreadId] - 1;
                            threadTable[managedThreadId] = num;
                            if (num == 0)
                            {
                                AndroidJNI.DetachCurrentThread();
                                threadTable.Remove(managedThreadId);
                            }
                        }
        }

        // RVA: 0x19F44C8
        static JniAttachSection()
        {
                        threadTable = new Dictionary<int, int>();
                        lockObject = new object();
        }
    }
}
