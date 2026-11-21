// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.BillingIos
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
    internal class BillingIos : AbstractBilling
    {
        private ShouldAddStorePaymentDelegate shouldAddStorePayment;

        // RVA: 0x1776168
        public BillingIos(PrePurchaseRequestDelegate defaultPrePurchaseRequest, PurchasedRequestDelegate defaultPurchasedRequest, SuccessPurchaseDelegate defaultSuccessPurchase, FailurePurchaseDelegate defaultFailurePurchase, RefreshReceiptDelegate defaultRefreshReceipt, ShouldAddStorePaymentDelegate shouldAddStorePayment)
            : base(Logger.Get<BillingIos>(), defaultPrePurchaseRequest, defaultPurchasedRequest, defaultSuccessPurchase, defaultFailurePurchase, defaultRefreshReceipt)
        {
        }

        // RVA: 0x1776224
        public override void Dispose()
        {
                        if (!Disposed)
                        {
                            Disposed = true;
                        }
        }

        // RVA: 0x177623C
        public override void Resume(Action<List<PurchasedProduct>, Action<List<PurchasedProduct>>> onGetResumeProducts)
        {
                        Resume(onGetResumeProducts, onFailureGetResumeProduct);
        }

        // RVA: 0x1776250
        public override void Resume(Action<List<PurchasedProduct>, Action<List<PurchasedProduct>>> onGetResumeProducts, Action<ResumeError> onFailureGetResumeProduct)
        {
                        ResumeContext resumeContext = new ResumeContext();
                        resumeContext.OnSuccessResume(delegate(List<PurchasedProduct> products)
                        {
                            Logger.Info("Resume success.");
                            if (onGetResumeProducts != null)
                            {
                                onGetResumeProducts(products, ResumeExecute);
                            }
                            else
                            {
                                ResumeExecute(products);
                            }
                        }).OnFailureResume(delegate(ResumeError error)
                        {
                            Logger.Info("Resume failed.");
                            if (onFailureGetResumeProduct != null)
                            {
                                onFailureGetResumeProduct(error);
                            }
                        }).Execute();
        }

        // RVA: 0x177649C
        private void ResumeExecute(ICollection<PurchasedProduct> products)
        {
                        if (products == null)
                        {
                            return;
                        }

                        foreach (PurchasedProduct purchasedProduct in products)
                        {
                            Logger.Debug("Resume purchased request TransactionID:{0} ProductID:{1}", new object[]
                            {
                                purchasedProduct.TransactionId,
                                purchasedProduct.Id
                            });
                            HandlePurchasedRequest(purchasedProduct);
                        }
        }

        // RVA: 0x1776870
        protected override void Resume()
        {
        }

        // RVA: 0x1776874
        protected override void QueryProductsCore(List<string> productIds)
        {
                        QueryProductsCore(productIds, null);
        }

        // RVA: 0x1776888
        protected override void QueryProductsCore(List<string> productIds, List<string> subsIds)
        {
        }

        // RVA: 0x177688C
        public override Tuple<bool, string> IsBillingSupported()
        {
                        return Tuple.Create(true, string.Empty);
        }

        // RVA: 0x17768EC
        protected override void PurchaseCore(PrePurchaseProduct prePurchaseProduct)
        {
        }

        // RVA: 0x17768F0
        protected override void FinishPurchaseCore(PurchasedProduct purchasedProduct)
        {
        }

        // RVA: 0x17768F4
        protected override void ReQueryProductsCore(PurchasedProduct purchasedProduct, Action<Product, PurchasedProduct, PurchaseSuccessTypes> completeReQuery)
        {
        }

        // RVA: 0x17768F8
        public override void RefreshReceipt()
        {
        }

        // RVA: 0x17768FC
        public override void OnAfterPlatformPurchase()
        {
        }

        // RVA: 0x1776900
        public override void Restore()
        {
        }

        // RVA: 0x1776904
        protected override void FinishRestoredProducts(List<PurchasedProduct> restoredProducts)
        {
        }
    }
}
