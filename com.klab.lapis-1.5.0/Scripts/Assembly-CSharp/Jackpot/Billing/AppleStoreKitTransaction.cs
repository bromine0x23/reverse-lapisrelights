// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.AppleStoreKitTransaction
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
    public class AppleStoreKitTransaction
    {
        public string ProductIdentifier { get; private set; }
        public string Quantity { get; private set; }
        public string ApplicationUsername { get; private set; }
        public AppleStoreKitTransactionState TransactionState { get; private set; }
        public string OriginalTransactionIdentifier { get; private set; }
        public string TransactionIdentifier { get; private set; }
        public long TransactionDate { get; private set; }
        public string Base64EncodedReceipt { get; private set; }
        public AppleStoreKitError Error { get; private set; }


















        // RVA: 0x17706B4
        public AppleStoreKitTransaction(Dictionary<string, object> dict)
        {
                        if (dict.ContainsKey("productIdentifier"))
                        {
                            ProductIdentifier = dict["productIdentifier"] as string;
                        }
                        if (dict.ContainsKey("quantity"))
                        {
                            Quantity = dict["quantity"] as string;
                        }
                        if (dict.ContainsKey("applicationUsername"))
                        {
                            ApplicationUsername = dict["applicationUsername"] as string;
                        }
                        if (dict.ContainsKey("transactionState"))
                        {
                            TransactionState = (AppleStoreKitTransactionState)Enum.ToObject(typeof(AppleStoreKitTransactionState), Convert.ToInt32(dict["transactionState"]));
                        }
                        if (dict.ContainsKey("originalTransactionIdentifier"))
                        {
                            OriginalTransactionIdentifier = dict["originalTransactionIdentifier"] as string;
                        }
                        if (dict.ContainsKey("transactionIdentifier"))
                        {
                            TransactionIdentifier = dict["transactionIdentifier"] as string;
                        }
                        if (dict.ContainsKey("transactionDate"))
                        {
                            TransactionDate = Convert.ToInt64(dict["transactionDate"]);
                        }
                        if (dict.ContainsKey("base64EncodedReceipt"))
                        {
                            Base64EncodedReceipt = dict["base64EncodedReceipt"] as string;
                        }
                        if (dict.ContainsKey("errorCode") && dict.ContainsKey("errorDomain") && dict.ContainsKey("errorDescription"))
                        {
                            Error = new AppleStoreKitError(Convert.ToInt64(dict["errorCode"]), dict["errorDomain"] as string, dict["errorDescription"] as string);
                        }
        }

        // RVA: 0x1770BFC
        public override string ToString()
        {
                        return string.Format("ProductIdentifier:{0}\nQuantity:{1}\nApplicationUsername:{2}\nTransactionState:{3}\nOriginalTransactionIdentifier:{4}\nTransactionIdentifier:{5}\nTransactionDate:{6}\nBase64EncodedReceipt:{7}", ProductIdentifier, Quantity, ApplicationUsername, TransactionState, OriginalTransactionIdentifier, TransactionIdentifier, TransactionDate, Base64EncodedReceipt);
        }
    }
}
