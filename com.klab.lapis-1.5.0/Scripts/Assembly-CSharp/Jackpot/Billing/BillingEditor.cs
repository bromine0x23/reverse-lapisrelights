// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.BillingEditor
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
    internal class BillingEditor : AbstractBilling
    {
        public static QueryError StubQueryError;
        public static PurchaseError StubPurchaseError;

        // RVA: 0x1774F4C
        public BillingEditor(PrePurchaseRequestDelegate defaultPrePurchaseRequest, PurchasedRequestDelegate defaultPurchasedRequest, SuccessPurchaseDelegate defaultSuccessPurchase, FailurePurchaseDelegate defaultFailurePurchase, RefreshReceiptDelegate defaultRefreshReceipt)
            : base(Logger.Get<BillingEditor>(), defaultPrePurchaseRequest, defaultPurchasedRequest, defaultSuccessPurchase, defaultFailurePurchase, defaultRefreshReceipt)
        {
        }

        // RVA: 0x1775008
        public override void Dispose()
        {
                        if (!Disposed)
                        {
                            Disposed = true;
                        }
        }

        // RVA: 0x1775020
        public override void Resume(Action<List<PurchasedProduct>, Action<List<PurchasedProduct>>> onGetResumeProducts)
        {
                        Resume(onGetResumeProducts, null);
        }

        // RVA: 0x1775034
        public override void Resume(Action<List<PurchasedProduct>, Action<List<PurchasedProduct>>> onGetResumeProducts, Action<ResumeError> onFailureGetResumeProduct)
        {
                        Logger.Info("Resume success.");
                        List<PurchasedProduct> products = new List<PurchasedProduct>();
                        if (onGetResumeProducts != null)
                        {
                            onGetResumeProducts(products, ResumeExecute);
                        }
        }

        // RVA: 0x1775178
        private void ResumeExecute(ICollection<PurchasedProduct> products)
        {
                        if (products == null)
                        {
                            return;
                        }

                        foreach (PurchasedProduct purchasedProduct in products)
                        {
                            Logger.Debug("Resume purchased request OrderID:{0} ProductID:{1}", new object[]
                            {
                                purchasedProduct.OrderId,
                                purchasedProduct.Id
                            });
                            HandlePurchasedRequest(purchasedProduct);
                        }
        }

        // RVA: 0x177554C
        protected override void QueryProductsCore(List<string> productIds)
        {
                        QueryProductsCore(productIds, null);
        }

        // RVA: 0x1775560
        protected override void QueryProductsCore(List<string> productIds, List<string> subsIds)
        {
                        List<Product> stubProducts = new List<Product>();
                        if (productIds != null)
                        {
                            productIds.ForEach(delegate(string productId)
                            {
                                stubProducts.Add(new Product(productId, "inapp", "Title:" + productId, "DescriptionDescriptionDescriptionDescriptionDescription", "10500", "¥10,500", Currency.Resolve("JPY")));
                            });
                        }

                        if (subsIds != null)
                        {
                            subsIds.ForEach(delegate(string subsId)
                            {
                                stubProducts.Add(new Product(subsId, "inapp", "Title:" + subsId, "DescriptionDescriptionDescriptionDescriptionDescription", "10500", "¥10,500", Currency.Resolve("JPY")));
                            });
                        }

                        if (stubProducts.Count > 0)
                        {
                            MainThreadDispatcher.Post(delegate
                            {
                                HandleSuccessQuery(stubProducts);
                            });
                        }
                        else
                        {
                            HandleSuccessQuery(new List<Product>());
                        }
        }

        // RVA: 0x17757C8
        public override Tuple<bool, string> IsBillingSupported()
        {
                        if (StubPurchaseError != null && StubPurchaseError.IsBillingNotSupported)
                        {
                            return Tuple.Create(false, StubPurchaseError.Message);
                        }

                        return Tuple.Create(true, string.Empty);
        }

        // RVA: 0x17758B8
        protected override void PurchaseCore(PrePurchaseProduct prePurchaseProduct)
        {
                        if (StubPurchaseError != null && StubPurchaseError.IsFailedOnPlatformPurchase)
                        {
                            HandleFailurePurchase(StubPurchaseError);
                        }
                        else if (prePurchaseProduct != null)
                        {
                            PurchasedProduct purchasedProduct = new PurchasedProduct(prePurchaseProduct.Id);
                            HandlePurchasedRequest(purchasedProduct);
                        }
        }

        // RVA: 0x1775A14
        protected override void FinishPurchaseCore(PurchasedProduct purchasedProduct)
        {
                        if (StubPurchaseError != null && StubPurchaseError.IsFailedOnPlatformFinishPurchase)
                        {
                            HandleFailurePurchase(StubPurchaseError);
                        }
                        else
                        {
                            HandleSuccessPurchase(purchasedProduct, PurchaseSuccessTypes.Normal);
                        }
        }

        // RVA: 0x1775B08
        protected override void ReQueryProductsCore(PurchasedProduct purchasedProduct, Action<Product, PurchasedProduct, PurchaseSuccessTypes> completeReQuery)
        {
                        if (StubPurchaseError != null && StubPurchaseError.IsFailedOnReQuery)
                        {
                            HandleFailurePurchase(StubPurchaseError);
                        }
                        else if (purchasedProduct != null)
                        {
                            Product product = new Product(purchasedProduct.Id, "inapp", "TitleTitleTitleTitleTitle", "DescriptionDescriptionDescriptionDescriptionDescription", "10500", "¥10,500", Currency.Resolve("JPY"));
                            if (completeReQuery != null)
                            {
                                completeReQuery(product, purchasedProduct, PurchaseSuccessTypes.Normal);
                            }
                        }
        }

        // RVA: 0x1775CDC
        public override void RefreshReceipt()
        {
        }

        // RVA: 0x1775CE4
        public override void OnAfterPlatformPurchase()
        {
        }

        // RVA: 0x1775CE8
        public override void Restore()
        {
                        List<PurchasedProduct> products = new List<PurchasedProduct>();
                        for (int i = 0; i <= 2; i++)
                        {
                            products.Add(new PurchasedProduct(i.ToString()));
                        }

                        MainThreadDispatcher.Post(delegate
                        {
                            HandleSuccessRestore(products);
                        });
        }

        // RVA: 0x1775EA4
        protected override void FinishRestoredProducts(List<PurchasedProduct> restoredProducts)
        {
        }

        // RVA: 0x1775EA8
        protected override void Resume()
        {
        }

        // RVA: 0x1775EAC
        static BillingEditor()
        {
        }
    }
}
