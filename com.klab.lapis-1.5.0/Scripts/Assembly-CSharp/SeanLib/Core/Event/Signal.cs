// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  SeanLib.Core.Event.Signal<T>
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  轻量委托容器：Add 前先 Remove，避免同一监听重复注册。
// =============================================================================

using System;
using System.Text;

namespace SeanLib.Core.Event
{
    public class Signal<T>
    {
        protected Action<T> handler;

        // RVA: 0x1E4564C
        public void AddEventListener(Action<T> handler)
        {
            this.handler = (Action<T>)Delegate.Combine(Delegate.Remove(this.handler, handler), handler);
        }

        // RVA: 0x1E45728
        public void RemoveEventListener(Action<T> handler)
        {
            this.handler = (Action<T>)Delegate.Remove(this.handler, handler);
        }

        // RVA: 0x1E457A4
        public void Clear()
        {
            handler = null;
        }

        // RVA: 0x1E457AC
        public void Dispatch(T arg)
        {
            if (handler != null)
            {
                handler(arg);
            }
        }

        // RVA: 0x1E457CC
        public string DebugString()
        {
            StringBuilder builder = new StringBuilder();
            builder.Append(GetType().Name);
            builder.Append(":");
            if (handler != null)
            {
                Delegate[] invocationList = handler.GetInvocationList();
                for (int i = 0; i < invocationList.Length; i++)
                {
                    builder.Append(invocationList[i].Method.Name);
                    builder.Append("|");
                }
            }
            return builder.ToString();
        }

        // RVA: 0x1E45928
        public Signal()
        {
        }
    }

    public class Signal<T1, T2>
    {
        protected Action<T1, T2> handler;

        public void AddEventListener(Action<T1, T2> handler)
        {
            this.handler = (Action<T1, T2>)Delegate.Combine(Delegate.Remove(this.handler, handler), handler);
        }

        public void RemoveEventListener(Action<T1, T2> handler)
        {
            this.handler = (Action<T1, T2>)Delegate.Remove(this.handler, handler);
        }

        public void Clear()
        {
            handler = null;
        }

        public void Dispatch(T1 arg, T2 arg2)
        {
            if (handler != null)
            {
                handler(arg, arg2);
            }
        }

        public Signal()
        {
        }
    }

    public class Signal<T1, T2, T3>
    {
        protected Action<T1, T2, T3> handler;

        public void AddEventListener(Action<T1, T2, T3> handler)
        {
            this.handler = (Action<T1, T2, T3>)Delegate.Combine(Delegate.Remove(this.handler, handler), handler);
        }

        public void RemoveEventListener(Action<T1, T2, T3> handler)
        {
            this.handler = (Action<T1, T2, T3>)Delegate.Remove(this.handler, handler);
        }

        public void Clear()
        {
            handler = null;
        }

        public void Dispatch(T1 arg, T2 arg2, T3 arg3)
        {
            if (handler != null)
            {
                handler(arg, arg2, arg3);
            }
        }

        public Signal()
        {
        }
    }
}
