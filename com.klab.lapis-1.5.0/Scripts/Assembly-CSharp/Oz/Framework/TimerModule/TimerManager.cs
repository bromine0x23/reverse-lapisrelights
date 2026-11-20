// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.TimerModule.TimerManager
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using LuaInterface;
using UnityEngine;

namespace Oz.Framework.TimerModule
{
    /// <summary>
    /// 定时器管理器（由 Launcher 装配到自身 GameObject）。每帧遍历链表，
    /// 到期则执行 Lua 回调，并据重复次数决定重置或销毁。
    /// </summary>
    public class TimerManager : MonoBehaviour
    {
        private static TimerManager Instance { get; set; }

        private LinkedList<Timer> m_LinkedTimers;
        private Dictionary<int, Timer> m_DictTimers;
        private int m_TimerID;

        // RVA: 0x2EE97A0
        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
            }
            m_TimerID = 0;
            m_LinkedTimers = new LinkedList<Timer>();
            m_DictTimers = new Dictionary<int, Timer>(1024);
        }

        // RVA: 0x2EE98DC
        private void OnDestroy()
        {
            m_LinkedTimers.Clear();
            m_DictTimers.Clear();
            m_TimerID = 0;
            if (Instance != null)
            {
                Instance = null;
            }
        }

        // RVA: 0x2EE99F0
        private void Update()
        {
            for (LinkedListNode<Timer> node = m_LinkedTimers.First; node != null; )
            {
                LinkedListNode<Timer> next = node.Next;
                Timer timer = node.Value;
                if (timer.Valid)
                {
                    if (timer.IsTimeUp())
                    {
                        timer.Execute();
                        if (timer.Repeat)
                        {
                            timer.Reset();
                        }
                        else
                        {
                            m_LinkedTimers.Remove(node);
                            m_DictTimers.Remove(timer.ID);
                            timer.Dispose();
                        }
                    }
                }
                else
                {
                    // 已被 Kill 的定时器直接清理
                    m_LinkedTimers.Remove(node);
                    m_DictTimers.Remove(timer.ID);
                    timer.Dispose();
                }
                node = next;
            }
        }

        /// <summary>按 <see cref="eTimerType"/> 创建定时器，返回其 ID（非法类型返回 -1）。</summary>
        // RVA: 0x2EE9CC4
        private int AddTimerInternal(int timerType, float delayTime, LuaFunction luaFunction, LuaTable luaObject, int repeatCount = 0)
        {
            int id = ++m_TimerID;
            Timer timer;
            switch (timerType)
            {
                case (int)eTimerType.ScaleTime:
                    timer = new OzScaleTimer(id, delayTime, luaFunction, luaObject, repeatCount);
                    break;
                case (int)eTimerType.UnscaleTime:
                    timer = new UnscaleTimer(id, delayTime, luaFunction, luaObject, repeatCount);
                    break;
                case (int)eTimerType.RealTime:
                    timer = new RealTimer(id, delayTime, luaFunction, luaObject, repeatCount);
                    break;
                case (int)eTimerType.FrameCount:
                    timer = new FrameTimer(id, (int)delayTime, luaFunction, luaObject, repeatCount);
                    break;
                default:
                    m_TimerID--;
                    return -1;
            }

            m_LinkedTimers.AddLast(timer);
            m_DictTimers.Add(m_TimerID, timer);
            return m_TimerID;
        }

        // RVA: 0x2EE9EB4
        private void RemoveTimerInternal(int timerID)
        {
            Timer timer;
            if (m_DictTimers.TryGetValue(timerID, out timer))
            {
                // 伪代码此处直接写入 _valid=0（Kill 被内联）
                timer.Kill();
            }
        }

        // RVA: 0x2EE9F38
        public static int AddTimer(int timerType, float delayTime, LuaFunction luaFunction, LuaTable luaObject, int repeatCount = 0)
        {
            if (Instance == null)
            {
                return -1;
            }
            return Instance.AddTimerInternal(timerType, delayTime, luaFunction, luaObject, repeatCount);
        }

        // RVA: 0x2EEA07C
        public static void RemoveTimer(int timerID)
        {
            if (Instance != null)
            {
                Instance.RemoveTimerInternal(timerID);
            }
        }

        // RVA: 0x2EEA178
        public TimerManager()
        {
        }
    }
}
