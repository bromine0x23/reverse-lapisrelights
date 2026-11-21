// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.GameServiceEditor
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
    public class GameServiceEditor : AbstractGameService
    {

        // RVA: 0x16B4C18
        public GameServiceEditor(SuccessAuthenticationDelegate successAuthentication, FailureAuthenticationDelegate failureAuthentication, bool showDefaultAchievementCompletionBanner)
            : base(Logger.Get<GameServiceEditor>(), successAuthentication, failureAuthentication)
        {
                        Logger = Logger.Get<GameServiceEditor>();
        }

        // RVA: 0x16B4CAC
        public override void RegisterHandler()
        {
        }

        // RVA: 0x16B4CB0
        public override void Dispose()
        {
        }

        // RVA: 0x16B4CB4
        public override void Authenticate()
        {
        }

        // RVA: 0x16B4CB8
        public override bool IsSignedIn()
        {
                        return false;
        }

        // RVA: 0x16B4CC0
        public override string PlayerIdentifier()
        {
                        return string.Empty;
        }

        // RVA: 0x16B4D10
        public override void ShowAchievements()
        {
        }

        // RVA: 0x16B4D14
        public override void ShowAchievements(Action signOutCallback)
        {
                        ShowAchievements();
        }

        // RVA: 0x16B4D20
        public override void ShowLeaderboards()
        {
        }

        // RVA: 0x16B4D24
        public override void ShowLeaderboards(Action signOutCallback)
        {
                        ShowLeaderboards();
        }

        // RVA: 0x16B4D34
        public override void ReportLeaderboardScore(long score, string boardId, Action<ReportingLeaderboard> onSuccess, Action<GameServiceError> onError)
        {
        }

        // RVA: 0x16B4D38
        public override void UnlockAchievement(string achievementId)
        {
        }

        // RVA: 0x16B4D3C
        public override void ReportAchievement(string achievementId, int numStepBefore, int numStepAfter)
        {
        }

        // RVA: 0x16B4D40
        public override void RevealAchievement(string achievementId)
        {
        }
    }
}
