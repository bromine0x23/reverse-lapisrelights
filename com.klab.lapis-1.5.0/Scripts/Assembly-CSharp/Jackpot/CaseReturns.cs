// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.CaseReturns
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jackpot
{
    public static class CaseReturns<TResult>
    {
        public static Case.IResultMatcher<T1, TResult> When<T1>(T1 value1, TResult result)
        {
            return new Case.ResultMatcher<T1, TResult>((candidate1) => EqualityComparer<T1>.Default.Equals(candidate1, value1), (T1 a1) => result);
        }

        public static Case.IResultMatcher<T1, TResult> When<T1>(T1 value1, Func<TResult> callback)
        {
            return new Case.ResultMatcher<T1, TResult>((candidate1) => EqualityComparer<T1>.Default.Equals(candidate1, value1), (T1 a1) => callback());
        }

        public static Case.IResultMatcher<T1, TResult> When<T1>(T1 value1, Func<T1, TResult> callback)
        {
            return new Case.ResultMatcher<T1, TResult>((candidate1) => EqualityComparer<T1>.Default.Equals(candidate1, value1), (T1 a1) => callback(a1));
        }

        public static Case.IResultMatcher<T1, TResult> When<T1>(Func<T1, bool> predicate, TResult result)
        {
            return new Case.ResultMatcher<T1, TResult>(predicate, (T1 a1) => result);
        }

        public static Case.IResultMatcher<T1, TResult> When<T1>(Func<T1, bool> predicate, Func<TResult> callback)
        {
            return new Case.ResultMatcher<T1, TResult>(predicate, (T1 a1) => callback());
        }

        public static Case.IResultMatcher<T1, TResult> When<T1>(Func<T1, bool> predicate, Func<T1, TResult> callback)
        {
            return new Case.ResultMatcher<T1, TResult>(predicate, (T1 a1) => callback(a1));
        }

        public static Case.IResultMatcher<T1, T2, TResult> When<T1, T2>(T1 value1, T2 value2, TResult result)
        {
            return new Case.ResultMatcher<T1, T2, TResult>((candidate1, candidate2) => EqualityComparer<T1>.Default.Equals(candidate1, value1) && EqualityComparer<T2>.Default.Equals(candidate2, value2), (T1 a1, T2 a2) => result);
        }

        public static Case.IResultMatcher<T1, T2, TResult> When<T1, T2>(T1 value1, T2 value2, Func<TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, TResult>((candidate1, candidate2) => EqualityComparer<T1>.Default.Equals(candidate1, value1) && EqualityComparer<T2>.Default.Equals(candidate2, value2), (T1 a1, T2 a2) => callback());
        }

        public static Case.IResultMatcher<T1, T2, TResult> When<T1, T2>(T1 value1, T2 value2, Func<T1, T2, TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, TResult>((candidate1, candidate2) => EqualityComparer<T1>.Default.Equals(candidate1, value1) && EqualityComparer<T2>.Default.Equals(candidate2, value2), (T1 a1, T2 a2) => callback(a1, a2));
        }

        public static Case.IResultMatcher<T1, T2, TResult> When<T1, T2>(Func<T1, T2, bool> predicate, TResult result)
        {
            return new Case.ResultMatcher<T1, T2, TResult>(predicate, (T1 a1, T2 a2) => result);
        }

        public static Case.IResultMatcher<T1, T2, TResult> When<T1, T2>(Func<T1, T2, bool> predicate, Func<TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, TResult>(predicate, (T1 a1, T2 a2) => callback());
        }

        public static Case.IResultMatcher<T1, T2, TResult> When<T1, T2>(Func<T1, T2, bool> predicate, Func<T1, T2, TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, TResult>(predicate, (T1 a1, T2 a2) => callback(a1, a2));
        }

        public static Case.IResultMatcher<T1, T2, T3, TResult> When<T1, T2, T3>(T1 value1, T2 value2, T3 value3, TResult result)
        {
            return new Case.ResultMatcher<T1, T2, T3, TResult>((candidate1, candidate2, candidate3) => EqualityComparer<T1>.Default.Equals(candidate1, value1) && EqualityComparer<T2>.Default.Equals(candidate2, value2) && EqualityComparer<T3>.Default.Equals(candidate3, value3), (T1 a1, T2 a2, T3 a3) => result);
        }

        public static Case.IResultMatcher<T1, T2, T3, TResult> When<T1, T2, T3>(T1 value1, T2 value2, T3 value3, Func<TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, T3, TResult>((candidate1, candidate2, candidate3) => EqualityComparer<T1>.Default.Equals(candidate1, value1) && EqualityComparer<T2>.Default.Equals(candidate2, value2) && EqualityComparer<T3>.Default.Equals(candidate3, value3), (T1 a1, T2 a2, T3 a3) => callback());
        }

        public static Case.IResultMatcher<T1, T2, T3, TResult> When<T1, T2, T3>(T1 value1, T2 value2, T3 value3, Func<T1, T2, T3, TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, T3, TResult>((candidate1, candidate2, candidate3) => EqualityComparer<T1>.Default.Equals(candidate1, value1) && EqualityComparer<T2>.Default.Equals(candidate2, value2) && EqualityComparer<T3>.Default.Equals(candidate3, value3), (T1 a1, T2 a2, T3 a3) => callback(a1, a2, a3));
        }

        public static Case.IResultMatcher<T1, T2, T3, TResult> When<T1, T2, T3>(Func<T1, T2, T3, bool> predicate, TResult result)
        {
            return new Case.ResultMatcher<T1, T2, T3, TResult>(predicate, (T1 a1, T2 a2, T3 a3) => result);
        }

        public static Case.IResultMatcher<T1, T2, T3, TResult> When<T1, T2, T3>(Func<T1, T2, T3, bool> predicate, Func<TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, T3, TResult>(predicate, (T1 a1, T2 a2, T3 a3) => callback());
        }

        public static Case.IResultMatcher<T1, T2, T3, TResult> When<T1, T2, T3>(Func<T1, T2, T3, bool> predicate, Func<T1, T2, T3, TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, T3, TResult>(predicate, (T1 a1, T2 a2, T3 a3) => callback(a1, a2, a3));
        }

        public static Case.IResultMatcher<T1, T2, T3, T4, TResult> When<T1, T2, T3, T4>(T1 value1, T2 value2, T3 value3, T4 value4, TResult result)
        {
            return new Case.ResultMatcher<T1, T2, T3, T4, TResult>((candidate1, candidate2, candidate3, candidate4) => EqualityComparer<T1>.Default.Equals(candidate1, value1) && EqualityComparer<T2>.Default.Equals(candidate2, value2) && EqualityComparer<T3>.Default.Equals(candidate3, value3) && EqualityComparer<T4>.Default.Equals(candidate4, value4), (T1 a1, T2 a2, T3 a3, T4 a4) => result);
        }

        public static Case.IResultMatcher<T1, T2, T3, T4, TResult> When<T1, T2, T3, T4>(T1 value1, T2 value2, T3 value3, T4 value4, Func<TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, T3, T4, TResult>((candidate1, candidate2, candidate3, candidate4) => EqualityComparer<T1>.Default.Equals(candidate1, value1) && EqualityComparer<T2>.Default.Equals(candidate2, value2) && EqualityComparer<T3>.Default.Equals(candidate3, value3) && EqualityComparer<T4>.Default.Equals(candidate4, value4), (T1 a1, T2 a2, T3 a3, T4 a4) => callback());
        }

        public static Case.IResultMatcher<T1, T2, T3, T4, TResult> When<T1, T2, T3, T4>(T1 value1, T2 value2, T3 value3, T4 value4, Func<T1, T2, T3, T4, TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, T3, T4, TResult>((candidate1, candidate2, candidate3, candidate4) => EqualityComparer<T1>.Default.Equals(candidate1, value1) && EqualityComparer<T2>.Default.Equals(candidate2, value2) && EqualityComparer<T3>.Default.Equals(candidate3, value3) && EqualityComparer<T4>.Default.Equals(candidate4, value4), (T1 a1, T2 a2, T3 a3, T4 a4) => callback(a1, a2, a3, a4));
        }

        public static Case.IResultMatcher<T1, T2, T3, T4, TResult> When<T1, T2, T3, T4>(Func<T1, T2, T3, T4, bool> predicate, TResult result)
        {
            return new Case.ResultMatcher<T1, T2, T3, T4, TResult>(predicate, (T1 a1, T2 a2, T3 a3, T4 a4) => result);
        }

        public static Case.IResultMatcher<T1, T2, T3, T4, TResult> When<T1, T2, T3, T4>(Func<T1, T2, T3, T4, bool> predicate, Func<TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, T3, T4, TResult>(predicate, (T1 a1, T2 a2, T3 a3, T4 a4) => callback());
        }

        public static Case.IResultMatcher<T1, T2, T3, T4, TResult> When<T1, T2, T3, T4>(Func<T1, T2, T3, T4, bool> predicate, Func<T1, T2, T3, T4, TResult> callback)
        {
            return new Case.ResultMatcher<T1, T2, T3, T4, TResult>(predicate, (T1 a1, T2 a2, T3 a3, T4 a4) => callback(a1, a2, a3, a4));
        }

    }
}
