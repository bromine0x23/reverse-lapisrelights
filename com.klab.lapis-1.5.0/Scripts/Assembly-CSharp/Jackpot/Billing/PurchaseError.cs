// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.PurchaseError
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
    public class PurchaseError
    {
        public bool IsBillingNotSupported { get; private set; }
        public bool IsFailedOnPrePurchase { get; private set; }
        public bool IsDeferredOnPlatformPurchase { get; private set; }
        public bool IsFailedOnPlatformPurchase { get; private set; }
        public bool IsFailedOnPurchasedRequest { get; private set; }
        public bool IsFailedOnPlatformFinishPurchase { get; private set; }
        public bool IsFailedOnReQuery { get; private set; }
        public bool IsCancelled { get; private set; }
        public bool IsInvalidOperation { get; private set; }
        public bool IsMaintenanceAppServer { get; private set; }
        public bool IsFailedOnRefreshReceipt { get; private set; }
        public bool IsCanceledByAppPausing { get; private set; }
        public bool IsFailedIAPPromoProduct { get; private set; }
        public string ProductId { get; private set; }
        public string Message { get; private set; }
        public PurchasedResponseKind PurchasedResponseKind { get; set; }
        public QueryError QueryError { get; set; }


































        // RVA: 0x1780DF8
        public static PurchaseError BillingNotSupported(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsBillingNotSupported = true;
            return purchaseError;
        }

        // RVA: 0x1780EB0
        public static PurchaseError FailedOnPrePurchase(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsFailedOnPrePurchase = true;
            return purchaseError;
        }

        // RVA: 0x1780F30
        public static PurchaseError DeferredOnPlatformPurchase(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsDeferredOnPlatformPurchase = true;
            return purchaseError;
        }

        // RVA: 0x1780FB0
        public static PurchaseError FailedOnPlatformPurchase(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsFailedOnPlatformPurchase = true;
            return purchaseError;
        }

        // RVA: 0x1781030
        public static PurchaseError FailedOnPurchasedRequest(string productId, string message)
        {
            return FailedOnPurchasedRequest(productId, message, (PurchasedResponseKind)(-1));
        }

        // RVA: 0x1781038
        public static PurchaseError FailedOnPurchasedRequest(string productId, string message, PurchasedResponseKind purchasedResponseKind)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsFailedOnPurchasedRequest = true;
            purchaseError.PurchasedResponseKind = purchasedResponseKind;
            return purchaseError;
        }

        // RVA: 0x17810C0
        public static PurchaseError FailedOnPlatformFinishPurchase(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsFailedOnPlatformFinishPurchase = true;
            return purchaseError;
        }

        // RVA: 0x1781140
        public static PurchaseError FailedOnReQuery(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsFailedOnReQuery = true;
            return purchaseError;
        }

        // RVA: 0x17811C0
        public static PurchaseError FailedOnReQuery(string productId, QueryError queryError)
        {
            PurchaseError purchaseError = FailedOnReQuery(productId, queryError.Message);
            purchaseError.QueryError = queryError;
            return purchaseError;
        }

        // RVA: 0x17811F4
        public static PurchaseError Cancelled(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsCancelled = true;
            return purchaseError;
        }

        // RVA: 0x1781274
        public static PurchaseError InvalidOperation(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsInvalidOperation = true;
            return purchaseError;
        }

        // RVA: 0x17812F4
        public static PurchaseError MaintenaceAppServer(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsMaintenanceAppServer = true;
            return purchaseError;
        }

        // RVA: 0x1781374
        public static PurchaseError FailedOnRefreshReceipt(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsFailedOnRefreshReceipt = true;
            return purchaseError;
        }

        // RVA: 0x17813F4
        public static PurchaseError CanceledByAppPausing(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsCanceledByAppPausing = true;
            return purchaseError;
        }

        // RVA: 0x1781474
        public static PurchaseError FailedIAPPromoProduct(string productId, string message)
        {
            PurchaseError purchaseError = new PurchaseError();
            purchaseError.ProductId = productId;
            purchaseError.Message = message;
            purchaseError.IsFailedIAPPromoProduct = true;
            return purchaseError;
        }

        // RVA: 0x1780E78
        private PurchaseError(string productId, string message)
        {
            ProductId = productId;
            Message = message;
        }

        // RVA: 0x17814F4
        public override string ToString()
        {
            if (IsBillingNotSupported)
            {
                return string.Format("BillingNotSupported({0}): {1}", ProductId, Message);
            }

            if (IsFailedOnPrePurchase)
            {
                return string.Format("FailedOnPrePurchase({0}): {1}", ProductId, Message);
            }

            if (IsFailedOnPlatformPurchase)
            {
                return string.Format("FailedOnPlatformPurchase({0}): {1}", ProductId, Message);
            }

            if (IsFailedOnPurchasedRequest)
            {
                return string.Format("FailedOnPurchasedRequest({0}): {1}", ProductId, Message);
            }

            if (IsFailedOnPlatformFinishPurchase)
            {
                return string.Format("FailedOnPlatformConsume({0}): {1}", ProductId, Message);
            }

            if (IsFailedOnReQuery)
            {
                return string.Format("FailedOnRequery({0}): {1}", ProductId, Message);
            }

            if (IsCancelled)
            {
                return string.Format("Cancelled({0}): {1}", ProductId, Message);
            }

            if (IsInvalidOperation)
            {
                return string.Format("InvalidOperation({0}): {1}", ProductId, Message);
            }

            if (IsMaintenanceAppServer)
            {
                return string.Format("IsMaintenanceAppServer({0}): {1}", ProductId, Message);
            }

            if (IsFailedOnRefreshReceipt)
            {
                return string.Format("IsFailedOnRefreshReceipt({0}): {1}", ProductId, Message);
            }

            if (IsCanceledByAppPausing)
            {
                return string.Format("IsCanceledByAppPausing({0}): {1}", ProductId, Message);
            }

            if (IsFailedIAPPromoProduct)
            {
                return string.Format("IsFailedIAPPromoProduct({0}): {1}", ProductId, Message);
            }

            return Message;
        }
    }
}
