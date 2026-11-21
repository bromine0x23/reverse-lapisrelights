// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.RestoreError
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
    public class RestoreError
    {
        public bool IsFailedOnPlatformRequest { get; set; }
        public string Message { get; set; }




        // RVA: 0x1783DB4
        public static RestoreError FailedOnPlatformRequest(string message)
        {
                        RestoreError restoreError = new RestoreError(message);
                        restoreError.IsFailedOnPlatformRequest = true;
                        return restoreError;
        }

        // RVA: 0x1783E28
        private RestoreError(string message)
        {
        }
    }
}
