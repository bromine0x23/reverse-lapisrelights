// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Extensions.TupleExtensions
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
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

namespace Jackpot.Extensions
{
    public static class TupleExtensions
    {

        [Extension]
        public static void Unpack<T1>(Tuple<T1> self, Action<T1> action)
        {
            action(self.Item1);
        }

        [Extension]
        public static TResult Unpack<T1, TResult>(Tuple<T1> self, Func<T1, TResult> func)
        {
            return func(self.Item1);
        }

        [Extension]
        public static void Unpack<T1, T2>(Tuple<T1, T2> self, Action<T1, T2> action)
        {
            action(self.Item1, self.Item2);
        }

        [Extension]
        public static TResult Unpack<T1, T2, TResult>(Tuple<T1, T2> self, Func<T1, T2, TResult> func)
        {
            return func(self.Item1, self.Item2);
        }

        [Extension]
        public static void Unpack<T1, T2, T3>(Tuple<T1, T2, T3> self, Action<T1, T2, T3> action)
        {
            action(self.Item1, self.Item2, self.Item3);
        }

        [Extension]
        public static TResult Unpack<T1, T2, T3, TResult>(Tuple<T1, T2, T3> self, Func<T1, T2, T3, TResult> func)
        {
            return func(self.Item1, self.Item2, self.Item3);
        }

        [Extension]
        public static void Unpack<T1, T2, T3, T4>(Tuple<T1, T2, T3, T4> self, Action<T1, T2, T3, T4> action)
        {
            action(self.Item1, self.Item2, self.Item3, self.Item4);
        }

        [Extension]
        public static TResult Unpack<T1, T2, T3, T4, TResult>(Tuple<T1, T2, T3, T4> self, Func<T1, T2, T3, T4, TResult> func)
        {
            return func(self.Item1, self.Item2, self.Item3, self.Item4);
        }

        [Extension]
        public static void Unpack<T1, T2, T3, T4, T5>(Tuple<T1, T2, T3, T4, T5> self, Action<T1, T2, T3, T4, T5> action)
        {
            action(self.Item1, self.Item2, self.Item3, self.Item4, self.Item5);
        }

        [Extension]
        public static TResult Unpack<T1, T2, T3, T4, T5, TResult>(Tuple<T1, T2, T3, T4, T5> self, Func<T1, T2, T3, T4, T5, TResult> func)
        {
            return func(self.Item1, self.Item2, self.Item3, self.Item4, self.Item5);
        }

        [Extension]
        public static void Unpack<T1, T2, T3, T4, T5, T6>(Tuple<T1, T2, T3, T4, T5, T6> self, Action<T1, T2, T3, T4, T5, T6> action)
        {
            action(self.Item1, self.Item2, self.Item3, self.Item4, self.Item5, self.Item6);
        }

        [Extension]
        public static TResult Unpack<T1, T2, T3, T4, T5, T6, TResult>(Tuple<T1, T2, T3, T4, T5, T6> self, Func<T1, T2, T3, T4, T5, T6, TResult> func)
        {
            return func(self.Item1, self.Item2, self.Item3, self.Item4, self.Item5, self.Item6);
        }

        [Extension]
        public static void Unpack<T1, T2, T3, T4, T5, T6, T7>(Tuple<T1, T2, T3, T4, T5, T6, T7> self, Action<T1, T2, T3, T4, T5, T6, T7> action)
        {
            action(self.Item1, self.Item2, self.Item3, self.Item4, self.Item5, self.Item6, self.Item7);
        }

        [Extension]
        public static TResult Unpack<T1, T2, T3, T4, T5, T6, T7, TResult>(Tuple<T1, T2, T3, T4, T5, T6, T7> self, Func<T1, T2, T3, T4, T5, T6, T7, TResult> func)
        {
            return func(self.Item1, self.Item2, self.Item3, self.Item4, self.Item5, self.Item6, self.Item7);
        }

        [Extension]
        public static void Unpack<T1, T2, T3, T4, T5, T6, T7, TRest>(Tuple<T1, T2, T3, T4, T5, T6, T7, TRest> self, Action<T1, T2, T3, T4, T5, T6, T7, TRest> action)
        {
            action(self.Item1, self.Item2, self.Item3, self.Item4, self.Item5, self.Item6, self.Item7, self.Rest);
        }

        [Extension]
        public static TResult Unpack<T1, T2, T3, T4, T5, T6, T7, TRest, TResult>(Tuple<T1, T2, T3, T4, T5, T6, T7, TRest> self, Func<T1, T2, T3, T4, T5, T6, T7, TRest, TResult> func)
        {
            return func(self.Item1, self.Item2, self.Item3, self.Item4, self.Item5, self.Item6, self.Item7, self.Rest);
        }
    }
}
