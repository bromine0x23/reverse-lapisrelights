// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.PurchaseContext
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
    public class PurchaseContext : Context
    {
        private readonly Product product;
        private readonly PrePurchaseRequestDelegate prePurchaseRequest;
        private readonly PurchasedRequestDelegate purchasedRequest;
        private readonly SuccessPurchaseDelegate successPurchase;
        private readonly FailurePurchaseDelegate failurePurchase;
        private readonly RefreshReceiptDelegate refreshReceipt;
        public Product Product { get { return product; } }
        public PrePurchaseRequestDelegate PrePurchaseRequest { get { return prePurchaseRequest; } }
        public PurchasedRequestDelegate PurchasedRequest { get { return purchasedRequest; } }
        public SuccessPurchaseDelegate SuccessPurchase { get { return successPurchase; } }
        public FailurePurchaseDelegate FailurePurchase { get { return failurePurchase; } }
        public RefreshReceiptDelegate RefreshReceipt { get { return refreshReceipt; } }
        // RVA: 0x17806D8
        public Product get_Product()
        {
            return product;
        }

        // RVA: 0x17806E0
        public PrePurchaseRequestDelegate get_PrePurchaseRequest()
        {
            return prePurchaseRequest;
        }

        // RVA: 0x17806E8
        public PurchasedRequestDelegate get_PurchasedRequest()
        {
            return purchasedRequest;
        }

        // RVA: 0x17806F0
        public SuccessPurchaseDelegate get_SuccessPurchase()
        {
            return successPurchase;
        }

        // RVA: 0x17806F8
        public FailurePurchaseDelegate get_FailurePurchase()
        {
            return failurePurchase;
        }

        // RVA: 0x1780700
        public RefreshReceiptDelegate get_RefreshReceipt()
        {
            return refreshReceipt;
        }

        // RVA: 0x1780708
        public PurchaseContext(Product product)
        {
                        this(product, null, null, null, null, null);
        }

        // RVA: 0x1780720
        public PurchaseContext(Product product, PrePurchaseRequestDelegate prePurchaseRequestDelegate, PurchasedRequestDelegate purchasedRequestDelegate, SuccessPurchaseDelegate successPurchaseDelegate, FailurePurchaseDelegate failurePurchaseDelegate, RefreshReceiptDelegate refreshReceiptDelegate)
        {
                        this.product = product;
                        this.prePurchaseRequest = prePurchaseRequestDelegate;
                        this.purchasedRequest = purchasedRequestDelegate;
                        this.successPurchase = successPurchaseDelegate;
                        this.failurePurchase = failurePurchaseDelegate;
                        this.refreshReceipt = refreshReceiptDelegate;
        }

        // RVA: 0x1780848
        public PurchaseContext(int id, Product product, PrePurchaseRequestDelegate prePurchaseRequestDelegate, PurchasedRequestDelegate purchasedRequestDelegate, SuccessPurchaseDelegate successPurchaseDelegate, FailurePurchaseDelegate failurePurchaseDelegate, RefreshReceiptDelegate refreshReceiptDelegate)
            : base(id)
        {
                        this.product = product;
                        this.prePurchaseRequest = prePurchaseRequestDelegate;
                        this.purchasedRequest = purchasedRequestDelegate;
                        this.successPurchase = successPurchaseDelegate;
                        this.failurePurchase = failurePurchaseDelegate;
                        this.refreshReceipt = refreshReceiptDelegate;
        }

        // RVA: 0x178092C
        public PurchaseContext OnPrePurchaseRequest(PrePurchaseRequestDelegate prePurchaseRequestDelegate)
        {
                        return new PurchaseContext(Id, product, prePurchaseRequestDelegate, purchasedRequest, successPurchase, failurePurchase, refreshReceipt);
        }

        // RVA: 0x17809D8
        public PurchaseContext OnPurchasedRequest(PurchasedRequestDelegate purchasedRequestDelegate)
        {
                        return new PurchaseContext(Id, product, prePurchaseRequest, purchasedRequestDelegate, successPurchase, failurePurchase, refreshReceipt);
        }

        // RVA: 0x1780A84
        public PurchaseContext OnSuccessPurchase(SuccessPurchaseDelegate successPurchaseDelegate)
        {
                        return new PurchaseContext(Id, product, prePurchaseRequest, purchasedRequest, successPurchaseDelegate, failurePurchase, refreshReceipt);
        }

        // RVA: 0x1780B30
        public PurchaseContext OnFailurePurchase(FailurePurchaseDelegate failurePurchaseDelegate)
        {
                        return new PurchaseContext(Id, product, prePurchaseRequest, purchasedRequest, successPurchase, failurePurchaseDelegate, refreshReceipt);
        }

        // RVA: 0x1780BDC
        public PurchaseContext OnRefreshReceipt(RefreshReceiptDelegate refreshReceiptDelegate)
        {
                        return new PurchaseContext(Id, product, prePurchaseRequest, purchasedRequest, successPurchase, failurePurchase, refreshReceiptDelegate);
        }

        // RVA: 0x1780C88
        public override void Execute()
        {
                        BillingService.Instance.Purchase(this);
        }
    }
}
