// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.BillingService
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
    public class BillingService : MonoBehaviour
    {
        private static BillingService instance;
        private ILogger logger;
        private AbstractBilling billing;
        private ContextQueue<QueryContext> queryQueue;
        private ContextQueue<PurchaseContext> purchaseQueue;
        private ContextQueue<ResumeContext> resumeQueue;
        private ContextQueue<RestoreContext> restoreQueue;
        public static BillingService Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new GameObject("BillingService").AddComponent<BillingService>();
                }

                return instance;
            }
        }
        public bool IsInitialized { get; private set; }



        // RVA: 0x1776C44
        private void Awake()
        {
                        MainThreadDispatcher.Initialize();
                        UnityEngine.Object.DontDestroyOnLoad(gameObject);
                        logger = Logger.Get<BillingService>();
                        IsInitialized = false;
                        billing = null;
                        queryQueue = null;
                        purchaseQueue = null;
                        resumeQueue = null;
                        restoreQueue = null;
        }

        // RVA: 0x1776D2C
        private void Update()
        {
                        if (IsInitialized)
                        {
                            queryQueue.ProcessQueue();
                            purchaseQueue.ProcessQueue();
                            resumeQueue.ProcessQueue();
                            restoreQueue.ProcessQueue();
                        }
        }

        // RVA: 0x1776DE0
        private void OnDestroy()
        {
                        if (IsInitialized && billing != null)
                        {
                            billing.Dispose();
                        }

                        instance = null;
        }

        // RVA: 0x1776E58
        private void OnApplicationPause(bool pauseStatus)
        {
                        if (!pauseStatus && IsInitialized)
                        {
                            billing.OnAfterPlatformPurchase();
                        }
        }

        // RVA: 0x1776E8C
        public void Initialize(PrePurchaseRequestDelegate prePurchaseRequest, PurchasedRequestDelegate purchasedRequest, SuccessPurchaseDelegate successPurchase, FailurePurchaseDelegate failurePurchase, RefreshReceiptDelegate refreshReceiptPurchase)
        {
                        Initialize(prePurchaseRequest, purchasedRequest, successPurchase, failurePurchase, refreshReceiptPurchase, null, false);
        }

        // RVA: 0x17771C8
        public void Initialize(PrePurchaseRequestDelegate prePurchaseRequest, PurchasedRequestDelegate purchasedRequest, SuccessPurchaseDelegate successPurchase, FailurePurchaseDelegate failurePurchase, RefreshReceiptDelegate refreshReceiptPurchase, ShouldAddStorePaymentDelegate shouldAddStorePayment)
        {
                        Initialize(prePurchaseRequest, purchasedRequest, successPurchase, failurePurchase, refreshReceiptPurchase, shouldAddStorePayment, false);
        }

        // RVA: 0x17771E8
        public void Initialize(PrePurchaseRequestDelegate prePurchaseRequest, PurchasedRequestDelegate purchasedRequest, SuccessPurchaseDelegate successPurchase, FailurePurchaseDelegate failurePurchase, RefreshReceiptDelegate refreshReceiptPurchase, bool enableClientAcknowledge)
        {
                        Initialize(prePurchaseRequest, purchasedRequest, successPurchase, failurePurchase, refreshReceiptPurchase, null, enableClientAcknowledge);
        }

        // RVA: 0x1776EAC
        public void Initialize(PrePurchaseRequestDelegate prePurchaseRequest, PurchasedRequestDelegate purchasedRequest, SuccessPurchaseDelegate successPurchase, FailurePurchaseDelegate failurePurchase, RefreshReceiptDelegate refreshReceiptPurchase, ShouldAddStorePaymentDelegate shouldAddStorePayment, bool enableClientAcknowledge)
        {
                        if (IsInitialized && IsBillingSupported())
                        {
                            logger.Info("Already initialized");
                            return;
                        }

                        logger.Info("Initialize BillingService");
                        switch (Application.platform)
                        {
                            case RuntimePlatform.Android:
                                billing = new BillingAndroid(prePurchaseRequest, purchasedRequest, successPurchase, failurePurchase, refreshReceiptPurchase, enableClientAcknowledge);
                                break;
                            case RuntimePlatform.IPhonePlayer:
                                billing = new BillingIos(prePurchaseRequest, purchasedRequest, successPurchase, failurePurchase, refreshReceiptPurchase);
                                break;
                            default:
                                billing = new BillingEditor(prePurchaseRequest, purchasedRequest, successPurchase, failurePurchase, refreshReceiptPurchase);
                                break;
                        }

                        queryQueue = new ContextQueue<QueryContext>(billing);
                        purchaseQueue = new ContextQueue<PurchaseContext>(billing);
                        resumeQueue = new ContextQueue<ResumeContext>(billing);
                        restoreQueue = new ContextQueue<RestoreContext>(billing);
                        IsInitialized = true;
        }

        // RVA: 0x1777338
        public void Resume()
        {
                        if (IsInitialized)
                        {
                            billing.Resume();
                        }
                        else
                        {
                            logger.Error("BillingService has not been initialized yet.");
                        }
        }

        // RVA: 0x1777420
        public void Resume(Action<List<PurchasedProduct>, Action<List<PurchasedProduct>>> onGetResumeProducts)
        {
                        if (IsInitialized)
                        {
                            billing.Resume(onGetResumeProducts);
                        }
                        else
                        {
                            logger.Error("BillingService has not been initialized yet.");
                        }
        }

        // RVA: 0x1777514
        public void Resume(Action<List<PurchasedProduct>, Action<List<PurchasedProduct>>> onGetResumeProducts, Action<ResumeError> onFailureGetResumeProducts)
        {
                        if (IsInitialized)
                        {
                            billing.Resume(onGetResumeProducts, onFailureGetResumeProducts);
                        }
                        else
                        {
                            logger.Error("BillingService has not been initialized yet.");
                        }
        }

        // RVA: 0x177761C
        internal void Query(QueryContext context)
        {
                        if (IsInitialized)
                        {
                            queryQueue.Enqueue(context);
                        }
                        else
                        {
                            logger.Error("BillingService has not been initialized yet.");
                        }
        }

        // RVA: 0x177771C
        internal void Purchase(PurchaseContext context)
        {
                        if (IsInitialized)
                        {
                            purchaseQueue.Enqueue(context);
                        }
                        else
                        {
                            logger.Error("BillingService has not been initialized yet.");
                        }
        }

        // RVA: 0x177781C
        public void RefreshReceipt()
        {
                        if (billing != null)
                        {
                            billing.RefreshReceipt();
                        }
        }

        // RVA: 0x1777840
        public void CaneclRefresh()
        {
                        if (billing != null)
                        {
                            billing.CancelRefreshReceipt();
                        }
        }

        // RVA: 0x1777208
        public bool IsBillingSupported()
        {
                        if (!IsInitialized)
                        {
                            return false;
                        }

                        return billing.IsBillingSupported().Unpack((bool result, string _) => result);
        }

        // RVA: 0x177785C
        internal void Restore(RestoreContext context)
        {
                        if (IsInitialized)
                        {
                            restoreQueue.Enqueue(context);
                        }
                        else
                        {
                            logger.Error("BillingService has not been initialized yet.");
                        }
        }

        // RVA: 0x177795C
        internal void Resume(ResumeContext context)
        {
                        if (IsInitialized)
                        {
                            resumeQueue.Enqueue(context);
                        }
                        else
                        {
                            logger.Error("BillingService has not been initialized yet.");
                        }
        }

        // RVA: 0x1777A5C
        public string GetSavedIAPPromoProductId()
        {
                        return string.Empty;
        }

        // RVA: 0x1777AAC
        public void CloseAndroidProudct()
        {
                        if (billing is BillingAndroid)
                        {
                            ((BillingAndroid)billing).CloseResumeProudct();
                        }
        }

        // RVA: 0x1777B30
        public BillingService()
        {
        }
    }
}
