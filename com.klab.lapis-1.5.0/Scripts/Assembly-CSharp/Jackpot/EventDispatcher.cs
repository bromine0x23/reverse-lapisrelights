// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.EventDispatcher
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jackpot
{
    public class EventDispatcher<TEventArgs>
    {
        private static readonly ILogger logger;
        private readonly List<EventHandlerReference<TEventArgs>> references;
        private int dispatchingCount;

        public int HandlersCount { get { return references.Count; } }
        public bool IsDispatching { get { return dispatchingCount > 0; } }
        public bool HandlerIsEmpty { get { return !references.Exists(reference => !reference.IsHandleOnce); } }
        public bool OnceHandlerIsEmpty { get { return !references.Exists(reference => reference.IsHandleOnce); } }

        public EventDispatcher()
            : this(new List<EventHandlerReference<TEventArgs>>())
        {
        }

        public EventDispatcher(EventDispatcher<TEventArgs> that)
            : this((that != null) ? that.references : new List<EventHandlerReference<TEventArgs>>())
        {
        }

        private EventDispatcher(List<EventHandlerReference<TEventArgs>> references)
        {
            this.references = references;
        }

        ~EventDispatcher()
        {
            RemoveAllHandlers();
        }

        public void AddHandler(EventHandler<TEventArgs> handler, bool isHandleOnce = false)
        {
            AddHandler(null, handler, isHandleOnce);
        }

        public void AddHandler(object target, EventHandler<TEventArgs> handler, bool isHandleOnce = false)
        {
            if (target != null)
            {
                references.Add(new WeakEventHandlerReference<TEventArgs>(target, handler, isHandleOnce));
            }
            else
            {
                references.Add(new HardEventHandlerReference<TEventArgs>(handler, isHandleOnce));
            }
        }

        public bool ContainsHandler(EventHandler<TEventArgs> handler, bool isHandleOnce = false)
        {
            return references.Exists(reference => reference.Handler == handler && reference.IsHandleOnce == isHandleOnce);
        }

        public void RemoveHandler(EventHandler<TEventArgs> handler)
        {
            references.RemoveAll(reference => reference.Handler == handler);
        }

        public void RemoveAllHandlers()
        {
            references.Clear();
        }

        public void RemoveNotAlivedReferences()
        {
            references.RemoveAll(reference => !reference.IsAlive);
        }

        public void Dispatch(TEventArgs eventArgs)
        {
            Dispatch(this, eventArgs);
        }

        public void Dispatch(object sender, TEventArgs eventArgs)
        {
            dispatchingCount++;
            try
            {
                EventHandlerReference<TEventArgs>[] snapshot = references.ToArray();
                foreach (EventHandlerReference<TEventArgs> reference in snapshot)
                {
                    if (!reference.IsAlive)
                    {
                        continue;
                    }

                    reference.Handler(sender, eventArgs);
                    if (reference.IsHandleOnce)
                    {
                        references.Remove(reference);
                    }
                }
            }
            finally
            {
                dispatchingCount--;
            }

            RemoveNotAlivedReferences();
        }

        private void CallbackWithRemoveNotAlivedReferences(Predicate<EventHandlerReference<TEventArgs>> callback)
        {
            references.RemoveAll(callback);
        }

        static EventDispatcher()
        {
            logger = Logger.Get<EventDispatcher<TEventArgs>>();
        }
    }
}
