// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.GameServiceErrorType
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

namespace Jackpot.Social.GameService
{
    public enum GameServiceErrorType
    {
        FailedAuthentication = 0,
        FailedReportAchievement = 1,
        FailedReportLeaderboard = 2,
        FailedLoadSharedData = 3,
        FailedSaveSharedData = 4,
        NotImplemented = 5
    }
}
