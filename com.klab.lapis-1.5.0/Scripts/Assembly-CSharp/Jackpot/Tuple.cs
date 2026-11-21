// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Tuple
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

namespace Jackpot
{
    public static class Tuple
    {

        public static Tuple<T1> Create<T1>(T1 item1)
        {
            return new Tuple<T1>(item1);
        }

        public static Tuple<T1, T2> Create<T1, T2>(T1 item1, T2 item2)
        {
            return new Tuple<T1, T2>(item1, item2);
        }

        public static Tuple<T1, T2, T3> Create<T1, T2, T3>(T1 item1, T2 item2, T3 item3)
        {
            return new Tuple<T1, T2, T3>(item1, item2, item3);
        }

        public static Tuple<T1, T2, T3, T4> Create<T1, T2, T3, T4>(T1 item1, T2 item2, T3 item3, T4 item4)
        {
            return new Tuple<T1, T2, T3, T4>(item1, item2, item3, item4);
        }

        public static Tuple<T1, T2, T3, T4, T5> Create<T1, T2, T3, T4, T5>(T1 item1, T2 item2, T3 item3, T4 item4, T5 item5)
        {
            return new Tuple<T1, T2, T3, T4, T5>(item1, item2, item3, item4, item5);
        }

        public static Tuple<T1, T2, T3, T4, T5, T6> Create<T1, T2, T3, T4, T5, T6>(T1 item1, T2 item2, T3 item3, T4 item4, T5 item5, T6 item6)
        {
            return new Tuple<T1, T2, T3, T4, T5, T6>(item1, item2, item3, item4, item5, item6);
        }

        public static Tuple<T1, T2, T3, T4, T5, T6, T7> Create<T1, T2, T3, T4, T5, T6, T7>(T1 item1, T2 item2, T3 item3, T4 item4, T5 item5, T6 item6, T7 item7)
        {
            return new Tuple<T1, T2, T3, T4, T5, T6, T7>(item1, item2, item3, item4, item5, item6, item7);
        }

        public static Tuple<T1, T2, T3, T4, T5, T6, T7, TRest> Create<T1, T2, T3, T4, T5, T6, T7, TRest>(T1 item1, T2 item2, T3 item3, T4 item4, T5 item5, T6 item6, T7 item7, TRest rest)
        {
            return new Tuple<T1, T2, T3, T4, T5, T6, T7, TRest>(item1, item2, item3, item4, item5, item6, item7, rest);
        }

        // RVA: 0x16BD318
        internal static int CombineHashCodes(int h1, int h2)
        {
                        return (h1 << 5) + h1 ^ h2;
        }

        // RVA: 0x16BD324
        internal static int CombineHashCodes(int h1, int h2, int h3)
        {
                        return CombineHashCodes(CombineHashCodes(h1, h2), h3);
        }

        // RVA: 0x16BD338
        internal static int CombineHashCodes(int h1, int h2, int h3, int h4)
        {
                        return CombineHashCodes(CombineHashCodes(h1, h2, h3), h4);
        }

        // RVA: 0x16BD354
        internal static int CombineHashCodes(int h1, int h2, int h3, int h4, int h5)
        {
                        return CombineHashCodes(CombineHashCodes(h1, h2, h3, h4), h5);
        }

        // RVA: 0x16BD378
        internal static int CombineHashCodes(int h1, int h2, int h3, int h4, int h5, int h6)
        {
                        return CombineHashCodes(CombineHashCodes(h1, h2, h3, h4, h5), h6);
        }

        // RVA: 0x16BD3A4
        internal static int CombineHashCodes(int h1, int h2, int h3, int h4, int h5, int h6, int h7)
        {
                        return CombineHashCodes(CombineHashCodes(h1, h2, h3, h4, h5, h6), h7);
        }

        // RVA: 0x16BD3D8
        internal static int CombineHashCodes(int h1, int h2, int h3, int h4, int h5, int h6, int h7, int h8)
        {
                        return CombineHashCodes(CombineHashCodes(h1, h2, h3, h4, h5, h6, h7), h8);
        }
    }
}
