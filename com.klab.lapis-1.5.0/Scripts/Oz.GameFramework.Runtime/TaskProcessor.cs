// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.IExecutor<T> / SpawnPool<T> / Processor<T>
//  来源：Il2CppDumper 元数据 + 共享泛型实例反汇编
//  共享泛型 RVA（<object> / <DownloadTask> 实例）：
//    SpawnPool<T>  ctor 0x1E43450  Spawn 0x1E434C8  Recycle 0x1E43544  Clear 0x1E4356C（均为 virtual，槽 4/5/6）
//    Processor<T>  ctor 0x1E41B4C  Update 0x1E41C84  ProcessWorking 0x1E41CD4  ProcessWaiting 0x1E41F50
//                  AddExecutor 0x1E42118  AddTask 0x1E42148  RemoveTask 0x1E421C8  ClearTask 0x1E42438
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;

namespace Oz.GameFramework.Runtime
{
    /// <summary>任务执行器：由 Processor 在空闲栈与工作链表之间调度。</summary>
    public interface IExecutor<T>
    {
        T Task { get; }

        bool IsDone { get; }

        void Update(float realtimeSinceStartup);

        void Reset();

        void Start(T task);
    }

    /// <summary>对象池：栈式复用，空时经 Activator 新建。</summary>
    public class SpawnPool<T>
    {
        private Stack<T> m_Objects;

        public SpawnPool()
        {
            m_Objects = new Stack<T>();
        }

        public virtual T Spawn()
        {
            if (m_Objects.Count >= 1)
            {
                return m_Objects.Pop();
            }

            return Activator.CreateInstance<T>();
        }

        public virtual void Recycle(T obj)
        {
            m_Objects.Push(obj);
        }

        public virtual void Clear()
        {
            m_Objects.Clear();
        }
    }

    /// <summary>任务处理器：空闲执行器栈 + 工作执行器链表 + 等待任务链表（含 handle → 节点索引）。</summary>
    public class Processor<T> where T : Task
    {
        private Stack<IExecutor<T>> m_IdleExecutors;
        private LinkedList<IExecutor<T>> m_WorkingExecutors;
        private LinkedList<T> m_WaitingTasks;
        private Dictionary<TaskHandle, LinkedListNode<T>> m_HandleToWaitingTask;

        public Processor()
        {
            m_IdleExecutors = new Stack<IExecutor<T>>();
            m_WorkingExecutors = new LinkedList<IExecutor<T>>();
            m_WaitingTasks = new LinkedList<T>();
            m_HandleToWaitingTask = new Dictionary<TaskHandle, LinkedListNode<T>>();
        }

        public void Update()
        {
            ProcessWorking();
            ProcessWaiting();
        }

        private void ProcessWorking()
        {
            LinkedListNode<IExecutor<T>> node = m_WorkingExecutors.First;
            while (node != null)
            {
                IExecutor<T> executor = node.Value;
                float now = Time.realtimeSinceStartup;
                executor.Update(now);

                LinkedListNode<IExecutor<T>> next = node.Next;
                if (executor.IsDone)
                {
                    executor.Reset();
                    m_IdleExecutors.Push(executor);
                    m_WorkingExecutors.Remove(node);
                }

                node = next;
            }
        }

        private void ProcessWaiting()
        {
            LinkedListNode<T> node = m_WaitingTasks.First;
            while (node != null)
            {
                if (m_IdleExecutors.Count <= 0)
                {
                    return;
                }

                LinkedListNode<T> next = node.Next;
                T task = node.Value;

                m_HandleToWaitingTask.Remove(task.Handle);
                m_WaitingTasks.Remove(node);

                IExecutor<T> executor = m_IdleExecutors.Pop();
                executor.Start(task);
                m_WorkingExecutors.AddLast(executor);

                node = next;
            }
        }

        public void AddExecutor(IExecutor<T> executor)
        {
            if (executor != null)
            {
                m_IdleExecutors.Push(executor);
            }
        }

        public void AddTask(T task, bool prior = false)
        {
            LinkedListNode<T> node = prior
                ? m_WaitingTasks.AddFirst(task)
                : m_WaitingTasks.AddLast(task);

            m_HandleToWaitingTask.Add(task.Handle, node);
        }

        public void RemoveTask(TaskHandle handle)
        {
            LinkedListNode<T> waiting;
            if (m_HandleToWaitingTask.TryGetValue(handle, out waiting))
            {
                m_WaitingTasks.Remove(waiting);
                m_HandleToWaitingTask.Remove(handle);
                return;
            }

            LinkedListNode<IExecutor<T>> node = m_WorkingExecutors.First;
            while (node != null)
            {
                IExecutor<T> executor = node.Value;
                if (executor.Task.Handle.Equals(handle))
                {
                    executor.Reset();
                    m_WorkingExecutors.Remove(node);
                    m_IdleExecutors.Push(executor);
                    return;
                }

                node = node.Next;
            }
        }

        public void ClearTask()
        {
            m_WaitingTasks.Clear();
            m_HandleToWaitingTask.Clear();

            LinkedListNode<IExecutor<T>> node = m_WorkingExecutors.First;
            while (node != null)
            {
                LinkedListNode<IExecutor<T>> next = node.Next;
                IExecutor<T> executor = node.Value;

                executor.Reset();
                m_WorkingExecutors.Remove(node);
                m_IdleExecutors.Push(executor);

                node = next;
            }
        }
    }
}
