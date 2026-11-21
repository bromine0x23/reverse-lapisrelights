// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.GameServiceIos
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
    public class GameServiceIos : AbstractGameService
    {

        // RVA: 0x16B4FB4
        public GameServiceIos(SuccessAuthenticationDelegate successAuthentication, FailureAuthenticationDelegate failureAuthentication, bool showDefaultAchievementCompletionBanner)
            : base(Logger.Get<GameServiceIos>(), successAuthentication, failureAuthentication)
        {
        }

        // RVA: 0x16B5048
        public override void RegisterHandler()
        {
        }

        // RVA: 0x16B504C
        public override void Dispose()
        {
        }

        // RVA: 0x16B5050
        public override void Authenticate()
        {
        }

        // RVA: 0x16B5054
        public override bool IsSignedIn()
        {
                        return false;
        }

        // RVA: 0x16B505C
        public override string PlayerIdentifier()
        {
                        return string.Empty;
        }

        // RVA: 0x16B50AC
        public override void ShowAchievements()
        {
        }

        // RVA: 0x16B50B0
        public override void ShowAchievements(Action signOutCallback)
        {
                        ShowAchievements();
        }

        // RVA: 0x16B50BC
        public override void ShowLeaderboards()
        {
        }

        // RVA: 0x16B50C0
        public override void ShowLeaderboards(Action signOutCallback)
        {
                        ShowLeaderboards();
        }

        // RVA: 0x16B50D0
        public override void ReportLeaderboardScore(long score, string boardId, Action<ReportingLeaderboard> onSuccess, Action<GameServiceError> onError)
        {
        }

        // RVA: 0x16B50D4
        public override void UnlockAchievement(string achievementId)
        {
        }

        // RVA: 0x16B50D8
        public override void ReportAchievement(string achievementId, int numStepBefore, int numStepAfter)
        {
        }

        // RVA: 0x16B50DC
        public override void RevealAchievement(string achievementId)
        {
        }
    }
}
