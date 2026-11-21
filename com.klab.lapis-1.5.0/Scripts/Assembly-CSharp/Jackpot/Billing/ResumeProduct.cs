// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.ResumeProduct
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
    public class ResumeProduct : Product
    {
        public string PurchaseToken { get; set; }
        // RVA: 0x1784060
        public ResumeProduct(string id, string type, string title, string description, string price, string formattedPrice, Currency currency, string token)
        {
                        PurchaseToken = token;
        }


    }
}
