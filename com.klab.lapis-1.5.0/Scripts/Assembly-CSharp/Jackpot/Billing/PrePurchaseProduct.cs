// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.PrePurchaseProduct
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

namespace Jackpot.Billing
{
    public class PrePurchaseProduct
    {
        public string Id { get; set; }
        public string Type { get; set; }
        public string SkuToReplace { get; set; }
        public GoogleIabProrationMode ProrationMode { get; set; }
        public string AccountId { get; set; }
        public string ProfileId { get; set; }

        // RVA: 0x177FFD4
        public PrePurchaseProduct()
        {
        }
    }
}
