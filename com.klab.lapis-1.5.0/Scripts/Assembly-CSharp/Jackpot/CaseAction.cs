// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.CaseAction
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
    public static class CaseAction
    {

        public static Case.IMatcher<T1> When<T1>(T1 value1, Action callback)
        {
            return new Case.ActionMatcher<T1>((T1 a) => EqualityComparer<T1>.Default.Equals(a, value1), (T1 a) => callback());
        }

        public static Case.IMatcher<T1> When<T1>(T1 value1, Action<T1> callback)
        {
            return new Case.ActionMatcher<T1>((T1 a) => EqualityComparer<T1>.Default.Equals(a, value1), callback);
        }

        public static Case.IMatcher<T1> When<T1>(Func<T1, bool> predicate, Action callback)
        {
            return new Case.ActionMatcher<T1>(predicate, (T1 a) => callback());
        }

        public static Case.IMatcher<T1> When<T1>(Func<T1, bool> predicate, Action<T1> callback)
        {
            return new Case.ActionMatcher<T1>(predicate, callback);
        }

        public static Case.IMatcher<T1, T2> When<T1, T2>(T1 value1, T2 value2, Action callback)
        {
            return new Case.ActionMatcher<T1, T2>((T1 a, T2 b) => EqualityComparer<T1>.Default.Equals(a, value1) && EqualityComparer<T2>.Default.Equals(b, value2), (T1 a, T2 b) => callback());
        }

        public static Case.IMatcher<T1, T2> When<T1, T2>(T1 value1, T2 value2, Action<T1, T2> callback)
        {
            return new Case.ActionMatcher<T1, T2>((T1 a, T2 b) => EqualityComparer<T1>.Default.Equals(a, value1) && EqualityComparer<T2>.Default.Equals(b, value2), callback);
        }

        public static Case.IMatcher<T1, T2> When<T1, T2>(Func<T1, T2, bool> predicate, Action callback)
        {
            return new Case.ActionMatcher<T1, T2>(predicate, (T1 a, T2 b) => callback());
        }

        public static Case.IMatcher<T1, T2> When<T1, T2>(Func<T1, T2, bool> predicate, Action<T1, T2> callback)
        {
            return new Case.ActionMatcher<T1, T2>(predicate, callback);
        }

        public static Case.IMatcher<T1, T2, T3> When<T1, T2, T3>(T1 value1, T2 value2, T3 value3, Action callback)
        {
            return new Case.ActionMatcher<T1, T2, T3>((T1 a, T2 b, T3 c) => EqualityComparer<T1>.Default.Equals(a, value1) && EqualityComparer<T2>.Default.Equals(b, value2) && EqualityComparer<T3>.Default.Equals(c, value3), (T1 a, T2 b, T3 c) => callback());
        }

        public static Case.IMatcher<T1, T2, T3> When<T1, T2, T3>(T1 value1, T2 value2, T3 value3, Action<T1, T2, T3> callback)
        {
            return new Case.ActionMatcher<T1, T2, T3>((T1 a, T2 b, T3 c) => EqualityComparer<T1>.Default.Equals(a, value1) && EqualityComparer<T2>.Default.Equals(b, value2) && EqualityComparer<T3>.Default.Equals(c, value3), callback);
        }

        public static Case.IMatcher<T1, T2, T3> When<T1, T2, T3>(Func<T1, T2, T3, bool> predicate, Action callback)
        {
            return new Case.ActionMatcher<T1, T2, T3>(predicate, (T1 a, T2 b, T3 c) => callback());
        }

        public static Case.IMatcher<T1, T2, T3> When<T1, T2, T3>(Func<T1, T2, T3, bool> predicate, Action<T1, T2, T3> callback)
        {
            return new Case.ActionMatcher<T1, T2, T3>(predicate, callback);
        }

        public static Case.IMatcher<T1, T2, T3, T4> When<T1, T2, T3, T4>(T1 value1, T2 value2, T3 value3, T4 value4, Action callback)
        {
            return new Case.ActionMatcher<T1, T2, T3, T4>((T1 a, T2 b, T3 c, T4 d) => EqualityComparer<T1>.Default.Equals(a, value1) && EqualityComparer<T2>.Default.Equals(b, value2) && EqualityComparer<T3>.Default.Equals(c, value3) && EqualityComparer<T4>.Default.Equals(d, value4), (T1 a, T2 b, T3 c, T4 d) => callback());
        }

        public static Case.IMatcher<T1, T2, T3, T4> When<T1, T2, T3, T4>(T1 value1, T2 value2, T3 value3, T4 value4, Action<T1, T2, T3, T4> callback)
        {
            return new Case.ActionMatcher<T1, T2, T3, T4>((T1 a, T2 b, T3 c, T4 d) => EqualityComparer<T1>.Default.Equals(a, value1) && EqualityComparer<T2>.Default.Equals(b, value2) && EqualityComparer<T3>.Default.Equals(c, value3) && EqualityComparer<T4>.Default.Equals(d, value4), callback);
        }

        public static Case.IMatcher<T1, T2, T3, T4> When<T1, T2, T3, T4>(Func<T1, T2, T3, T4, bool> predicate, Action callback)
        {
            return new Case.ActionMatcher<T1, T2, T3, T4>(predicate, (T1 a, T2 b, T3 c, T4 d) => callback());
        }

        public static Case.IMatcher<T1, T2, T3, T4> When<T1, T2, T3, T4>(Func<T1, T2, T3, T4, bool> predicate, Action<T1, T2, T3, T4> callback)
        {
            return new Case.ActionMatcher<T1, T2, T3, T4>(predicate, callback);
        }
    }
}
