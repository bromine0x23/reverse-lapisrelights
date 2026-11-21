// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.BillingAndroid
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
    internal class BillingAndroid : AbstractBilling
    {
        private readonly List<ResumeProduct> resumedProducts;
        private bool isBillingSupported;
        private string billingNotSupportedMessage;
        private bool enableClientAcknowledge;

        // RVA: 0x1770E30
        public BillingAndroid(PrePurchaseRequestDelegate defaultPrePurchaseRequest, PurchasedRequestDelegate defaultPurchasedRequest, SuccessPurchaseDelegate defaultSuccessPurchase, FailurePurchaseDelegate defaultFailurePurchase, RefreshReceiptDelegate defaultRefreshReceipt, bool enableClientAcknowledge)
            : base(Logger.Get<BillingAndroid>(), defaultPrePurchaseRequest, defaultPurchasedRequest, defaultSuccessPurchase, defaultFailurePurchase, defaultRefreshReceipt)
        {
                        resumedProducts = new List<ResumeProduct>();
                        isBillingSupported = false;
                        billingNotSupportedMessage = string.Empty;
                        this.enableClientAcknowledge = enableClientAcknowledge;
                        GoogleInAppBilling.EnableLogging(Debug.isDebugBuild);
                        GoogleInAppBilling.SetupSucceeded += HandleSetupSucceeded;
                        GoogleInAppBilling.SetupFailed += HandleSetupFailed;
                        GoogleInAppBilling.QueryInventorySucceeded += HandleQueryInventorySucceeded;
                        GoogleInAppBilling.QueryInventoryFailed += HandleQueryInventoryFailed;
                        GoogleInAppBilling.PurchaseSucceeded += HandlePurchaseSucceed;
                        GoogleInAppBilling.PurchaseFailed += HandlePurchaseFailed;
                        GoogleInAppBilling.ConsumeSucceeded += HandleConsumeSucceeded;
                        GoogleInAppBilling.ConsumeFailed += HandleConsumeFailed;
                        GoogleInAppBilling.AcknowledgeSucceeded += HandleAcknowledgeSucceeded;
                        GoogleInAppBilling.AcknowledgeFailed += HandleAcknowledgeFailed;
                        GoogleInAppBilling.RestoreSucceeded += HandleRestoreSucceeded;
                        GoogleInAppBilling.RestoreFailed += HandleRestoreFailed;
                        GoogleInAppBilling.QueryPurchasesSucceeded += HandleQueryPurchasesSucceeded;
                        GoogleInAppBilling.QueryPurchasesFailed += HandleQueryPurchasesFailed;
                        GoogleInAppBilling.StartSetup();
        }

        // RVA: 0x1771298
        public override void Dispose()
        {
                        if (Disposed)
                        {
                            return;
                        }

                        Disposed = true;
                        GoogleInAppBilling.SetupSucceeded -= HandleSetupSucceeded;
                        GoogleInAppBilling.SetupFailed -= HandleSetupFailed;
                        GoogleInAppBilling.QueryInventorySucceeded -= HandleQueryInventorySucceeded;
                        GoogleInAppBilling.QueryInventoryFailed -= HandleQueryInventoryFailed;
                        GoogleInAppBilling.PurchaseSucceeded -= HandlePurchaseSucceed;
                        GoogleInAppBilling.PurchaseFailed -= HandlePurchaseFailed;
                        GoogleInAppBilling.ConsumeSucceeded -= HandleConsumeSucceeded;
                        GoogleInAppBilling.ConsumeFailed -= HandleConsumeFailed;
                        GoogleInAppBilling.AcknowledgeSucceeded -= HandleAcknowledgeSucceeded;
                        GoogleInAppBilling.AcknowledgeFailed -= HandleAcknowledgeFailed;
                        GoogleInAppBilling.RestoreSucceeded -= HandleRestoreSucceeded;
                        GoogleInAppBilling.RestoreFailed -= HandleRestoreFailed;
                        GoogleInAppBilling.QueryPurchasesSucceeded -= HandleQueryPurchasesSucceeded;
                        GoogleInAppBilling.QueryPurchasesFailed -= HandleQueryPurchasesFailed;
                        GoogleInAppBilling.Dispose();
        }

        // RVA: 0x1771628
        public override void Resume(Action<List<PurchasedProduct>, Action<List<PurchasedProduct>>> onGetResumeProducts)
        {
                        Resume(onGetResumeProducts, null);
        }

        // RVA: 0x177163C
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

        // RVA: 0x1771768
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

        // RVA: 0x1771B38
        protected override void Resume()
        {
                        GoogleInAppBilling.QueryPurchases();
        }

        // RVA: 0x1771B98
        protected override void QueryProductsCore(List<string> productIds)
        {
                        QueryProductsCore(productIds, null);
        }

        // RVA: 0x1771BAC
        protected override void QueryProductsCore(List<string> productIds, List<string> subsIds)
        {
                        if (productIds == null)
                        {
                            productIds = new List<string>();
                        }

                        if (subsIds == null)
                        {
                            subsIds = new List<string>();
                        }

                        GoogleInAppBilling.QueryInventory(productIds.ToArray(), subsIds.ToArray());
        }

        // RVA: 0x1771CBC
        public override Tuple<bool, string> IsBillingSupported()
        {
                        return Tuple.Create(isBillingSupported, billingNotSupportedMessage);
        }

        // RVA: 0x1771D10
        protected override void PurchaseCore(PrePurchaseProduct prePurchaseProduct)
        {
                        if (prePurchaseProduct == null)
                        {
                            throw new ArgumentNullException();
                        }

                        if (prePurchaseProduct.SkuToReplace != null)
                        {
                            switch (prePurchaseProduct.ProrationMode)
                            {
                                case GoogleIabProrationMode.ImmediateWithTimeProration:
                                    GoogleInAppBilling.PurchaseWithTimeProration(prePurchaseProduct.Id, prePurchaseProduct.AccountId, prePurchaseProduct.ProfileId, prePurchaseProduct.SkuToReplace);
                                    break;
                                case GoogleIabProrationMode.ImmediateAndChargeProratedPrice:
                                    GoogleInAppBilling.PurchaseWithChargeProratedPrice(prePurchaseProduct.Id, prePurchaseProduct.AccountId, prePurchaseProduct.ProfileId, prePurchaseProduct.SkuToReplace);
                                    break;
                                case GoogleIabProrationMode.ImmediateWithoutProration:
                                    GoogleInAppBilling.PurchaseWithoutProration(prePurchaseProduct.Id, prePurchaseProduct.AccountId, prePurchaseProduct.ProfileId, prePurchaseProduct.SkuToReplace);
                                    break;
                                case GoogleIabProrationMode.Deferred:
                                    GoogleInAppBilling.PurchaseWithDeferred(prePurchaseProduct.Id, prePurchaseProduct.AccountId, prePurchaseProduct.ProfileId, prePurchaseProduct.SkuToReplace);
                                    break;
                                default:
                                    throw new ArgumentOutOfRangeException();
                            }
                        }
                        else
                        {
                            GoogleInAppBilling.Purchase(prePurchaseProduct.Id, prePurchaseProduct.AccountId, prePurchaseProduct.ProfileId);
                        }
        }

        // RVA: 0x1771F20
        protected override void FinishPurchaseCore(PurchasedProduct purchasedProduct)
        {
                        if (purchasedProduct == null)
                        {
                            throw new ArgumentNullException();
                        }

                        if (purchasedProduct.Type == "subs")
                        {
                            if (purchasedProduct.Acknowledged)
                            {
                                Logger.Info("Already acknowledged OrderID: {0} ProductID: {1}", new object[]
                                {
                                    purchasedProduct.OrderId,
                                    purchasedProduct.Id
                                });
                                HandleSuccessPurchase(purchasedProduct, PurchaseSuccessTypes.Normal);
                            }
                            else if (enableClientAcknowledge)
                            {
                                GoogleInAppBilling.Acknowledge(purchasedProduct.Id, purchasedProduct.PurchaseToken);
                            }
                            else
                            {
                                Logger.Info("Disable acknowledge.");
                                HandleSuccessPurchase(purchasedProduct, PurchaseSuccessTypes.Normal);
                            }
                        }
                        else
                        {
                            GoogleInAppBilling.Consume(purchasedProduct.Id, purchasedProduct.PurchaseToken);
                        }
        }

        // RVA: 0x17721D8
        protected override void ReQueryProductsCore(PurchasedProduct purchasedProduct, Action<Product, PurchasedProduct, PurchaseSuccessTypes> completeReQuery)
        {
                        ResumeProduct resumeProduct = resumedProducts.Find((ResumeProduct product) => product.Id == purchasedProduct.Id);
                        if (resumeProduct != null)
                        {
                            resumedProducts.Remove(resumeProduct);
                        }

                        if (completeReQuery != null)
                        {
                            completeReQuery(resumeProduct, purchasedProduct, PurchaseSuccessTypes.Normal);
                        }
        }

        // RVA: 0x17722F0
        public override void RefreshReceipt()
        {
                        CurrentPurchasedProduct = null;
        }

        // RVA: 0x17722F8
        public override void OnAfterPlatformPurchase()
        {
                        if (CurrentPurchasedProduct != null)
                        {
                            bool flag = GoogleInAppBilling.EnsureFinishPausedPurchase();
                            Logger.Info("EnsureFinishPausedPurchase:" + flag);
                        }
        }

        // RVA: 0x1772420
        public override void Restore()
        {
                        GoogleInAppBilling.QueryPurchases("subs");
        }

        // RVA: 0x177248C
        protected override void FinishRestoredProducts(List<PurchasedProduct> restoredProducts)
        {
        }

        // RVA: 0x1772490
        private void HandleQueryInventorySucceeded(List<GoogleIabSkuDetail> skus)
        {
                        Logger.Info("QueryInventorySucceededEvent");
                        List<Product> products = new List<Product>();
                        skus.ForEach(delegate(GoogleIabSkuDetail sku)
                        {
                            products.Add(new Product(sku.ProductId, sku.Type, sku.Title, sku.Description, sku.Price, sku.FormattedPrice, Currency.Resolve(sku.PriceCurrencyCode)));
                        });
                        HandleSuccessQuery(products);
        }

        // RVA: 0x1772608
        private void HandleQueryInventoryFailed(GoogleIabResult result)
        {
                        Logger.Info("ProductListRequestFailed:" + result);
                        HandleFailureQuery(QueryError.FailedOnPlatformRequest(result.Message));
        }

        // RVA: 0x1772700
        private void HandleSetupSucceeded()
        {
                        isBillingSupported = true;
        }

        // RVA: 0x177270C
        private void HandleSetupFailed(GoogleIabResult result)
        {
                        isBillingSupported = false;
                        billingNotSupportedMessage = result.Message;
        }

        // RVA: 0x177272C
        private void HandlePurchaseSucceed(GoogleIabPurchase purchase)
        {
                        Logger.Info("PurchaseSucceededEvent");
                        if (purchase != null)
                        {
                            Logger.Info("OriginalJson:" + purchase.OriginalJson);
                        }

                        PurchasedProduct purchasedProduct = new PurchasedProduct(purchase.ProductId, purchase.ItemType, purchase.OriginalJson, purchase.Signature, purchase.OrderId, purchase.PackageName, purchase.PurchaseTime, purchase.PurchaseToken, purchase.AutoRenewing, purchase.Acknowledged);
                        if (purchase.IsPending)
                        {
                            HandleSuccessPurchase(purchasedProduct, PurchaseSuccessTypes.Pending);
                        }
                        else
                        {
                            HandlePurchasedRequest(purchasedProduct);
                        }
        }

        // RVA: 0x1772964
        private void HandlePurchaseFailed(GoogleIabResult result)
        {
                        Logger.Info("purchase failed with error:" + result);
                        string productId = ((CurrentPurchaseContext != null && CurrentPurchaseContext.Product != null) ? CurrentPurchaseContext.Product.Id : "Unknown");
                        PurchaseError error = (result.IsBillingResponseResultUserCanceled ? PurchaseError.Cancelled(productId, result.Message) : (result.IsPurchaseCanceledByAppPausing ? PurchaseError.CanceledByAppPausing(productId, result.Message) : PurchaseError.FailedOnPlatformPurchase(productId, result.Message)));
                        HandleFailurePurchase(error);
        }

        // RVA: 0x1772AA8
        private void HandleConsumeSucceeded(GoogleIabPurchase googlePurchase)
        {
                        Logger.Info("HandleConsumeSucceeded: {0}", new object[]
                        {
                            googlePurchase.ProductId
                        });
                        PurchasedProduct purchasedProduct = new PurchasedProduct(googlePurchase.ProductId, googlePurchase.ItemType, googlePurchase.OriginalJson, googlePurchase.Signature, googlePurchase.OrderId, googlePurchase.PackageName, googlePurchase.PurchaseTime, googlePurchase.PurchaseToken, googlePurchase.AutoRenewing, googlePurchase.Acknowledged);
                        HandleSuccessPurchase(purchasedProduct, PurchaseSuccessTypes.Normal);
        }

        // RVA: 0x1772C74
        private void HandleConsumeFailed(GoogleIabResult result)
        {
                        Logger.Info("HandleConsumeFailed:" + result);
                        string productId = ((CurrentPurchaseContext != null && CurrentPurchaseContext.Product != null) ? CurrentPurchaseContext.Product.Id : "Unknown");
                        HandleFailurePurchase(PurchaseError.FailedOnPlatformFinishPurchase(productId, result.Message));
        }

        // RVA: 0x1772D90
        private void HandleAcknowledgeSucceeded(GoogleIabPurchase googlePurchase)
        {
                        Logger.Info("HandleAcknowledgeSucceeded: {0}", new object[]
                        {
                            googlePurchase.ProductId
                        });
                        PurchasedProduct purchasedProduct = new PurchasedProduct(googlePurchase.ProductId, googlePurchase.ItemType, googlePurchase.OriginalJson, googlePurchase.Signature, googlePurchase.OrderId, googlePurchase.PackageName, googlePurchase.PurchaseTime, googlePurchase.PurchaseToken, googlePurchase.AutoRenewing, googlePurchase.Acknowledged);
                        HandleSuccessPurchase(purchasedProduct, PurchaseSuccessTypes.Normal);
        }

        // RVA: 0x1772F5C
        private void HandleAcknowledgeFailed(GoogleIabResult result)
        {
                        Logger.Info("HandleAcknowledgeFailed:" + result);
                        string productId = ((CurrentPurchaseContext != null && CurrentPurchaseContext.Product != null) ? CurrentPurchaseContext.Product.Id : "Unknown");
                        HandleFailurePurchase(PurchaseError.FailedOnPlatformFinishPurchase(productId, result.Message));
        }

        // RVA: 0x1773078
        private void HandleRestoreSucceeded(List<GoogleIabPurchase> purchases)
        {
                        Logger.Info("RestoreRequestSuccessful");
                        List<PurchasedProduct> products = new List<PurchasedProduct>();
                        foreach (GoogleIabPurchase purchase in purchases)
                        {
                            PurchasedProduct item = new PurchasedProduct(purchase.ProductId, purchase.ItemType, purchase.OriginalJson, purchase.Signature, purchase.OrderId, purchase.PackageName, purchase.PurchaseTime, purchase.PurchaseToken, purchase.AutoRenewing, purchase.Acknowledged);
                            products.Add(item);
                        }

                        HandleSuccessRestore(products);
        }

        // RVA: 0x17732F4
        private void HandleRestoreFailed(GoogleIabResult result)
        {
                        Logger.Info("RestoreRequestFailed:" + result);
                        HandleFailureRestore(RestoreError.FailedOnPlatformRequest(result.Message));
        }

        // RVA: 0x17733EC
        private void HandleQueryPurchasesSucceeded(List<GoogleIabPurchase> purchases, List<GoogleIabSkuDetail> skuDetails)
        {
                        Logger.Info("HandleQueryPurchasesSucceeded");
                        List<PurchasedProduct> products = new List<PurchasedProduct>();
                        foreach (GoogleIabPurchase purchase in purchases)
                        {
                            GoogleIabSkuDetail googleIabSkuDetail = skuDetails.Find((GoogleIabSkuDetail skuDetail) => skuDetail.ProductId == purchase.ProductId);
                            if (googleIabSkuDetail == null)
                            {
                                HandleFailureResume(ResumeError.FailedOnPlatformRequest("resume product sku detail is not exist."));
                                return;
                            }

                            products.Add(new PurchasedProduct(purchase.ProductId, purchase.ItemType, purchase.OriginalJson, purchase.Signature, purchase.OrderId, purchase.PackageName, purchase.PurchaseTime, purchase.PurchaseToken, purchase.AutoRenewing, purchase.Acknowledged));
                            resumedProducts.Add(new ResumeProduct(googleIabSkuDetail.ProductId, googleIabSkuDetail.Type, googleIabSkuDetail.Title, googleIabSkuDetail.Description, googleIabSkuDetail.Price, googleIabSkuDetail.FormattedPrice, Currency.Resolve(googleIabSkuDetail.PriceCurrencyCode), purchase.PurchaseToken));
                        }

                        if (CurrentRestoreContext != null)
                        {
                            HandleSuccessRestore(products);
                        }
                        else
                        {
                            HandleSuccessResume(products);
                        }
        }

        // RVA: 0x1773820
        private void HandleQueryPurchasesFailed(GoogleIabResult result)
        {
                        Logger.Info("HandleQueryPurchasesFailed:" + result);
                        if (CurrentRestoreContext != null)
                        {
                            HandleFailureRestore(RestoreError.FailedOnPlatformRequest(result.Message));
                        }
                        else
                        {
                            HandleFailureResume(ResumeError.FailedOnPlatformRequest(result.Message));
                        }
        }

        // RVA: 0x177393C
        public void CloseResumeProudct()
        {
                        if (resumedProducts.Count < 1)
                        {
                            return;
                        }

                        foreach (ResumeProduct resumedProduct in resumedProducts)
                        {
                            GoogleInAppBilling.Consume(resumedProduct.Id, resumedProduct.PurchaseToken);
                        }

                        resumedProducts.Clear();
        }
    }
}
