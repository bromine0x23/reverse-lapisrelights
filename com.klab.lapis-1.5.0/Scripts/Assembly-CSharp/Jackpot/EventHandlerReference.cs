// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.EventHandlerReference / HardEventHandlerReference /
//  WeakEventHandlerReference
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using UnityEngine;

namespace Jackpot
{
    public abstract class EventHandlerReference<TEventArgs>
    {
        public bool IsHandleOnce { get; private set; }

        public abstract bool IsAlive { get; }
        public abstract EventHandler<TEventArgs> Handler { get; protected set; }

        protected EventHandlerReference(bool isHandleOnce)
        {
            IsHandleOnce = isHandleOnce;
        }
    }

    public class HardEventHandlerReference<TEventArgs> : EventHandlerReference<TEventArgs>
    {
        public override bool IsAlive { get { return Handler != null; } }
        public override EventHandler<TEventArgs> Handler { get; protected set; }

        public HardEventHandlerReference(EventHandler<TEventArgs> handler, bool isHandleOnce)
            : base(isHandleOnce)
        {
            Handler = handler;
        }
    }

    public class WeakEventHandlerReference<TEventArgs> : EventHandlerReference<TEventArgs>
    {
        private WeakReference handlerReference;
        private readonly WeakReference targetReference;

        public override bool IsAlive
        {
            get
            {
                if (targetReference == null || !targetReference.IsAlive)
                {
                    return false;
                }

                if (handlerReference == null || !handlerReference.IsAlive)
                {
                    return false;
                }

                object target = targetReference.Target;
                if (target is MonoBehaviour behaviour)
                {
                    return behaviour != null;
                }

                if (target is GameObject gameObject)
                {
                    return gameObject != null;
                }

                return true;
            }
        }

        public override EventHandler<TEventArgs> Handler
        {
            get
            {
                if (handlerReference == null)
                {
                    return null;
                }

                return (EventHandler<TEventArgs>)handlerReference.Target;
            }
            protected set
            {
                handlerReference = new WeakReference(value);
            }
        }

        public WeakEventHandlerReference(object target, EventHandler<TEventArgs> handler, bool isHandleOnce)
            : base(isHandleOnce)
        {
            targetReference = new WeakReference(target);
            Handler = handler;
        }
    }
}
