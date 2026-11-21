// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.AbstractBilling
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
    internal abstract class AbstractBilling : IContextExecutor<QueryContext>, IContextExecutor<PurchaseContext>, IContextExecutor<RestoreContext>, IContextExecutor<ResumeContext>, IDisposable
    {
        private PrePurchaseRequestDelegate defaultPrePurchaseRequest;
        private PurchasedRequestDelegate defaultPurchasedRequest;
        private SuccessPurchaseDelegate defaultSuccessPurchase;
        private FailurePurchaseDelegate defaultFailurePurchase;
        private RefreshReceiptDelegate defaultRefreshReceipt;
        public abstract void Dispose();
        public abstract void Resume(Action<List<PurchasedProduct>, Action<List<PurchasedProduct>>> onGetResumeProducts);
        public abstract void Resume(Action<List<PurchasedProduct>, Action<List<PurchasedProduct>>> onGetResumeProducts, Action<ResumeError> onFailureGetResumeProducts);
        public abstract Tuple<bool, string> IsBillingSupported();
        protected abstract void QueryProductsCore(List<string> productIds);
        protected abstract void QueryProductsCore(List<string> productIds, List<string> subsIds);
        protected abstract void PurchaseCore(PrePurchaseProduct prePurchaseProduct);
        protected abstract void FinishPurchaseCore(PurchasedProduct purchasedProduct);
        protected abstract void ReQueryProductsCore(PurchasedProduct purchasedProduct, Action<Product, PurchasedProduct, PurchaseSuccessTypes> completeReQuery);
        protected abstract void FinishRestoredProducts(List<PurchasedProduct> restoredProducts);
        public abstract void RefreshReceipt();
        public abstract void OnAfterPlatformPurchase();
        public abstract void Restore();
        protected abstract void Resume();
        protected ILogger Logger { get; private set; }
        protected QueryContext CurrentQueryContext { get; private set; }
        protected PurchaseContext CurrentPurchaseContext { get; private set; }
        protected PurchasedProduct CurrentPurchasedProduct { get; protected set; }
        protected RestoreContext CurrentRestoreContext { get; private set; }
        protected ResumeContext CurrentResumeContext { get; private set; }
        protected bool Disposed { get; protected set; }














        // RVA: 0x176CF28
        protected AbstractBilling(ILogger logger, PrePurchaseRequestDelegate defaultPrePurchaseRequest, PurchasedRequestDelegate defaultPurchasedRequest, SuccessPurchaseDelegate defaultSuccessPurchase, FailurePurchaseDelegate defaultFailurePurchase, RefreshReceiptDelegate defaultRefreshReceipt)
        {
                        Logger = logger;
                        Disposed = false;
            this.defaultPrePurchaseRequest = defaultPrePurchaseRequest;
            this.defaultPurchasedRequest = defaultPurchasedRequest;
            this.defaultSuccessPurchase = defaultSuccessPurchase;
            this.defaultFailurePurchase = defaultFailurePurchase;
            this.defaultRefreshReceipt = defaultRefreshReceipt;
        }

        // RVA: 0x176CF90
        ~AbstractBilling()
        {
                        if (!Disposed)
                        {
                            Dispose();
                        }
        }

        // RVA: 0x176D010
        public bool CanExecute(QueryContext context)
        {
                        return CurrentQueryContext == null;
        }

        // RVA: 0x176D020
        public bool CanExecute(PurchaseContext context)
        {
                        return CurrentPurchaseContext == null;
        }

        // RVA: 0x176D030
        public bool CanExecute(RestoreContext context)
        {
                        if (CurrentRestoreContext != null)
                        {
                            return false;
                        }

                        return CurrentResumeContext == null;
        }

        // RVA: 0x176D050
        public bool CanExecute(ResumeContext context)
        {
                        if (CurrentResumeContext != null)
                        {
                            return false;
                        }

                        return CurrentRestoreContext == null;
        }

        // RVA: 0x176D070
        public void Execute(QueryContext context)
        {
                        if (context == null)
                        {
                            return;
                        }

                        Logger.Debug("Execute Query: {0}", new object[]
                        {
                            context.Id
                        });
                        CurrentQueryContext = context;
                        if (context.QueryRequest != null)
                        {
                            Logger.Debug("Start QueryRequest: {0}", new object[]
                            {
                                context.Id
                            });
                            context.QueryRequest(QueryProductsCore, HandleFailureQuery);
                        }
                        else if (context.QueryItemsRequest != null)
                        {
                            Logger.Debug("Start QueryItemRequest: {0}", new object[]
                            {
                                context.Id
                            });
                            context.QueryItemsRequest(QueryProductsCore, HandleFailureQuery);
                        }
                        else
                        {
                            HandleFailureQuery(QueryError.InvalidOperation("QueryRequestDelegate and QueryItemsRequestDelegate was not set."));
                        }
        }

        // RVA: 0x176D6BC
        public void Execute(RestoreContext context)
        {
                        if (context == null)
                        {
                            return;
                        }

                        Logger.Debug("Execute Restore: {0}", new object[]
                        {
                            context.Id
                        });
                        CurrentRestoreContext = context;
                        Restore();
        }

        // RVA: 0x176D830
        public void Execute(ResumeContext context)
        {
                        if (context == null)
                        {
                            return;
                        }

                        Logger.Debug("Execute Resume: {0}", new object[]
                        {
                            context.Id
                        });
                        CurrentResumeContext = context;
                        Resume();
        }

        // RVA: 0x176D9A4
        public void Execute(PurchaseContext context)
        {
                        if (context == null)
                        {
                            throw new ArgumentNullException("Expected context was not null");
                        }

                        if (context.Product == null)
                        {
                            throw new ArgumentException("Expected product was not null");
                        }

                        Logger.Debug("Execute Purchase: {0}, {1}", new object[]
                        {
                            context.Id,
                            context.Product.Id
                        });
                        CurrentPurchaseContext = context;
                        Tuple<bool, string> billingSupported = IsBillingSupported();
                        if (!billingSupported.Item1)
                        {
                            HandleFailurePurchase(PurchaseError.BillingNotSupported(context.Product.Id, billingSupported.Item2));
                            return;
                        }

                        PrePurchaseProduct prePurchaseProduct = new PrePurchaseProduct();
                        prePurchaseProduct.Id = context.Product.Id;
                        prePurchaseProduct.Type = context.Product.Type;
                        if (context.PrePurchaseRequest != null)
                        {
                            Logger.Debug("Start Custom PrePurchase: {0}, {1}", new object[]
                            {
                                context.Id,
                                context.Product.Id
                            });
                            context.PrePurchaseRequest(prePurchaseProduct, PurchaseCore, HandleFailurePurchase);
                        }
                        else if (defaultPrePurchaseRequest != null)
                        {
                            Logger.Debug("Start Default PrePurchase: {0}, {1}", new object[]
                            {
                                context.Id,
                                context.Product.Id
                            });
                            defaultPrePurchaseRequest(prePurchaseProduct, PurchaseCore, HandleFailurePurchase);
                        }
                        else
                        {
                            HandleFailurePurchase(PurchaseError.InvalidOperation(context.Product.Id, "PrePurchaseRequestDelegate was not set."));
                        }
        }

        // RVA: 0x176DFB0
        public void CancelRefreshReceipt()
        {
                        if (CurrentPurchasedProduct != null)
                        {
                            HandleFailurePurchase(PurchaseError.FailedOnRefreshReceipt(CurrentPurchasedProduct.Id, "refresh receipt canceled."));
                            CurrentPurchasedProduct = null;
                        }
        }

        // RVA: 0x176E024
        protected void HandleSuccessQuery(List<Product> products)
        {
                        Logger.Info("Handle Success Query");
                        QueryContext currentQueryContext = CurrentQueryContext;
                        CurrentQueryContext = null;
                        if (currentQueryContext != null && currentQueryContext.SuccessQuery != null)
                        {
                            currentQueryContext.SuccessQuery(products);
                            return;
                        }

                        Logger.Warn("SuccessQueryDelegate was not set.");
        }

        // RVA: 0x176D4C8
        protected void HandleFailureQuery(QueryError error)
        {
                        Logger.Info("Handle Failure Query");
                        QueryContext currentQueryContext = CurrentQueryContext;
                        CurrentQueryContext = null;
                        if (currentQueryContext != null && currentQueryContext.FailureQuery != null)
                        {
                            currentQueryContext.FailureQuery(error);
                            return;
                        }

                        Logger.Warn("FailureQueryDelegate was not set. Error:", error);
        }

        // RVA: 0x176E1A4
        protected void HandlePurchasedRequest(PurchasedProduct purchasedProduct)
        {
                        Logger.Debug("Handle PurchasedRequest Query: {0}", new object[]
                        {
                            purchasedProduct.Id
                        });
                        if (CurrentPurchaseContext != null && CurrentPurchaseContext.Product.Id == purchasedProduct.Id && CurrentPurchaseContext.PurchasedRequest != null)
                        {
                            Logger.Debug("Current Context: {0}", new object[]
                            {
                                purchasedProduct.Id
                            });
                            CurrentPurchaseContext.PurchasedRequest(purchasedProduct, FinishPurchaseCore, HandleFailurePurchase);
                        }
                        else if (defaultPurchasedRequest != null)
                        {
                            Logger.Debug("Default Context: {0}", new object[]
                            {
                                purchasedProduct.Id
                            });
                            defaultPurchasedRequest(purchasedProduct, FinishPurchaseCore, HandleFailurePurchase);
                        }
                        else
                        {
                            FinishPurchaseCore(purchasedProduct);
                        }
        }

        // RVA: 0x176E5F8
        protected void HandleSuccessPurchase(PurchasedProduct purchasedProduct, PurchaseSuccessTypes successType)
        {
                        if (CurrentPurchaseContext != null)
                        {
                            HandleSuccessPurchase(CurrentPurchaseContext.Product, purchasedProduct, successType);
                            return;
                        }

                        Logger.Debug("Start ReQuery: {0}", new object[]
                        {
                            purchasedProduct.Id
                        });
                        ReQueryProductsCore(purchasedProduct, HandleSuccessPurchase);
        }

        // RVA: 0x176E7B4
        protected void HandleSuccessPurchase(Product product, PurchasedProduct purchasedProduct, PurchaseSuccessTypes successType)
        {
                        if (purchasedProduct != null)
                        {
                            Logger.Debug("Handle Success Purchase: {0}", new object[]
                            {
                                purchasedProduct.Id
                            });
                        }

                        PurchaseContext currentPurchaseContext = CurrentPurchaseContext;
                        CurrentPurchaseContext = null;
                        if (currentPurchaseContext != null && currentPurchaseContext.SuccessPurchase != null)
                        {
                            if (purchasedProduct == null)
                            {
                                if (successType == PurchaseSuccessTypes.NoPurchases)
                                {
                                    currentPurchaseContext.SuccessPurchase(product, null, PurchaseSuccessTypes.NoPurchases);
                                    return;
                                }
                            }
                            else if (currentPurchaseContext.Product.Id == purchasedProduct.Id)
                            {
                                currentPurchaseContext.SuccessPurchase(product, purchasedProduct, successType);
                                return;
                            }
                        }

                        if (defaultSuccessPurchase != null)
                        {
                            defaultSuccessPurchase(product, purchasedProduct, successType);
                        }
                        else
                        {
                            HandleFailurePurchase(PurchaseError.InvalidOperation(purchasedProduct.Id, "SuccessPurchaseDelegate was not set."));
                        }
        }

        // RVA: 0x176DF80
        protected void HandleFailurePurchase(PurchaseError error)
        {
                        PurchaseContext currentPurchaseContext = CurrentPurchaseContext;
                        CurrentPurchaseContext = null;
                        FailurePurchaseDelegate failurePurchaseDelegate = ((currentPurchaseContext != null) ? currentPurchaseContext.FailurePurchase : null) ?? defaultFailurePurchase;
                        if (failurePurchaseDelegate != null)
                        {
                            failurePurchaseDelegate(error);
                        }
        }

        // RVA: 0x176E9B0
        protected void HandleSuccessRestore(List<PurchasedProduct> products)
        {
                        Logger.Info("Handle Success Restore");
                        RestoreContext currentRestoreContext = CurrentRestoreContext;
                        CurrentRestoreContext = null;
                        if (currentRestoreContext != null && currentRestoreContext.SuccessRestore != null)
                        {
                            currentRestoreContext.SuccessRestore(products, FinishRestoredProducts);
                            return;
                        }

                        Logger.Warn("SuccessRestoreDelegate was not set.");
        }

        // RVA: 0x176EB6C
        protected void HandleFailureRestore(RestoreError error)
        {
                        Logger.Info("Handle Failure Restore");
                        RestoreContext currentRestoreContext = CurrentRestoreContext;
                        CurrentRestoreContext = null;
                        if (currentRestoreContext != null && currentRestoreContext.FailureRestore != null)
                        {
                            currentRestoreContext.FailureRestore(error);
                            return;
                        }

                        Logger.Warn("FailureRestoreDelegate was not set. Error:", error);
        }

        // RVA: 0x176ED60
        protected void HandleSuccessResume(List<PurchasedProduct> products)
        {
                        Logger.Info("Handle Success Resume");
                        ResumeContext currentResumeContext = CurrentResumeContext;
                        CurrentResumeContext = null;
                        if (currentResumeContext != null && currentResumeContext.SuccessResume != null)
                        {
                            currentResumeContext.SuccessResume(products);
                            return;
                        }

                        Logger.Warn("SuccessResumeDelegate was not set.");
        }

        // RVA: 0x176EEE0
        protected void HandleFailureResume(ResumeError error)
        {
                        Logger.Info("Handle Failure Restore");
                        ResumeContext currentResumeContext = CurrentResumeContext;
                        CurrentResumeContext = null;
                        if (currentResumeContext != null && currentResumeContext.FailureResume != null)
                        {
                            currentResumeContext.FailureResume(error);
                            return;
                        }

                        Logger.Warn("FailureResumeDelegate was not set. Error:", error);
        }

        // RVA: 0x176F0D4
        private void <Execute>b__39_0(QueryError message)
        {
                        HandleFailureQuery(message);
        }

        // RVA: 0x176F0D8
        private void <Execute>b__39_1(QueryError message)
        {
                        HandleFailureQuery(message);
        }

        // RVA: 0x176F0DC
        private void <Execute>b__42_0(PurchaseError purchaseError)
        {
                        HandleFailurePurchase(purchaseError);
        }

        // RVA: 0x176F0E0
        private void <Execute>b__42_1(PurchaseError purchaseError)
        {
                        HandleFailurePurchase(purchaseError);
        }

        // RVA: 0x176F0E4
        private void <HandleSuccessRestore>b__64_0(List<PurchasedProduct> restoredProducts)
        {
                        FinishRestoredProducts(restoredProducts);
        }
    }
}
