// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.PurchasedResponseKind
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
    public enum PurchasedResponseKind
    {
        Unknown = -1,
        ProcessedSuccessfully = 0,
        AlreadyProcessed = 1,
        InvalidParam = 10,
        InvalidReceipt = 11,
        FailedToConnectToAppStore = 12,
        InvalidProductId = 13,
        ReceiptOutOfDate = 14,
        UnexpectedValidastionError = 19,
        ContentDeliverFailed = 30
    }
}
