// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.ResemaraDetectionIdResultKind
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

namespace Jackpot
{
    public enum ResemaraDetectionIdResultKind
    {
        Succeeded = 0,
        Failed = 1,
        GooglePlayServicesNotAvailable = 2,
        GooglePlayServicesDisconnect = 3,
        GooglePlayServicesRepairable = 4,
        UnknownError = 5
    }
}
