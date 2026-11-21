// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Case
//  来源：libil2cpp.so (ARM64) 反汇编 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jackpot
{
    public static partial class Case
    {
        public interface IApplyer<T1, T2>
        {
            void Apply(T1 candidate1, T2 candidate2);
        }

        public interface IMatcher<T1, T2> : IApplyer<T1, T2>
        {
            IMatcher<T1, T2> When(T1 value1, T2 value2, Action callback);

            IMatcher<T1, T2> When(T1 value1, T2 value2, Action<T1, T2> callback);

            IMatcher<T1, T2> When(Func<T1, T2, bool> predicate, Action callback);

            IMatcher<T1, T2> When(Func<T1, T2, bool> predicate, Action<T1, T2> callback);

            IMatcher<T1, T2> Default(Action defaultCallback);

            IMatcher<T1, T2> Default(Action<T1, T2> defaultCallback);
        }

        public interface IApplyer<T1>
        {
            void Apply(T1 candidate1);
        }

        public interface IMatcher<T1> : IApplyer<T1>
        {
            IMatcher<T1> When(T1 value1, Action callback);

            IMatcher<T1> When(T1 value1, Action<T1> callback);

            IMatcher<T1> When(Func<T1, bool> predicate, Action callback);

            IMatcher<T1> When(Func<T1, bool> predicate, Action<T1> callback);

            IMatcher<T1> Default(Action defaultCallback);

            IMatcher<T1> Default(Action<T1> defaultCallback);
        }

        public class ActionMatcher<T1, T2> : IMatcher<T1, T2>
        {
            private class Pair
            {
                public Func<T1, T2, bool> predicate;
                public Action<T1, T2> callback;
            }

            private readonly List<Pair> pairs = new List<Pair>();
            private Action<T1, T2> defaultCallback;

            public ActionMatcher(Func<T1, T2, bool> predicate, Action<T1, T2> callback)
            {
                pairs.Add(new Pair
                {
                    predicate = predicate,
                    callback = callback
                });
            }

            public IMatcher<T1, T2> When(T1 value1, T2 value2, Action callback)
            {
                return When((T1 a, T2 b) => EqualityComparer<T1>.Default.Equals(a, value1) && EqualityComparer<T2>.Default.Equals(b, value2), (T1 a, T2 b) => callback());
            }

            public IMatcher<T1, T2> When(T1 value1, T2 value2, Action<T1, T2> callback)
            {
                return When((T1 a, T2 b) => EqualityComparer<T1>.Default.Equals(a, value1) && EqualityComparer<T2>.Default.Equals(b, value2), callback);
            }

            public IMatcher<T1, T2> When(Func<T1, T2, bool> predicate, Action callback)
            {
                return When(predicate, (T1 a, T2 b) => callback());
            }

            public IMatcher<T1, T2> When(Func<T1, T2, bool> predicate, Action<T1, T2> callback)
            {
                pairs.Add(new Pair
                {
                    predicate = predicate,
                    callback = callback
                });
                return this;
            }

            public IMatcher<T1, T2> Default(Action defaultCallback)
            {
                return Default((T1 a, T2 b) => defaultCallback());
            }

            public IMatcher<T1, T2> Default(Action<T1, T2> defaultCallback)
            {
                this.defaultCallback = defaultCallback;
                return this;
            }

            public void Apply(T1 candidate1, T2 candidate2)
            {
                foreach (Pair pair in pairs)
                {
                    if (pair.predicate(candidate1, candidate2))
                    {
                        pair.callback(candidate1, candidate2);
                        return;
                    }
                }

                if (defaultCallback != null)
                {
                    defaultCallback(candidate1, candidate2);
                }
            }
        }

        public class ActionMatcher<T1> : IMatcher<T1>
        {
            private class Pair
            {
                public Func<T1, bool> predicate;
                public Action<T1> callback;
            }

            private readonly List<Pair> pairs = new List<Pair>();
            private Action<T1> defaultCallback;

            public ActionMatcher(Func<T1, bool> predicate, Action<T1> callback)
            {
                pairs.Add(new Pair
                {
                    predicate = predicate,
                    callback = callback
                });
            }

            public IMatcher<T1> When(T1 value1, Action callback)
            {
                return When((T1 a) => EqualityComparer<T1>.Default.Equals(a, value1), (T1 a) => callback());
            }

            public IMatcher<T1> When(T1 value1, Action<T1> callback)
            {
                return When((T1 a) => EqualityComparer<T1>.Default.Equals(a, value1), callback);
            }

            public IMatcher<T1> When(Func<T1, bool> predicate, Action callback)
            {
                return When(predicate, (T1 a) => callback());
            }

            public IMatcher<T1> When(Func<T1, bool> predicate, Action<T1> callback)
            {
                pairs.Add(new Pair
                {
                    predicate = predicate,
                    callback = callback
                });
                return this;
            }

            public IMatcher<T1> Default(Action defaultCallback)
            {
                return Default((T1 a) => defaultCallback());
            }

            public IMatcher<T1> Default(Action<T1> defaultCallback)
            {
                this.defaultCallback = defaultCallback;
                return this;
            }

            public void Apply(T1 candidate1)
            {
                foreach (Pair pair in pairs)
                {
                    if (pair.predicate(candidate1))
                    {
                        pair.callback(candidate1);
                        return;
                    }
                }

                if (defaultCallback != null)
                {
                    defaultCallback(candidate1);
                }
            }
        }

        // RVA: 0x1789578
        internal static void ValidateWhenArguments(object predicate, object callback)
        {
            if (predicate == null)
            {
                throw new ArgumentNullException("predicate");
            }

            if (callback == null)
            {
                throw new ArgumentNullException("callback");
            }
        }

        // RVA: 0x1789624
        static Case()
        {
        }
    }
}
