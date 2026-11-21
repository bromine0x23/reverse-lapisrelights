// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.AppleStoreKitError
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
    public class AppleStoreKitError
    {
        public long Code { get; private set; }
        public string Domain { get; private set; }
        public string Description { get; private set; }
        public bool IsUnknown { get; private set; }
        public bool IsClientInvalid { get; private set; }
        public bool IsPaymentCancelled { get; private set; }
        public bool IsPaymentInvalid { get; private set; }
        public bool IsPaymentNotAllowed { get; private set; }
        public bool IsNotAvailable { get; private set; }
        public bool IsKJPBillingErrorUnknown { get; private set; }
        public bool KJPBillingErrorPurchaseFailed { get; private set; }






















        // RVA: 0x176F59C
        public AppleStoreKitError(Dictionary<string, object> dict)
        {
                        if (dict.ContainsKey("code"))
                        {
                            Code = Convert.ToInt64(dict["code"]);
                        }
                        if (dict.ContainsKey("domain"))
                        {
                            Domain = dict["domain"] as string;
                        }
                        if (dict.ContainsKey("description"))
                        {
                            Description = dict["description"] as string;
                        }
                        CaseAction.When<string>("KJPBillingErrorDomain", SetKJPBillingErrorType).Default(SetErrorType).Apply(Domain);
        }

        // RVA: 0x176F888
        public AppleStoreKitError(long code, string domain, string description)
        {
                        Code = code;
                        Domain = domain;
                        Description = description;
                        CaseAction.When<string>("KJPBillingErrorDomain", SetKJPBillingErrorType).Default(SetErrorType).Apply(Domain);
        }

        // RVA: 0x176FA5C
        private void SetErrorType()
        {
                        switch (Code)
                        {
                            case 1L:
                                IsClientInvalid = true;
                                break;
                            case 2L:
                                IsPaymentCancelled = true;
                                break;
                            case 3L:
                                IsPaymentInvalid = true;
                                break;
                            case 4L:
                                IsPaymentNotAllowed = true;
                                break;
                            case 5L:
                                IsNotAvailable = true;
                                break;
                            default:
                                IsUnknown = true;
                                break;
                        }
        }

        // RVA: 0x176FAD4
        private void SetKJPBillingErrorType()
        {
                        if (Code == 1L)
                        {
                            KJPBillingErrorPurchaseFailed = true;
                        }
                        else
                        {
                            IsKJPBillingErrorUnknown = true;
                        }
        }

        // RVA: 0x176FAF4
        public override string ToString()
        {
                        if (IsClientInvalid)
                        {
                            return string.Format("IsClientInvalid({0}),domain:{1},description:{2}", Code, Domain, Description);
                        }

                        if (IsPaymentCancelled)
                        {
                            return string.Format("IsPaymentCancelled({0}),domain:{1},description:{2}", Code, Domain, Description);
                        }

                        if (IsPaymentInvalid)
                        {
                            return string.Format("IsPaymentInvalid({0}),domain:{1},description:{2}", Code, Domain, Description);
                        }

                        if (IsPaymentNotAllowed)
                        {
                            return string.Format("IsPaymentNotAllowed({0}),domain:{1},description:{2}", Code, Domain, Description);
                        }

                        if (IsNotAvailable)
                        {
                            return string.Format("IsNotAvailable({0}),domain:{1},description:{2}", Code, Domain, Description);
                        }

                        if (IsUnknown)
                        {
                            return string.Format("IsUnknown({0}),domain:{1},description:{2}", Code, Domain, Description);
                        }

                        if (IsKJPBillingErrorUnknown)
                        {
                            return string.Format("IsKJPBillingErrorUnknown({0}),domain:{1},description:{2}", Code, Domain, Description);
                        }

                        if (KJPBillingErrorPurchaseFailed)
                        {
                            return string.Format("KJPBillingErrorPurchaseFailed({0}),domain:{1},description:{2}", Code, Domain, Description);
                        }

                        return string.Format("code:{0},domain:{1},description:{2}", Code, Domain, Description);
        }
    }
}
