// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.AbstractGameService
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.Social.GameService
{
    public abstract class AbstractGameService : IContextExecutor<ReportAchievementContext>, IDisposable
    {
        private SuccessAuthenticationDelegate successAuthentication;
        private FailureAuthenticationDelegate failureAuthentication;
        private SuccessAuthenticationDelegate currentSuccessAuthentication;
        private FailureAuthenticationDelegate currentFailureAuthentication;
        public abstract void RegisterHandler();
        public abstract void Dispose();
        public abstract void Authenticate();
        public abstract bool IsSignedIn();
        public abstract string PlayerIdentifier();
        public abstract void ShowAchievements();
        public abstract void ShowAchievements(Action signOutCallback);
        public abstract void ShowLeaderboards();
        public abstract void ShowLeaderboards(Action signOutCallback);
        public abstract void ReportLeaderboardScore(long score, string boardId, Action<ReportingLeaderboard> onSuccess, Action<GameServiceError> onError);
        public abstract void UnlockAchievement(string achievementId);
        public abstract void ReportAchievement(string achievementId, int numStepBefore, int numStepAfter);
        public abstract void RevealAchievement(string achievementId);
        protected ILogger Logger { get; private set; }
        protected ReportAchievementContext CurrentReportAchievementContext { get; private set; }




        // RVA: 0x1EA4F24
        protected void add_successAuthentication(SuccessAuthenticationDelegate value)
        {
            SuccessAuthenticationDelegate successAuthentication2;
            SuccessAuthenticationDelegate successAuthentication3;
            do
            {
                successAuthentication2 = successAuthentication;
                successAuthentication3 = (SuccessAuthenticationDelegate)Delegate.Combine(successAuthentication2, value);
            }
            while (Interlocked.CompareExchange(ref successAuthentication, successAuthentication3, successAuthentication2) != successAuthentication2);
        }

        // RVA: 0x1EA4FC8
        protected void remove_successAuthentication(SuccessAuthenticationDelegate value)
        {
            SuccessAuthenticationDelegate successAuthentication2;
            SuccessAuthenticationDelegate successAuthentication3;
            do
            {
                successAuthentication2 = successAuthentication;
                successAuthentication3 = (SuccessAuthenticationDelegate)Delegate.Remove(successAuthentication2, value);
            }
            while (Interlocked.CompareExchange(ref successAuthentication, successAuthentication3, successAuthentication2) != successAuthentication2);
        }

        // RVA: 0x1EA506C
        protected void add_failureAuthentication(FailureAuthenticationDelegate value)
        {
            FailureAuthenticationDelegate failureAuthentication2;
            FailureAuthenticationDelegate failureAuthentication3;
            do
            {
                failureAuthentication2 = failureAuthentication;
                failureAuthentication3 = (FailureAuthenticationDelegate)Delegate.Combine(failureAuthentication2, value);
            }
            while (Interlocked.CompareExchange(ref failureAuthentication, failureAuthentication3, failureAuthentication2) != failureAuthentication2);
        }

        // RVA: 0x1EA5110
        protected void remove_failureAuthentication(FailureAuthenticationDelegate value)
        {
            FailureAuthenticationDelegate failureAuthentication2;
            FailureAuthenticationDelegate failureAuthentication3;
            do
            {
                failureAuthentication2 = failureAuthentication;
                failureAuthentication3 = (FailureAuthenticationDelegate)Delegate.Remove(failureAuthentication2, value);
            }
            while (Interlocked.CompareExchange(ref failureAuthentication, failureAuthentication3, failureAuthentication2) != failureAuthentication2);
        }

        // RVA: 0x1EA51B4
        protected void add_currentSuccessAuthentication(SuccessAuthenticationDelegate value)
        {
            SuccessAuthenticationDelegate currentSuccessAuthentication2;
            SuccessAuthenticationDelegate currentSuccessAuthentication3;
            do
            {
                currentSuccessAuthentication2 = currentSuccessAuthentication;
                currentSuccessAuthentication3 = (SuccessAuthenticationDelegate)Delegate.Combine(currentSuccessAuthentication2, value);
            }
            while (Interlocked.CompareExchange(ref currentSuccessAuthentication, currentSuccessAuthentication3, currentSuccessAuthentication2) != currentSuccessAuthentication2);
        }

        // RVA: 0x1EA5258
        protected void remove_currentSuccessAuthentication(SuccessAuthenticationDelegate value)
        {
            SuccessAuthenticationDelegate currentSuccessAuthentication2;
            SuccessAuthenticationDelegate currentSuccessAuthentication3;
            do
            {
                currentSuccessAuthentication2 = currentSuccessAuthentication;
                currentSuccessAuthentication3 = (SuccessAuthenticationDelegate)Delegate.Remove(currentSuccessAuthentication2, value);
            }
            while (Interlocked.CompareExchange(ref currentSuccessAuthentication, currentSuccessAuthentication3, currentSuccessAuthentication2) != currentSuccessAuthentication2);
        }

        // RVA: 0x1EA52FC
        protected void add_currentFailureAuthentication(FailureAuthenticationDelegate value)
        {
            FailureAuthenticationDelegate currentFailureAuthentication2;
            FailureAuthenticationDelegate currentFailureAuthentication3;
            do
            {
                currentFailureAuthentication2 = currentFailureAuthentication;
                currentFailureAuthentication3 = (FailureAuthenticationDelegate)Delegate.Combine(currentFailureAuthentication2, value);
            }
            while (Interlocked.CompareExchange(ref currentFailureAuthentication, currentFailureAuthentication3, currentFailureAuthentication2) != currentFailureAuthentication2);
        }

        // RVA: 0x1EA53A0
        protected void remove_currentFailureAuthentication(FailureAuthenticationDelegate value)
        {
            FailureAuthenticationDelegate currentFailureAuthentication2;
            FailureAuthenticationDelegate currentFailureAuthentication3;
            do
            {
                currentFailureAuthentication2 = currentFailureAuthentication;
                currentFailureAuthentication3 = (FailureAuthenticationDelegate)Delegate.Remove(currentFailureAuthentication2, value);
            }
            while (Interlocked.CompareExchange(ref currentFailureAuthentication, currentFailureAuthentication3, currentFailureAuthentication2) != currentFailureAuthentication2);
        }

        // RVA: 0x1EA5444
        public AbstractGameService(ILogger logger, SuccessAuthenticationDelegate successAuthentication, FailureAuthenticationDelegate failureAuthentication)
        {
            Logger = logger;
            this.successAuthentication = successAuthentication;
            this.failureAuthentication = failureAuthentication;
        }

        // RVA: 0x1EA5490
        ~AbstractGameService()
        {
            Dispose();
        }

        // RVA: 0x1EA5500
        public void Authenticate(SuccessAuthenticationDelegate successAuthentication, FailureAuthenticationDelegate failureAuthentication)
        {
            currentSuccessAuthentication = successAuthentication;
            currentFailureAuthentication = failureAuthentication;
            Authenticate();
        }

        // RVA: 0x1EA5510
        protected void AuthenticationFinishedEvent(bool success)
        {
            if (success)
            {
                Logger.Info("AuthenticationFinishedEvent : Succeeded");
                if (currentSuccessAuthentication != null)
                {
                    currentSuccessAuthentication();
                }
                else if (successAuthentication != null)
                {
                    successAuthentication();
                }
            }
            else
            {
                Logger.Info("AuthenticationFinishedEvent : Failed");
                FailureAuthenticationDelegate failureAuthenticationDelegate = currentFailureAuthentication ?? failureAuthentication;
                if (failureAuthenticationDelegate != null)
                {
                    failureAuthenticationDelegate(GameServiceError.FailedAuthentication("AuthenticationFinishedEvent : Failed"));
                }
            }

            currentSuccessAuthentication = null;
            currentFailureAuthentication = null;
        }

        // RVA: 0x1EA5A40
        protected void OnSuccessReportAchievement()
        {
            Logger.Info("OnSuccessReportAchievement");
            ReportAchievementContext currentReportAchievementContext = CurrentReportAchievementContext;
            CurrentReportAchievementContext = null;
            if (currentReportAchievementContext != null && currentReportAchievementContext.SuccessReport != null)
            {
                currentReportAchievementContext.SuccessReport();
            }
        }

        // RVA: 0x1EA5B34
        protected void OnFailureReportAchievement(string message)
        {
            Logger.Info("OnFailureReportAchievement:" + message);
            ReportAchievementContext currentReportAchievementContext = CurrentReportAchievementContext;
            CurrentReportAchievementContext = null;
            if (currentReportAchievementContext != null && currentReportAchievementContext.FailureReport != null)
            {
                currentReportAchievementContext.FailureReport(GameServiceError.FailedReportAchievement(message));
            }
        }

        // RVA: 0x1EA5FE0
        protected void ReportAchievementFinishedEvent(bool success)
        {
            if (success)
            {
                Logger.Info("ReportAchievementFinishedEvent : Succeeded");
                OnSuccessReportAchievement();
            }
            else
            {
                OnFailureReportAchievement("ReportAchievementFinishedEvent : Failed");
            }
        }

        // RVA: 0x1EA60D8
        public bool CanExecute(ReportAchievementContext context)
        {
            return CurrentReportAchievementContext == null;
        }

        // RVA: 0x1EA60E8
        public void Execute(ReportAchievementContext context)
        {
            ReportingAchievement reportingAchievement = context.ReportingAchievement;
            Logger.Info("Execute ReportContext:{0}; {1}: from:{2}, to:{3}, unlock:{4}, reveal:{5}", new object[]
            {
                context.Id,
                reportingAchievement.AchievementId,
                reportingAchievement.NumStepBefore,
                reportingAchievement.NumStepAfter,
                reportingAchievement.UnlockFlag,
                reportingAchievement.RevealFlag
            });
            CurrentReportAchievementContext = context;
            if (!IsSignedIn())
            {
                OnFailureReportAchievement("Is not SignedIn");
                return;
            }

            if (reportingAchievement.RevealFlag)
            {
                RevealAchievement(reportingAchievement.AchievementId);
            }

            if (reportingAchievement.UnlockFlag)
            {
                UnlockAchievement(reportingAchievement.AchievementId);
            }
            else
            {
                ReportAchievement(reportingAchievement.AchievementId, reportingAchievement.NumStepBefore, reportingAchievement.NumStepAfter);
            }
        }

        // RVA: 0x1EA64AC
        public virtual void LoadSharedData(string name, Action<GameServiceSharedData> onSuccess, Action<GameServiceError> onError)
        {
            if (onError != null)
            {
                onError(GameServiceError.NotImplemented("LoadSharedData is not implemented"));
            }
        }

        // RVA: 0x1EA6524
        public virtual void SaveSharedData(string name, GameServiceSharedData data, Action OnSuccess, Action<GameServiceError> OnError)
        {
            if (OnError != null)
            {
                OnError(GameServiceError.NotImplemented("SaveSharedData is not implemented"));
            }
        }
    }
}
