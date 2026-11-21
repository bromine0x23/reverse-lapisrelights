// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.GoogleInAppBilling
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.Billing
{
    public class GoogleInAppBilling
    {
        private static Action<GoogleIabResult> SetupFailed;
        private static Action SetupSucceeded;
        private static Action<GoogleIabResult> QueryInventoryFailed;
        private static Action<List<GoogleIabSkuDetail>> QueryInventorySucceeded;
        private static Action<GoogleIabResult> PurchaseFailed;
        private static Action<GoogleIabPurchase> PurchaseSucceeded;
        private static Action<GoogleIabResult> ConsumeFailed;
        private static Action<GoogleIabPurchase> ConsumeSucceeded;
        private static Action<GoogleIabResult> AcknowledgeFailed;
        private static Action<GoogleIabPurchase> AcknowledgeSucceeded;
        private static Action<GoogleIabResult> RestoreFailed;
        private static Action<List<GoogleIabPurchase>> RestoreSucceeded;
        private static Action<GoogleIabResult> QueryPurchasesFailed;
        private static Action<List<GoogleIabPurchase>, List<GoogleIabSkuDetail>> QueryPurchasesSucceeded;
        private static AndroidJavaObject plugin;

        // RVA: 0x177B5F0
        public static void add_SetupFailed(Action<GoogleIabResult> value)
        {
                        SetupFailed b;
                        SetupFailed c;
                        do
                        {
                            b = SetupFailed;
                            c = (Action<GoogleIabResult>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref SetupFailed, c, b) != b);
        }

        // RVA: 0x177B6DC
        public static void remove_SetupFailed(Action<GoogleIabResult> value)
        {
                        SetupFailed b;
                        SetupFailed c;
                        do
                        {
                            b = SetupFailed;
                            c = (Action<GoogleIabResult>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref SetupFailed, c, b) != b);
        }

        // RVA: 0x177B7C8
        public static void add_SetupSucceeded(Action value)
        {
                        SetupSucceeded b;
                        SetupSucceeded c;
                        do
                        {
                            b = SetupSucceeded;
                            c = (Action)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref SetupSucceeded, c, b) != b);
        }

        // RVA: 0x177B8B8
        public static void remove_SetupSucceeded(Action value)
        {
                        SetupSucceeded b;
                        SetupSucceeded c;
                        do
                        {
                            b = SetupSucceeded;
                            c = (Action)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref SetupSucceeded, c, b) != b);
        }

        // RVA: 0x177B9A8
        public static void add_QueryInventoryFailed(Action<GoogleIabResult> value)
        {
                        QueryInventoryFailed b;
                        QueryInventoryFailed c;
                        do
                        {
                            b = QueryInventoryFailed;
                            c = (Action<GoogleIabResult>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref QueryInventoryFailed, c, b) != b);
        }

        // RVA: 0x177BA98
        public static void remove_QueryInventoryFailed(Action<GoogleIabResult> value)
        {
                        QueryInventoryFailed b;
                        QueryInventoryFailed c;
                        do
                        {
                            b = QueryInventoryFailed;
                            c = (Action<GoogleIabResult>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref QueryInventoryFailed, c, b) != b);
        }

        // RVA: 0x177BB88
        public static void add_QueryInventorySucceeded(Action<List<GoogleIabSkuDetail>> value)
        {
                        QueryInventorySucceeded b;
                        QueryInventorySucceeded c;
                        do
                        {
                            b = QueryInventorySucceeded;
                            c = (Action<List<GoogleIabSkuDetail>>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref QueryInventorySucceeded, c, b) != b);
        }

        // RVA: 0x177BC78
        public static void remove_QueryInventorySucceeded(Action<List<GoogleIabSkuDetail>> value)
        {
                        QueryInventorySucceeded b;
                        QueryInventorySucceeded c;
                        do
                        {
                            b = QueryInventorySucceeded;
                            c = (Action<List<GoogleIabSkuDetail>>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref QueryInventorySucceeded, c, b) != b);
        }

        // RVA: 0x177BD68
        public static void add_PurchaseFailed(Action<GoogleIabResult> value)
        {
                        PurchaseFailed b;
                        PurchaseFailed c;
                        do
                        {
                            b = PurchaseFailed;
                            c = (Action<GoogleIabResult>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref PurchaseFailed, c, b) != b);
        }

        // RVA: 0x177BE58
        public static void remove_PurchaseFailed(Action<GoogleIabResult> value)
        {
                        PurchaseFailed b;
                        PurchaseFailed c;
                        do
                        {
                            b = PurchaseFailed;
                            c = (Action<GoogleIabResult>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref PurchaseFailed, c, b) != b);
        }

        // RVA: 0x177BF48
        public static void add_PurchaseSucceeded(Action<GoogleIabPurchase> value)
        {
                        PurchaseSucceeded b;
                        PurchaseSucceeded c;
                        do
                        {
                            b = PurchaseSucceeded;
                            c = (Action<GoogleIabPurchase>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref PurchaseSucceeded, c, b) != b);
        }

        // RVA: 0x177C038
        public static void remove_PurchaseSucceeded(Action<GoogleIabPurchase> value)
        {
                        PurchaseSucceeded b;
                        PurchaseSucceeded c;
                        do
                        {
                            b = PurchaseSucceeded;
                            c = (Action<GoogleIabPurchase>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref PurchaseSucceeded, c, b) != b);
        }

        // RVA: 0x177C128
        public static void add_ConsumeFailed(Action<GoogleIabResult> value)
        {
                        ConsumeFailed b;
                        ConsumeFailed c;
                        do
                        {
                            b = ConsumeFailed;
                            c = (Action<GoogleIabResult>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref ConsumeFailed, c, b) != b);
        }

        // RVA: 0x177C218
        public static void remove_ConsumeFailed(Action<GoogleIabResult> value)
        {
                        ConsumeFailed b;
                        ConsumeFailed c;
                        do
                        {
                            b = ConsumeFailed;
                            c = (Action<GoogleIabResult>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref ConsumeFailed, c, b) != b);
        }

        // RVA: 0x177C308
        public static void add_ConsumeSucceeded(Action<GoogleIabPurchase> value)
        {
                        ConsumeSucceeded b;
                        ConsumeSucceeded c;
                        do
                        {
                            b = ConsumeSucceeded;
                            c = (Action<GoogleIabPurchase>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref ConsumeSucceeded, c, b) != b);
        }

        // RVA: 0x177C3F8
        public static void remove_ConsumeSucceeded(Action<GoogleIabPurchase> value)
        {
                        ConsumeSucceeded b;
                        ConsumeSucceeded c;
                        do
                        {
                            b = ConsumeSucceeded;
                            c = (Action<GoogleIabPurchase>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref ConsumeSucceeded, c, b) != b);
        }

        // RVA: 0x177C4E8
        public static void add_AcknowledgeFailed(Action<GoogleIabResult> value)
        {
                        AcknowledgeFailed b;
                        AcknowledgeFailed c;
                        do
                        {
                            b = AcknowledgeFailed;
                            c = (Action<GoogleIabResult>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref AcknowledgeFailed, c, b) != b);
        }

        // RVA: 0x177C5D8
        public static void remove_AcknowledgeFailed(Action<GoogleIabResult> value)
        {
                        AcknowledgeFailed b;
                        AcknowledgeFailed c;
                        do
                        {
                            b = AcknowledgeFailed;
                            c = (Action<GoogleIabResult>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref AcknowledgeFailed, c, b) != b);
        }

        // RVA: 0x177C6C8
        public static void add_AcknowledgeSucceeded(Action<GoogleIabPurchase> value)
        {
                        AcknowledgeSucceeded b;
                        AcknowledgeSucceeded c;
                        do
                        {
                            b = AcknowledgeSucceeded;
                            c = (Action<GoogleIabPurchase>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref AcknowledgeSucceeded, c, b) != b);
        }

        // RVA: 0x177C7B8
        public static void remove_AcknowledgeSucceeded(Action<GoogleIabPurchase> value)
        {
                        AcknowledgeSucceeded b;
                        AcknowledgeSucceeded c;
                        do
                        {
                            b = AcknowledgeSucceeded;
                            c = (Action<GoogleIabPurchase>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref AcknowledgeSucceeded, c, b) != b);
        }

        // RVA: 0x177C8A8
        public static void add_RestoreFailed(Action<GoogleIabResult> value)
        {
                        RestoreFailed b;
                        RestoreFailed c;
                        do
                        {
                            b = RestoreFailed;
                            c = (Action<GoogleIabResult>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref RestoreFailed, c, b) != b);
        }

        // RVA: 0x177C998
        public static void remove_RestoreFailed(Action<GoogleIabResult> value)
        {
                        RestoreFailed b;
                        RestoreFailed c;
                        do
                        {
                            b = RestoreFailed;
                            c = (Action<GoogleIabResult>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref RestoreFailed, c, b) != b);
        }

        // RVA: 0x177CA88
        public static void add_RestoreSucceeded(Action<List<GoogleIabPurchase>> value)
        {
                        RestoreSucceeded b;
                        RestoreSucceeded c;
                        do
                        {
                            b = RestoreSucceeded;
                            c = (Action<List<GoogleIabPurchase>>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref RestoreSucceeded, c, b) != b);
        }

        // RVA: 0x177CB78
        public static void remove_RestoreSucceeded(Action<List<GoogleIabPurchase>> value)
        {
                        RestoreSucceeded b;
                        RestoreSucceeded c;
                        do
                        {
                            b = RestoreSucceeded;
                            c = (Action<List<GoogleIabPurchase>>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref RestoreSucceeded, c, b) != b);
        }

        // RVA: 0x177CC68
        public static void add_QueryPurchasesFailed(Action<GoogleIabResult> value)
        {
                        QueryPurchasesFailed b;
                        QueryPurchasesFailed c;
                        do
                        {
                            b = QueryPurchasesFailed;
                            c = (Action<GoogleIabResult>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref QueryPurchasesFailed, c, b) != b);
        }

        // RVA: 0x177CD58
        public static void remove_QueryPurchasesFailed(Action<GoogleIabResult> value)
        {
                        QueryPurchasesFailed b;
                        QueryPurchasesFailed c;
                        do
                        {
                            b = QueryPurchasesFailed;
                            c = (Action<GoogleIabResult>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref QueryPurchasesFailed, c, b) != b);
        }

        // RVA: 0x177CE48
        public static void add_QueryPurchasesSucceeded(Action<List<GoogleIabPurchase>, List<GoogleIabSkuDetail>> value)
        {
                        QueryPurchasesSucceeded b;
                        QueryPurchasesSucceeded c;
                        do
                        {
                            b = QueryPurchasesSucceeded;
                            c = (Action<List<GoogleIabPurchase>, List<GoogleIabSkuDetail>>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref QueryPurchasesSucceeded, c, b) != b);
        }

        // RVA: 0x177CF38
        public static void remove_QueryPurchasesSucceeded(Action<List<GoogleIabPurchase>, List<GoogleIabSkuDetail>> value)
        {
                        QueryPurchasesSucceeded b;
                        QueryPurchasesSucceeded c;
                        do
                        {
                            b = QueryPurchasesSucceeded;
                            c = (Action<List<GoogleIabPurchase>, List<GoogleIabSkuDetail>>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref QueryPurchasesSucceeded, c, b) != b);
        }

        // RVA: 0x177D028
        static GoogleInAppBilling()
        {
                        if (Application.platform == RuntimePlatform.Android)
                        {
                            plugin = new AndroidJavaClass("com.klab.jackpot.billing.UnityBridge");
                        }
        }

        // RVA: 0x177D0B0
        public static void EnableLogging(bool enable)
        {
                        plugin.CallStatic("enableLogging", enable);
        }

        // RVA: 0x177D1BC
        public static void StartSetup()
        {
                        plugin.CallStatic("startSetup", new GoogleInAppBilling.GoogleInAppBillingListener());
        }

        // RVA: 0x177D334
        public static void Dispose()
        {
                        plugin.CallStatic("dispose", new object[0]);
        }

        // RVA: 0x177D3D0
        public static void QueryInventory(string[] itemSkus, string[] subsSkus)
        {
                        plugin.CallStatic("queryInventory", itemSkus, subsSkus);
        }

        // RVA: 0x177D4E8
        public static void Purchase(string sku, string accountId, string profileId)
        {
                        plugin.CallStatic("purchase", sku, accountId, profileId);
        }

        // RVA: 0x177D634
        public static void PurchaseWithTimeProration(string sku, string accountId, string profileId, string oldSku)
        {
                        plugin.CallStatic("purchaseWithTimeProration", sku, accountId, profileId, oldSku);
        }

        // RVA: 0x177D7AC
        public static void PurchaseWithChargeProratedPrice(string sku, string accountId, string profileId, string oldSku)
        {
                        plugin.CallStatic("purchaseWithChargeProratedPrice", sku, accountId, profileId, oldSku);
        }

        // RVA: 0x177D924
        public static void PurchaseWithoutProration(string sku, string accountId, string profileId, string oldSku)
        {
                        plugin.CallStatic("purchaseWithoutProration", sku, accountId, profileId, oldSku);
        }

        // RVA: 0x177DA9C
        public static void PurchaseWithDeferred(string sku, string accountId, string profileId, string oldSku)
        {
                        plugin.CallStatic("purchaseWithDeferred", sku, accountId, profileId, oldSku);
        }

        // RVA: 0x177DC14
        public static void Consume(string sku, string purchaseToken)
        {
                        plugin.CallStatic("consume", sku, purchaseToken);
        }

        // RVA: 0x177DD2C
        public static void Consume(string sku, string purchaseToken, string developerPayload)
        {
                        plugin.CallStatic("consume", sku, purchaseToken, developerPayload);
        }

        // RVA: 0x177DE78
        public static void Acknowledge(string sku, string purchaseToken)
        {
                        plugin.CallStatic("acknowledge", sku, purchaseToken);
        }

        // RVA: 0x177DF90
        public static void Acknowledge(string sku, string purchaseToken, string developerPayload)
        {
                        plugin.CallStatic("acknowledge", sku, purchaseToken, developerPayload);
        }

        // RVA: 0x177E0DC
        public static bool EnsureFinishPausedPurchase()
        {
                        return plugin.CallStatic<bool>("ensureFinishPausedPurchase", new object[0]);
        }

        // RVA: 0x177E180
        public static void QueryPurchases()
        {
                        plugin.CallStatic("queryPurchases", new object[0]);
        }

        // RVA: 0x177E21C
        public static void QueryPurchases(string skuType)
        {
                        plugin.CallStatic("queryPurchases", skuType);
        }

        // RVA: 0x177E308
        public GoogleInAppBilling()
        {
        }
    }
}
