// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.PurchasedProduct
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
    public class PurchasedProduct
    {
        public PurchasedProduct.Isset __isset;
        private string id;
        private string type;
        private string receipt;
        private string signedData;
        private string signature;
        private string orderId;
        private string packageName;
        private long purchaseTime;
        private string purchaseToken;
        private bool autoRenewing;
        private bool acknowledged;
        private bool isIos;
        private bool isAndroid;
        private bool isUnityEditor;
        public string Id { get { return id; } set { id = value; } }
        public string OriginalTransactionId { get; private set; }
        public string TransactionId { get; private set; }
        public DateTime TransactionDate { get; private set; }
        public string Receipt { get { return receipt; } set { receipt = value; } }
        public string Type { get { return type; } set { type = value; } }
        public string SignedData { get { return signedData; } set { signedData = value; } }
        public string Signature { get { return signature; } set { signature = value; } }
        public string OrderId { get { return orderId; } set { orderId = value; } }
        public string PackageName { get { return packageName; } set { packageName = value; } }
        public long PurchaseTime { get { return purchaseTime; } set { purchaseTime = value; } }
        public string PurchaseToken { get { return purchaseToken; } set { purchaseToken = value; } }
        public bool AutoRenewing { get { return autoRenewing; } set { autoRenewing = value; } }
        public bool Acknowledged { get { return acknowledged; } set { acknowledged = value; } }
        public int RetryRefreshReceiptCount { get; set; }
        // RVA: 0x1781668
        public string get_Id()
        {
            return id;
        }

        // RVA: 0x1781670
        public void set_Id(string value)
        {
            id = value;
        }







        // RVA: 0x17816B0
        public string get_Receipt()
        {
            return receipt;
        }

        // RVA: 0x17816B8
        public void set_Receipt(string value)
        {
            receipt = value;
        }

        // RVA: 0x17816C8
        public string get_Type()
        {
            return type;
        }

        // RVA: 0x17816D0
        public void set_Type(string value)
        {
            type = value;
        }

        // RVA: 0x17816E0
        public string get_SignedData()
        {
            return signedData;
        }

        // RVA: 0x17816E8
        public void set_SignedData(string value)
        {
            signedData = value;
        }

        // RVA: 0x17816F8
        public string get_Signature()
        {
            return signature;
        }

        // RVA: 0x1781700
        public void set_Signature(string value)
        {
            signature = value;
        }

        // RVA: 0x1781710
        public string get_OrderId()
        {
            return orderId;
        }

        // RVA: 0x1781718
        public void set_OrderId(string value)
        {
            orderId = value;
        }

        // RVA: 0x1781728
        public string get_PackageName()
        {
            return packageName;
        }

        // RVA: 0x1781730
        public void set_PackageName(string value)
        {
            packageName = value;
        }

        // RVA: 0x1781740
        public long get_PurchaseTime()
        {
            return purchaseTime;
        }

        // RVA: 0x1781748
        public void set_PurchaseTime(long value)
        {
            purchaseTime = value;
        }

        // RVA: 0x1781758
        public string get_PurchaseToken()
        {
            return purchaseToken;
        }

        // RVA: 0x1781760
        public void set_PurchaseToken(string value)
        {
            purchaseToken = value;
        }

        // RVA: 0x1781770
        public bool get_AutoRenewing()
        {
            return autoRenewing;
        }

        // RVA: 0x1781778
        public void set_AutoRenewing(bool value)
        {
            autoRenewing = value;
        }

        // RVA: 0x178178C
        public bool get_Acknowledged()
        {
            return acknowledged;
        }

        // RVA: 0x1781794
        public void set_Acknowledged(bool value)
        {
            acknowledged = value;
        }



        // RVA: 0x17817B8
        public PurchasedProduct(string id, string transactionId, string receipt, long transactionDate, string originalTransactionId)
        {
                        this.id = id;
                        TransactionId = transactionId;
                        this.receipt = receipt;
                        TransactionDate = UnixEpoch.ToDateTime(transactionDate);
                        OriginalTransactionId = originalTransactionId;
                        __isset.Id = true;
                        __isset.Receipt = true;
                        isIos = true;
        }

        // RVA: 0x1781880
        public PurchasedProduct(string id, string type, string signedData, string signature, string orderId, string packageName, long purchaseTime, string purchaseToken, bool autoRenewing, bool acknowledged)
        {
                        this.id = id;
                        this.type = type;
                        this.signedData = signedData;
                        this.signature = signature;
                        this.orderId = orderId;
                        this.packageName = packageName;
                        this.purchaseTime = purchaseTime;
                        this.purchaseToken = purchaseToken;
                        this.autoRenewing = autoRenewing;
                        this.acknowledged = acknowledged;
                        __isset.Id = true;
                        __isset.Type = true;
                        __isset.SignedData = true;
                        __isset.Signature = true;
                        __isset.OrderId = true;
                        __isset.PackageName = true;
                        __isset.PurchaseTime = true;
                        __isset.PurchaseToken = true;
                        __isset.AutoRenewing = true;
                        __isset.Acknowledged = true;
                        isAndroid = true;
        }

        // RVA: 0x17759DC
        public PurchasedProduct(string id)
        {
                        this.id = id;
                        __isset.Id = true;
                        isUnityEditor = true;
        }

        // RVA: 0x1781930
        public Dictionary<string, string> ToDictionary()
        {
                        if (isIos)
                        {
                            return ToDictionary("product_id", "receipt");
                        }

                        if (isAndroid)
                        {
                            return ToDictionary("sku", "type", "signed_data", "base64_signature", "order_id", "package_name", "purchase_time", "purchase_token", "autoRenewing", "acknowledged");
                        }

                        if (isUnityEditor)
                        {
                            return ToDictionary("product_id");
                        }

                        throw new InvalidOperationException("Unsupported platform");
        }

        // RVA: 0x1781AA0
        public Dictionary<string, string> ToDictionary(string idKey, string receiptKey)
        {
                        Dictionary<string, string> dictionary = new Dictionary<string, string>();
                        if (__isset.Id && !string.IsNullOrEmpty(id))
                        {
                            dictionary[idKey] = id;
                        }

                        if (__isset.Receipt && !string.IsNullOrEmpty(receipt))
                        {
                            dictionary[receiptKey] = receipt;
                        }

                        return dictionary;
        }

        // RVA: 0x1781B8C
        public Dictionary<string, string> ToDictionary(string idKey, string typeKey, string signedDataKey, string signatureKey, string orderIdKey, string packageNameKey, string purchaseTimeKey, string purchaseTokenKey, string autoRenewingKey, string acknowledgedKey)
        {
                        Dictionary<string, string> dictionary = new Dictionary<string, string>();
                        if (__isset.Id && !string.IsNullOrEmpty(id))
                        {
                            dictionary[idKey] = id;
                        }

                        if (__isset.Type && !string.IsNullOrEmpty(type))
                        {
                            dictionary[typeKey] = type;
                        }

                        if (__isset.SignedData && !string.IsNullOrEmpty(signedData))
                        {
                            dictionary[signedDataKey] = signedData;
                        }

                        if (__isset.Signature && !string.IsNullOrEmpty(signature))
                        {
                            dictionary[signatureKey] = signature;
                        }

                        if (__isset.OrderId && !string.IsNullOrEmpty(orderId))
                        {
                            dictionary[orderIdKey] = orderId;
                        }

                        if (__isset.PackageName && !string.IsNullOrEmpty(packageName))
                        {
                            dictionary[packageNameKey] = packageName;
                        }

                        if (__isset.PurchaseTime && purchaseTime >= 0)
                        {
                            dictionary[purchaseTimeKey] = purchaseTime.ToString();
                        }

                        if (__isset.PurchaseToken && !string.IsNullOrEmpty(purchaseToken))
                        {
                            dictionary[purchaseTokenKey] = purchaseToken;
                        }

                        if (__isset.AutoRenewing)
                        {
                            dictionary[autoRenewingKey] = autoRenewing.ToString();
                        }

                        if (__isset.Acknowledged)
                        {
                            dictionary[acknowledgedKey] = acknowledged.ToString();
                        }

                        return dictionary;
        }

        // RVA: 0x1781E84
        public Dictionary<string, string> ToDictionary(string idKey)
        {
                        Dictionary<string, string> dictionary = new Dictionary<string, string>();
                        if (__isset.Id && !string.IsNullOrEmpty(id))
                        {
                            dictionary[idKey] = id;
                        }

                        return dictionary;
        }
    }
}
