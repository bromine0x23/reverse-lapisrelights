// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.BindableObject
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jackpot
{
    public class BindableObject<T>
    {
        private static readonly Func<T, T, bool> DefaultChangesPolicy;
        private T value;
        private EventDispatcher<PropertyChangedEventArgs<T>> dispatcher;
        private Func<T, T, bool> changesPolicy;

        public T Value
        {
            get { return value; }
            set
            {
                ValidateCallStackChanging();
                T oldValue = this.value;
                this.value = value;
                if (changesPolicy != null && !changesPolicy(oldValue, value))
                {
                    return;
                }

                if (!IsDispatchable())
                {
                    return;
                }

                dispatcher.Dispatch(this, PropertyChangedEventArgs<T>.Update(oldValue, value));
            }
        }
        public BindableRules Rule { get; set; }

        public BindableObject()
            : this(default(T))
        {
        }

        public BindableObject(T value)
            : this(value, BindableRules.NotAllowCallStackChanging)
        {
        }

        public BindableObject(T value, BindableRules rule)
        {
            this.value = value;
            Rule = rule;
            dispatcher = new EventDispatcher<PropertyChangedEventArgs<T>>();
            changesPolicy = DefaultChangesPolicy;
        }

        public BindableObject(BindableObject<T> that)
            : this(that, true)
        {
        }

        public BindableObject(BindableObject<T> that, bool withCopyBinding)
            : this(that, withCopyBinding, false)
        {
        }

        public BindableObject(BindableObject<T> that, bool withCopyBinding, bool withCopyValue)
        {
            if (withCopyValue && that.value is ICloneable cloneable)
            {
                value = (T)cloneable.Clone();
            }
            else
            {
                value = that.value;
            }

            Rule = that.Rule;
            dispatcher = (withCopyBinding ? new EventDispatcher<PropertyChangedEventArgs<T>>(that.dispatcher) : new EventDispatcher<PropertyChangedEventArgs<T>>());
            changesPolicy = that.changesPolicy;
        }

        public void Bind(EventHandler<PropertyChangedEventArgs<T>> binder)
        {
            dispatcher.AddHandler(binder, false);
        }

        public void Bind(object target, EventHandler<PropertyChangedEventArgs<T>> binder)
        {
            dispatcher.AddHandler(target, binder, false);
        }

        public void BindOnce(EventHandler<PropertyChangedEventArgs<T>> binder)
        {
            dispatcher.AddHandler(binder, true);
        }

        public void BindOnce(object target, EventHandler<PropertyChangedEventArgs<T>> binder)
        {
            dispatcher.AddHandler(target, binder, true);
        }

        public bool IsBinding()
        {
            return !dispatcher.HandlerIsEmpty;
        }

        public bool IsBinding(EventHandler<PropertyChangedEventArgs<T>> binder)
        {
            return dispatcher.ContainsHandler(binder, false);
        }

        public bool IsBindingOnce()
        {
            return !dispatcher.OnceHandlerIsEmpty;
        }

        public bool IsBindingOnce(EventHandler<PropertyChangedEventArgs<T>> binder)
        {
            return dispatcher.ContainsHandler(binder, true);
        }

        public void Unbind(EventHandler<PropertyChangedEventArgs<T>> binder)
        {
            dispatcher.RemoveHandler(binder);
        }

        public void UnBindAll()
        {
            dispatcher.RemoveAllHandlers();
        }

        public void SetChangesPolicy(Func<T, T, bool> changesPolicy)
        {
            this.changesPolicy = changesPolicy;
        }

        public void ForceUpdate()
        {
            ValidateCallStackChanging();
            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, PropertyChangedEventArgs<T>.ForceUpdate(value));
            }
        }

        public virtual object Clone()
        {
            return Clone(true);
        }

        public virtual object Clone(bool withCopyBinding)
        {
            return Clone(withCopyBinding, false);
        }

        public virtual object Clone(bool withCopyBinding, bool withCopyValue)
        {
            return new BindableObject<T>(this, withCopyBinding, withCopyValue);
        }

        public override string ToString()
        {
            return value.ToString();
        }

        [Obsolete]
        public bool Equals(object objA, object objB)
        {
            return object.Equals(objA, objB);
        }

        [Obsolete]
        public bool Equals(T x, T y)
        {
            return EqualityComparer<T>.Default.Equals(x, y);
        }

        [Obsolete]
        public int GetHashCode(T obj)
        {
            return obj.GetHashCode();
        }

        protected virtual void ValidateCallStackChanging()
        {
            if (Rule != BindableRules.NotAllowCallStackChanging)
            {
                return;
            }

            if (dispatcher.IsDispatching)
            {
                throw new InvalidOperationException("A value cannot be changed while dispatching data.");
            }
        }

        protected bool IsDispatchable()
        {
            if (!dispatcher.IsDispatching)
            {
                return true;
            }

            return Rule != BindableRules.ThroughCallStackChanging;
        }

        static BindableObject()
        {
            DefaultChangesPolicy = delegate (T x, T y)
            {
                return !EqualityComparer<T>.Default.Equals(x, y);
            };
        }
    }
}
