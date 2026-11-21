// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Case (result matcher family)
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jackpot
{
    public static partial class Case
    {
        public interface IApplyer<T1, TResult>
        {
            TResult Apply(T1 candidate1);
        }

        public interface IResultMatcher<T1, TResult> : IApplyer<T1, TResult>
        {
            IResultMatcher<T1, TResult> When(T1 value1, TResult result);
            IResultMatcher<T1, TResult> When(T1 value1, Func<TResult> callback);
            IResultMatcher<T1, TResult> When(T1 value1, Func<T1, TResult> callback);
            IResultMatcher<T1, TResult> When(Func<T1, bool> predicate, TResult result);
            IResultMatcher<T1, TResult> When(Func<T1, bool> predicate, Func<TResult> callback);
            IResultMatcher<T1, TResult> When(Func<T1, bool> predicate, Func<T1, TResult> callback);
            IResultMatcher<T1, TResult> Default(TResult result);
            IResultMatcher<T1, TResult> Default(Func<TResult> callback);
            IResultMatcher<T1, TResult> Default(Func<T1, TResult> callback);
        }

        public class ResultMatcher<T1, TResult> : IResultMatcher<T1, TResult>
        {
            private class Pair
            {
                public Func<T1, bool> predicate;
                public Func<T1, TResult> callback;
            }

            private readonly List<Pair> pairs = new List<Pair>();
            private Func<T1, TResult> defaultCallback;

            public ResultMatcher(Func<T1, bool> predicate, Func<T1, TResult> callback)
            {
                pairs.Add(new Pair { predicate = predicate, callback = callback });
            }

            public IResultMatcher<T1, TResult> When(T1 value1, TResult result)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1), (T1 a1) => result);
            }

            public IResultMatcher<T1, TResult> When(T1 value1, Func<TResult> callback)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1), (T1 a1) => callback());
            }

            public IResultMatcher<T1, TResult> When(T1 value1, Func<T1, TResult> callback)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1), callback);
            }

            public IResultMatcher<T1, TResult> When(Func<T1, bool> predicate, TResult result)
            {
                return When(predicate, (T1 a1) => result);
            }

            public IResultMatcher<T1, TResult> When(Func<T1, bool> predicate, Func<TResult> callback)
            {
                return When(predicate, (T1 a1) => callback());
            }

            public IResultMatcher<T1, TResult> When(Func<T1, bool> predicate, Func<T1, TResult> callback)
            {
                pairs.Add(new Pair { predicate = predicate, callback = callback });
                return this;
            }

            public IResultMatcher<T1, TResult> Default(TResult result)
            {
                return Default((T1 a1) => result);
            }

            public IResultMatcher<T1, TResult> Default(Func<TResult> callback)
            {
                return Default((T1 a1) => callback());
            }

            public IResultMatcher<T1, TResult> Default(Func<T1, TResult> callback)
            {
                defaultCallback = callback;
                return this;
            }

            public TResult Apply(T1 candidate1)
            {
                foreach (Pair pair in pairs)
                {
                    if (pair.predicate(candidate1))
                    {
                        return pair.callback(candidate1);
                    }
                }

                if (defaultCallback != null)
                {
                    return defaultCallback(candidate1);
                }

                return default(TResult);
            }
        }

        public interface IApplyer<T1, T2, TResult>
        {
            TResult Apply(T1 candidate1, T2 candidate2);
        }

        public interface IResultMatcher<T1, T2, TResult> : IApplyer<T1, T2, TResult>
        {
            IResultMatcher<T1, T2, TResult> When(T1 value1, T2 value2, TResult result);
            IResultMatcher<T1, T2, TResult> When(T1 value1, T2 value2, Func<TResult> callback);
            IResultMatcher<T1, T2, TResult> When(T1 value1, T2 value2, Func<T1, T2, TResult> callback);
            IResultMatcher<T1, T2, TResult> When(Func<T1, T2, bool> predicate, TResult result);
            IResultMatcher<T1, T2, TResult> When(Func<T1, T2, bool> predicate, Func<TResult> callback);
            IResultMatcher<T1, T2, TResult> When(Func<T1, T2, bool> predicate, Func<T1, T2, TResult> callback);
            IResultMatcher<T1, T2, TResult> Default(TResult result);
            IResultMatcher<T1, T2, TResult> Default(Func<TResult> callback);
            IResultMatcher<T1, T2, TResult> Default(Func<T1, T2, TResult> callback);
        }

        public class ResultMatcher<T1, T2, TResult> : IResultMatcher<T1, T2, TResult>
        {
            private class Pair
            {
                public Func<T1, T2, bool> predicate;
                public Func<T1, T2, TResult> callback;
            }

            private readonly List<Pair> pairs = new List<Pair>();
            private Func<T1, T2, TResult> defaultCallback;

            public ResultMatcher(Func<T1, T2, bool> predicate, Func<T1, T2, TResult> callback)
            {
                pairs.Add(new Pair { predicate = predicate, callback = callback });
            }

            public IResultMatcher<T1, T2, TResult> When(T1 value1, T2 value2, TResult result)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1) && EqualityComparer<T2>.Default.Equals(a2, value2), (T1 a1, T2 a2) => result);
            }

            public IResultMatcher<T1, T2, TResult> When(T1 value1, T2 value2, Func<TResult> callback)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1) && EqualityComparer<T2>.Default.Equals(a2, value2), (T1 a1, T2 a2) => callback());
            }

            public IResultMatcher<T1, T2, TResult> When(T1 value1, T2 value2, Func<T1, T2, TResult> callback)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1) && EqualityComparer<T2>.Default.Equals(a2, value2), callback);
            }

            public IResultMatcher<T1, T2, TResult> When(Func<T1, T2, bool> predicate, TResult result)
            {
                return When(predicate, (T1 a1, T2 a2) => result);
            }

            public IResultMatcher<T1, T2, TResult> When(Func<T1, T2, bool> predicate, Func<TResult> callback)
            {
                return When(predicate, (T1 a1, T2 a2) => callback());
            }

            public IResultMatcher<T1, T2, TResult> When(Func<T1, T2, bool> predicate, Func<T1, T2, TResult> callback)
            {
                pairs.Add(new Pair { predicate = predicate, callback = callback });
                return this;
            }

            public IResultMatcher<T1, T2, TResult> Default(TResult result)
            {
                return Default((T1 a1, T2 a2) => result);
            }

            public IResultMatcher<T1, T2, TResult> Default(Func<TResult> callback)
            {
                return Default((T1 a1, T2 a2) => callback());
            }

            public IResultMatcher<T1, T2, TResult> Default(Func<T1, T2, TResult> callback)
            {
                defaultCallback = callback;
                return this;
            }

            public TResult Apply(T1 candidate1, T2 candidate2)
            {
                foreach (Pair pair in pairs)
                {
                    if (pair.predicate(candidate1, candidate2))
                    {
                        return pair.callback(candidate1, candidate2);
                    }
                }

                if (defaultCallback != null)
                {
                    return defaultCallback(candidate1, candidate2);
                }

                return default(TResult);
            }
        }

        public interface IApplyer<T1, T2, T3, TResult>
        {
            TResult Apply(T1 candidate1, T2 candidate2, T3 candidate3);
        }

        public interface IResultMatcher<T1, T2, T3, TResult> : IApplyer<T1, T2, T3, TResult>
        {
            IResultMatcher<T1, T2, T3, TResult> When(T1 value1, T2 value2, T3 value3, TResult result);
            IResultMatcher<T1, T2, T3, TResult> When(T1 value1, T2 value2, T3 value3, Func<TResult> callback);
            IResultMatcher<T1, T2, T3, TResult> When(T1 value1, T2 value2, T3 value3, Func<T1, T2, T3, TResult> callback);
            IResultMatcher<T1, T2, T3, TResult> When(Func<T1, T2, T3, bool> predicate, TResult result);
            IResultMatcher<T1, T2, T3, TResult> When(Func<T1, T2, T3, bool> predicate, Func<TResult> callback);
            IResultMatcher<T1, T2, T3, TResult> When(Func<T1, T2, T3, bool> predicate, Func<T1, T2, T3, TResult> callback);
            IResultMatcher<T1, T2, T3, TResult> Default(TResult result);
            IResultMatcher<T1, T2, T3, TResult> Default(Func<TResult> callback);
            IResultMatcher<T1, T2, T3, TResult> Default(Func<T1, T2, T3, TResult> callback);
        }

        public class ResultMatcher<T1, T2, T3, TResult> : IResultMatcher<T1, T2, T3, TResult>
        {
            private class Pair
            {
                public Func<T1, T2, T3, bool> predicate;
                public Func<T1, T2, T3, TResult> callback;
            }

            private readonly List<Pair> pairs = new List<Pair>();
            private Func<T1, T2, T3, TResult> defaultCallback;

            public ResultMatcher(Func<T1, T2, T3, bool> predicate, Func<T1, T2, T3, TResult> callback)
            {
                pairs.Add(new Pair { predicate = predicate, callback = callback });
            }

            public IResultMatcher<T1, T2, T3, TResult> When(T1 value1, T2 value2, T3 value3, TResult result)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1) && EqualityComparer<T2>.Default.Equals(a2, value2) && EqualityComparer<T3>.Default.Equals(a3, value3), (T1 a1, T2 a2, T3 a3) => result);
            }

            public IResultMatcher<T1, T2, T3, TResult> When(T1 value1, T2 value2, T3 value3, Func<TResult> callback)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1) && EqualityComparer<T2>.Default.Equals(a2, value2) && EqualityComparer<T3>.Default.Equals(a3, value3), (T1 a1, T2 a2, T3 a3) => callback());
            }

            public IResultMatcher<T1, T2, T3, TResult> When(T1 value1, T2 value2, T3 value3, Func<T1, T2, T3, TResult> callback)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1) && EqualityComparer<T2>.Default.Equals(a2, value2) && EqualityComparer<T3>.Default.Equals(a3, value3), callback);
            }

            public IResultMatcher<T1, T2, T3, TResult> When(Func<T1, T2, T3, bool> predicate, TResult result)
            {
                return When(predicate, (T1 a1, T2 a2, T3 a3) => result);
            }

            public IResultMatcher<T1, T2, T3, TResult> When(Func<T1, T2, T3, bool> predicate, Func<TResult> callback)
            {
                return When(predicate, (T1 a1, T2 a2, T3 a3) => callback());
            }

            public IResultMatcher<T1, T2, T3, TResult> When(Func<T1, T2, T3, bool> predicate, Func<T1, T2, T3, TResult> callback)
            {
                pairs.Add(new Pair { predicate = predicate, callback = callback });
                return this;
            }

            public IResultMatcher<T1, T2, T3, TResult> Default(TResult result)
            {
                return Default((T1 a1, T2 a2, T3 a3) => result);
            }

            public IResultMatcher<T1, T2, T3, TResult> Default(Func<TResult> callback)
            {
                return Default((T1 a1, T2 a2, T3 a3) => callback());
            }

            public IResultMatcher<T1, T2, T3, TResult> Default(Func<T1, T2, T3, TResult> callback)
            {
                defaultCallback = callback;
                return this;
            }

            public TResult Apply(T1 candidate1, T2 candidate2, T3 candidate3)
            {
                foreach (Pair pair in pairs)
                {
                    if (pair.predicate(candidate1, candidate2, candidate3))
                    {
                        return pair.callback(candidate1, candidate2, candidate3);
                    }
                }

                if (defaultCallback != null)
                {
                    return defaultCallback(candidate1, candidate2, candidate3);
                }

                return default(TResult);
            }
        }

        public interface IApplyer<T1, T2, T3, T4, TResult>
        {
            TResult Apply(T1 candidate1, T2 candidate2, T3 candidate3, T4 candidate4);
        }

        public interface IResultMatcher<T1, T2, T3, T4, TResult> : IApplyer<T1, T2, T3, T4, TResult>
        {
            IResultMatcher<T1, T2, T3, T4, TResult> When(T1 value1, T2 value2, T3 value3, T4 value4, TResult result);
            IResultMatcher<T1, T2, T3, T4, TResult> When(T1 value1, T2 value2, T3 value3, T4 value4, Func<TResult> callback);
            IResultMatcher<T1, T2, T3, T4, TResult> When(T1 value1, T2 value2, T3 value3, T4 value4, Func<T1, T2, T3, T4, TResult> callback);
            IResultMatcher<T1, T2, T3, T4, TResult> When(Func<T1, T2, T3, T4, bool> predicate, TResult result);
            IResultMatcher<T1, T2, T3, T4, TResult> When(Func<T1, T2, T3, T4, bool> predicate, Func<TResult> callback);
            IResultMatcher<T1, T2, T3, T4, TResult> When(Func<T1, T2, T3, T4, bool> predicate, Func<T1, T2, T3, T4, TResult> callback);
            IResultMatcher<T1, T2, T3, T4, TResult> Default(TResult result);
            IResultMatcher<T1, T2, T3, T4, TResult> Default(Func<TResult> callback);
            IResultMatcher<T1, T2, T3, T4, TResult> Default(Func<T1, T2, T3, T4, TResult> callback);
        }

        public class ResultMatcher<T1, T2, T3, T4, TResult> : IResultMatcher<T1, T2, T3, T4, TResult>
        {
            private class Pair
            {
                public Func<T1, T2, T3, T4, bool> predicate;
                public Func<T1, T2, T3, T4, TResult> callback;
            }

            private readonly List<Pair> pairs = new List<Pair>();
            private Func<T1, T2, T3, T4, TResult> defaultCallback;

            public ResultMatcher(Func<T1, T2, T3, T4, bool> predicate, Func<T1, T2, T3, T4, TResult> callback)
            {
                pairs.Add(new Pair { predicate = predicate, callback = callback });
            }

            public IResultMatcher<T1, T2, T3, T4, TResult> When(T1 value1, T2 value2, T3 value3, T4 value4, TResult result)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1) && EqualityComparer<T2>.Default.Equals(a2, value2) && EqualityComparer<T3>.Default.Equals(a3, value3) && EqualityComparer<T4>.Default.Equals(a4, value4), (T1 a1, T2 a2, T3 a3, T4 a4) => result);
            }

            public IResultMatcher<T1, T2, T3, T4, TResult> When(T1 value1, T2 value2, T3 value3, T4 value4, Func<TResult> callback)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1) && EqualityComparer<T2>.Default.Equals(a2, value2) && EqualityComparer<T3>.Default.Equals(a3, value3) && EqualityComparer<T4>.Default.Equals(a4, value4), (T1 a1, T2 a2, T3 a3, T4 a4) => callback());
            }

            public IResultMatcher<T1, T2, T3, T4, TResult> When(T1 value1, T2 value2, T3 value3, T4 value4, Func<T1, T2, T3, T4, TResult> callback)
            {
                return When(EqualityComparer<T1>.Default.Equals(a1, value1) && EqualityComparer<T2>.Default.Equals(a2, value2) && EqualityComparer<T3>.Default.Equals(a3, value3) && EqualityComparer<T4>.Default.Equals(a4, value4), callback);
            }

            public IResultMatcher<T1, T2, T3, T4, TResult> When(Func<T1, T2, T3, T4, bool> predicate, TResult result)
            {
                return When(predicate, (T1 a1, T2 a2, T3 a3, T4 a4) => result);
            }

            public IResultMatcher<T1, T2, T3, T4, TResult> When(Func<T1, T2, T3, T4, bool> predicate, Func<TResult> callback)
            {
                return When(predicate, (T1 a1, T2 a2, T3 a3, T4 a4) => callback());
            }

            public IResultMatcher<T1, T2, T3, T4, TResult> When(Func<T1, T2, T3, T4, bool> predicate, Func<T1, T2, T3, T4, TResult> callback)
            {
                pairs.Add(new Pair { predicate = predicate, callback = callback });
                return this;
            }

            public IResultMatcher<T1, T2, T3, T4, TResult> Default(TResult result)
            {
                return Default((T1 a1, T2 a2, T3 a3, T4 a4) => result);
            }

            public IResultMatcher<T1, T2, T3, T4, TResult> Default(Func<TResult> callback)
            {
                return Default((T1 a1, T2 a2, T3 a3, T4 a4) => callback());
            }

            public IResultMatcher<T1, T2, T3, T4, TResult> Default(Func<T1, T2, T3, T4, TResult> callback)
            {
                defaultCallback = callback;
                return this;
            }

            public TResult Apply(T1 candidate1, T2 candidate2, T3 candidate3, T4 candidate4)
            {
                foreach (Pair pair in pairs)
                {
                    if (pair.predicate(candidate1, candidate2, candidate3, candidate4))
                    {
                        return pair.callback(candidate1, candidate2, candidate3, candidate4);
                    }
                }

                if (defaultCallback != null)
                {
                    return defaultCallback(candidate1, candidate2, candidate3, candidate4);
                }

                return default(TResult);
            }
        }

    }
}
