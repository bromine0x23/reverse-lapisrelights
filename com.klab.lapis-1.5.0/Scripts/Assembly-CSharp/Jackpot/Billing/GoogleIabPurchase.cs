// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.GoogleIabPurchase
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
    public class GoogleIabPurchase
    {
        public string ItemType { get; private set; }
        public string OrderId { get; private set; }
        public string PackageName { get; private set; }
        public string ProductId { get; private set; }
        public string AccountId { get; private set; }
        public string ProfileId { get; private set; }
        public long PurchaseTime { get; private set; }
        public string DeveloperPayload { get; private set; }
        public string PurchaseToken { get; private set; }
        public string OriginalJson { get; private set; }
        public string Signature { get; private set; }
        public bool AutoRenewing { get; private set; }
        public bool Acknowledged { get; private set; }
        public bool IsPending { get; private set; }




























        // RVA: 0x177A3F0
        public GoogleIabPurchase(Dictionary<string, object> dict)
        {
                        if (dict.ContainsKey("orderId"))
                        {
                            OrderId = dict["orderId"] as string;
                        }
                        if (dict.ContainsKey("packageName"))
                        {
                            PackageName = dict["packageName"] as string;
                        }
                        if (dict.ContainsKey("productId"))
                        {
                            ProductId = dict["productId"] as string;
                        }
                        if (dict.ContainsKey("purchaseTime"))
                        {
                            PurchaseTime = Convert.ToInt64(dict["purchaseTime"]);
                        }
                        if (dict.ContainsKey("developerPayload"))
                        {
                            DeveloperPayload = dict["developerPayload"] as string;
                        }
                        if (dict.ContainsKey("purchaseToken"))
                        {
                            PurchaseToken = dict["purchaseToken"] as string;
                        }
                        if (dict.ContainsKey("itemType"))
                        {
                            ItemType = dict["itemType"] as string;
                        }
                        if (dict.ContainsKey("signature"))
                        {
                            Signature = dict["signature"] as string;
                        }
                        if (dict.ContainsKey("autoRenewing"))
                        {
                            AutoRenewing = Convert.ToBoolean(dict["autoRenewing"]);
                        }
                        if (dict.ContainsKey("acknowledged"))
                        {
                            Acknowledged = Convert.ToBoolean(dict["acknowledged"]);
                        }
                        if (dict.ContainsKey("originalJson"))
                        {
                            OriginalJson = dict["originalJson"] as string;
                        }
                        if (dict.ContainsKey("isPending"))
                        {
                            IsPending = Convert.ToBoolean(dict["isPending"]);
                        }
                        if (dict.ContainsKey("accountId"))
                        {
                            AccountId = dict["accountId"] as string;
                        }
                        if (dict.ContainsKey("profileId"))
                        {
                            ProfileId = dict["profileId"] as string;
                        }
        }

        // RVA: 0x177A9AC
        public override string ToString()
        {
                        return string.Format("ItemType:{0}\nOrderId:{1}\nPackageName:{2}\nProductId:{3}\nAccountId:{4}\nProfileId:{5}\nPurchaseTime:{6}\nDeveloperPayload:{7}\nPurchaseToken:{8}\nSignature:{9}\nAutoRenewing:{10}\nAcknowledged:{11}\nOriginalJson:{12}\nIsPending:{13}", ItemType, OrderId, PackageName, ProductId, AccountId, ProfileId, PurchaseTime, DeveloperPayload, PurchaseToken, Signature, AutoRenewing, Acknowledged, OriginalJson, IsPending);
        }
    }
}
