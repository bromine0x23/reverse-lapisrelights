// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.GoogleIabResult
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
    public class GoogleIabResult
    {
        public bool IsBillingResponseResultOk { get; private set; }
        public bool IsBillingResponseResultUserCanceled { get; private set; }
        public bool IsBillingResponseResultServiceUnavailable { get; private set; }
        public bool IsBillingResponseResultBillingUnavailable { get; private set; }
        public bool IsBillingResponseResultItemUnavailable { get; private set; }
        public bool IsBillingResponseResultDeveloperError { get; private set; }
        public bool IsBillingResponseResultError { get; private set; }
        public bool IsBillingResponseResultItemAlreadyOwned { get; private set; }
        public bool IsBillingResponseResultItemNotOwned { get; private set; }
        public bool IsBillingResponseResultServiceDisconnected { get; private set; }
        public bool IsBillingResponseResultFeatureNotSupported { get; private set; }
        public bool IsBillingResponseResultServiceTimeout { get; private set; }
        public bool IsBillingServiceError { get; private set; }
        public bool IsPurchaseCanceledByAppPausing { get; private set; }
        public bool IsUnknown { get; private set; }
        public int Response { get; private set; }
        public string Message { get; private set; }


































        // RVA: 0x177AE5C
        public GoogleIabResult(int response, string message)
        {
                        Response = response;
                        Message = message;
                        switch (response)
                        {
                            case -3:
                                IsBillingResponseResultServiceTimeout = true;
                                break;
                            case -2:
                                IsBillingResponseResultFeatureNotSupported = true;
                                break;
                            case -1:
                                IsBillingResponseResultServiceDisconnected = true;
                                break;
                            case 0:
                                IsBillingResponseResultOk = true;
                                break;
                            case 1:
                                IsBillingResponseResultUserCanceled = true;
                                break;
                            case 2:
                                IsBillingResponseResultServiceUnavailable = true;
                                break;
                            case 3:
                                IsBillingResponseResultBillingUnavailable = true;
                                break;
                            case 4:
                                IsBillingResponseResultItemUnavailable = true;
                                break;
                            case 5:
                                IsBillingResponseResultDeveloperError = true;
                                break;
                            case 6:
                                IsBillingResponseResultError = true;
                                break;
                            case 7:
                                IsBillingResponseResultItemAlreadyOwned = true;
                                break;
                            case 8:
                                IsBillingResponseResultItemNotOwned = true;
                                break;
                            case 100:
                                IsBillingServiceError = true;
                                break;
                            case 102:
                                IsPurchaseCanceledByAppPausing = true;
                                break;
                            default:
                                IsUnknown = true;
                                break;
                        }
        }

        // RVA: 0x177AF70
        public override string ToString()
        {
                        return string.Format("Response:{0},Message:{1}", Response, Message);
        }
    }
}
