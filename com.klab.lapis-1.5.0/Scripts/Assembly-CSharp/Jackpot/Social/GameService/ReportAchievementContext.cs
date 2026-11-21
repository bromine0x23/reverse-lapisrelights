// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.ReportAchievementContext
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

namespace Jackpot.Social.GameService
{
    public class ReportAchievementContext : Context
    {
        public ReportingAchievement ReportingAchievement { get; private set; }
        public SuccessReportAchievementDelegate SuccessReport { get; private set; }
        public FailureReportAchievementDelegate FailureReport { get; private set; }






        // RVA: 0x16B5F90
        private ReportAchievementContext(ReportingAchievement reportingAchievement, SuccessReportAchievementDelegate successReport, FailureReportAchievementDelegate failureReport)
        {
                        ReportingAchievement = reportingAchievement;
                        SuccessReport = successReport;
                        FailureReport = failureReport;
        }

        // RVA: 0x16B6020
        private ReportAchievementContext(int id, ReportingAchievement reportingAchievement, SuccessReportAchievementDelegate successReport, FailureReportAchievementDelegate failureReport)
            : base(id)
        {
                        ReportingAchievement = reportingAchievement;
                        SuccessReport = successReport;
                        FailureReport = failureReport;
        }

        // RVA: 0x16B60B8
        public static ReportAchievementContext CreateStepReportContext(string achievementId, int numStepBefore, int numStepAfter)
        {
                        ReportingAchievement reportingAchievement = new ReportingAchievement(achievementId);
                        reportingAchievement.NumStepBefore = numStepBefore;
                        reportingAchievement.NumStepAfter = numStepAfter;
                        return new ReportAchievementContext(reportingAchievement, null, null);
        }

        // RVA: 0x16B6190
        public static ReportAchievementContext CreateUnlockContext(string achievementId)
        {
                        ReportingAchievement reportingAchievement = new ReportingAchievement(achievementId);
                        reportingAchievement.UnlockFlag = true;
                        return new ReportAchievementContext(reportingAchievement, null, null);
        }

        // RVA: 0x16B6234
        public static ReportAchievementContext CreateRevealContext(string achievementId)
        {
                        ReportingAchievement reportingAchievement = new ReportingAchievement(achievementId);
                        reportingAchievement.RevealFlag = true;
                        return new ReportAchievementContext(reportingAchievement, null, null);
        }

        // RVA: 0x16B62D8
        public ReportAchievementContext OnSuccessReport(SuccessReportAchievementDelegate successReportDelegate)
        {
                        return new ReportAchievementContext(Id, ReportingAchievement, successReportDelegate, FailureReport);
        }

        // RVA: 0x16B6364
        public ReportAchievementContext OnFailureReport(FailureReportAchievementDelegate failureReportDelegate)
        {
                        return new ReportAchievementContext(Id, ReportingAchievement, SuccessReport, failureReportDelegate);
        }

        // RVA: 0x16B63EC
        public override void Execute()
        {
                        PlatformGameService.Instance.ReportAchievement(this);
        }
    }
}
