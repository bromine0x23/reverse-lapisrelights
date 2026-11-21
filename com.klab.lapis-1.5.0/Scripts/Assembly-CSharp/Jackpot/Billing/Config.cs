// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.Config
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

namespace Jackpot.Billing
{
    public class Config
    {
        private const int DefaultMaxRetryRefreshReceiptCount = 3;
        public static int MaxRetryRefreshReceiptCount { get; set; }


        // RVA: 0x1777C80
        static Config()
        {
                        FillDefault();
        }

        // RVA: 0x1777C84
        private static void FillDefault()
        {
                        MaxRetryRefreshReceiptCount = 3;
        }

        // RVA: 0x1777D2C
        public Config()
        {
        }
    }
}
