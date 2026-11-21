// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.ReportingAchievement
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
    public class ReportingAchievement
    {
        public string AchievementId { get; private set; }
        public int NumStepBefore { get; private set; }
        public int NumStepAfter { get; private set; }
        public bool UnlockFlag { get; private set; }
        public bool RevealFlag { get; private set; }










        // RVA: 0x16B615C
        public ReportingAchievement(string achievementId)
        {
        }

        // RVA: 0x16B6188
        public void SetReportNumSetp(int numStepBefore, int numStepAfter)
        {
            NumStepBefore = numStepBefore;
            NumStepAfter = numStepAfter;
        }

        // RVA: 0x16B6228
        public void SetUnlockFlag(bool unlockFlag)
        {
            UnlockFlag = unlockFlag;
        }

        // RVA: 0x16B62CC
        public void SetRevealFlag(bool revealFlag)
        {
            RevealFlag = revealFlag;
        }
    }
}
