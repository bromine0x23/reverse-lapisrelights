// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.ResumeError
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
    public class ResumeError
    {
        public bool IsFailedOnPlatformRequest { get; set; }
        public string Message { get; set; }




        // RVA: 0x1783FC0
        public static ResumeError FailedOnPlatformRequest(string message)
        {
                        ResumeError resumeError = new ResumeError(message);
                        resumeError.IsFailedOnPlatformRequest = true;
                        return resumeError;
        }

        // RVA: 0x1784034
        private ResumeError(string message)
        {
        }
    }
}
