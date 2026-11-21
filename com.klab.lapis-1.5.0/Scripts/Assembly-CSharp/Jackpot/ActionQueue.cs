// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.ActionQueue
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
    public class ActionQueue
    {
        private static readonly Action<Exception> DefaultExceptionCallback;
        private readonly List<Action>[] buffers;
        private int frontBufferIndex;
        private object gate;
        private bool isDequeing;
        private List<Action> frontBuffer { get { return buffers[frontBufferIndex]; } }
        public bool IsProcessing { get { return isDequeing; } }
        public int Count
        {
            get
            {
                lock (gate)
                {
                    return frontBuffer.Count;
                }
            }
        }
        // RVA: 0x1763C18
        private List<Action> get_frontBuffer()
        {
            return buffers[frontBufferIndex];
        }

        // RVA: 0x1763C58
        public bool get_IsProcessing()
        {
            return isDequeing;
        }

        // RVA: 0x1763C60
        public int get_Count()
        {
            lock (gate)
            {
                return frontBuffer.Count;
            }
        }

        // RVA: 0x1763D24
        public ActionQueue()
        {
                        buffers = new List<Action>[2]
                        {
                            new List<Action>(),
                            new List<Action>()
                        };
                        frontBufferIndex = 0;
                        gate = new object();
                        isDequeing = false;
        }

        // RVA: 0x1763E6C
        public void Enqueue(Action action)
        {
                        lock (gate)
                        {
                            frontBuffer.Add(action);
                        }
        }

        // RVA: 0x1763F40
        private List<Action> SwapBuffers()
        {
                        int index = frontBufferIndex;
                        frontBufferIndex = ((index == 1) ? 0 : 1);
                        return buffers[index];
        }

        // RVA: 0x1763F90
        public void Process(Action<Exception> exceptionCallback)
        {
                        Action action;
                        lock (gate)
                        {
                            if (isDequeing)
                            {
                                ExecuteExeptionCallback(exceptionCallback, new InvalidOperationException("Queue already executing"));
                                return;
                            }

                            List<Action> list = frontBuffer;
                            if (list.Count <= 0)
                            {
                                return;
                            }

                            isDequeing = true;
                            action = list[0];
                            list.RemoveAt(0);
                        }

                        try
                        {
                            action();
                        }
                        catch (Exception e)
                        {
                            ExecuteExeptionCallback(exceptionCallback, e);
                        }
                        finally
                        {
                            lock (gate)
                            {
                                isDequeing = false;
                            }
                        }
        }

        // RVA: 0x1764314
        public void ProcessAll(Action<Exception> exceptionCallback)
        {
                        List<Action> list;
                        lock (gate)
                        {
                            if (isDequeing)
                            {
                                ExecuteExeptionCallback(exceptionCallback, new InvalidOperationException("Queue already executing"));
                                return;
                            }

                            isDequeing = true;
                            list = SwapBuffers();
                        }

                        try
                        {
                            for (int i = 0; i < list.Count; i++)
                            {
                                try
                                {
                                    list[i]();
                                }
                                catch (Exception e)
                                {
                                    ExecuteExeptionCallback(exceptionCallback, e);
                                }
                            }
                        }
                        finally
                        {
                            list.Clear();
                            lock (gate)
                            {
                                isDequeing = false;
                            }
                        }
        }

        // RVA: 0x17645E8
        public void ProcessWhile(uint milliSeconds, Action<Exception> exceptionCallback)
        {
                        DateTime dateTime = DateTime.Now.AddMilliseconds(milliSeconds);
                        while (Count >= 1 && dateTime > DateTime.Now)
                        {
                            Process(exceptionCallback);
                        }
        }

        // RVA: 0x1764270
        private void ExecuteExeptionCallback(Action<Exception> exceptionCallback, Exception e)
        {
                        if (exceptionCallback != null)
                        {
                            exceptionCallback(e);
                        }
                        else
                        {
                            DefaultExceptionCallback(e);
                        }
        }

        // RVA: 0x17646D8
        static ActionQueue()
        {
                        DefaultExceptionCallback = delegate(Exception e)
                        {
                            Logger.Get<ActionQueue>().Error(e, Array.Empty<object>());
                        };
        }
    }
}
