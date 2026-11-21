// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.GameServiceAndroid
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using GooglePlayGames;
using GooglePlayGames.BasicApi;
using GooglePlayGames.BasicApi.SavedGame;
using UnityEngine.SocialPlatforms;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.Social.GameService
{
    public class GameServiceAndroid : AbstractGameService
    {

        // RVA: 0x1EA661C
        public GameServiceAndroid(SuccessAuthenticationDelegate successAuthentication, FailureAuthenticationDelegate failureAuthentication, bool enableSharedData = False)
            : base(Logger.Get<GameServiceAndroid>(), successAuthentication, failureAuthentication)
        {
            RegisterHandler();
            PlayGamesPlatform.DebugLogEnabled = Debug.isDebugBuild;
            PlayGamesClientConfiguration.Builder builder = new PlayGamesClientConfiguration.Builder();
            if (enableSharedData)
            {
                builder.EnableSavedGames();
            }

            PlayGamesPlatform.InitializeInstance(builder.Build());
            PlayGamesPlatform.Activate();
        }

        // RVA: 0x1EA67BC
        public override void RegisterHandler()
        {
        }

        // RVA: 0x1EA67C0
        public override void Dispose()
        {
        }

        // RVA: 0x1EA67C4
        public override void Authenticate()
        {
            Social.localUser.Authenticate(success => AuthenticationFinishedEvent(success));
        }

        // RVA: 0x1EA68C0
        public override bool IsSignedIn()
        {
            return Social.localUser.authenticated;
        }

        // RVA: 0x1EA6978
        public override string PlayerIdentifier()
        {
            return Social.localUser.id;
        }

        // RVA: 0x1EA6A2C
        public override void ShowAchievements()
        {
            Social.ShowAchievementsUI();
        }

        // RVA: 0x1EA6A40
        public override void ShowAchievements(Action signOutCallback)
        {
            PlayGamesPlatform.Instance.ShowAchievementsUI(status =>
            {
                if (status == UIStatus.NotAuthorized && signOutCallback != null)
                {
                    signOutCallback();
                }
            });
        }

        // RVA: 0x1EA6B24
        public override void ShowLeaderboards()
        {
            Social.ShowLeaderboardUI();
        }

        // RVA: 0x1EA6B2C
        public override void ShowLeaderboards(Action signOutCallback)
        {
            PlayGamesPlatform.Instance.ShowLeaderboardUI(status =>
            {
                if (status == UIStatus.NotAuthorized && signOutCallback != null)
                {
                    signOutCallback();
                }
            });
        }

        // RVA: 0x1EA6C14
        public override void ReportLeaderboardScore(long score, string boardId, Action<ReportingLeaderboard> onSuccess, Action<GameServiceError> onError)
        {
            Social.ReportScore(score, boardId, success =>
            {
                if (success)
                {
                    if (onSuccess != null)
                    {
                        onSuccess(new ReportingLeaderboard(score, boardId));
                    }
                }
                else if (onError != null)
                {
                    onError(GameServiceError.FailedReportLeaderboard("failed to report score"));
                }
            });
        }

        // RVA: 0x1EA6CE0
        public override void UnlockAchievement(string achievementId)
        {
            Social.ReportProgress(achievementId, 100.0, success => ReportAchievementFinishedEvent(success));
        }

        // RVA: 0x1EA6D74
        public override void ReportAchievement(string achievementId, int numStepBefore, int numStepAfter)
        {
            PlayGamesPlatform.Instance.IncrementAchievement(achievementId, numStepAfter - numStepBefore, success => ReportAchievementFinishedEvent(success));
        }

        // RVA: 0x1EA6E50
        public override void RevealAchievement(string achievementId)
        {
            Social.ReportProgress(achievementId, 0.0, success => ReportAchievementFinishedEvent(success));
        }

        // RVA: 0x1EA6EE0
        public override void LoadSharedData(string name, Action<GameServiceSharedData> onSuccess, Action<GameServiceError> onError)
        {
                        ISavedGameClient savedGame = PlayGamesPlatform.Instance.SavedGame;
                        savedGame.OpenWithAutomaticConflictResolution(name, DataSource.ReadCacheOrNetwork, ConflictResolutionStrategy.UseLongestPlaytime, (SavedGameRequestStatus status, ISavedGameMetadata metadata) =>
                        {
                            if (status == SavedGameRequestStatus.Success)
                            {
                                Logger.Info("loading snapshot succeed");
                                savedGame.ReadBinaryData(metadata, (SavedGameRequestStatus readStatus, byte[] snapshotData) =>
                                {
                                    if (readStatus == SavedGameRequestStatus.Success)
                                    {
                                        Logger.Info("reading snapshot succeed");
                                        GameServiceSharedData gameServiceSharedData = GameServiceSharedData.GetDataFromXml(this, name, snapshotData);
                                        gameServiceSharedData.MetaData = metadata;
                                        if (onSuccess != null)
                                        {
                                            onSuccess(gameServiceSharedData);
                                        }
                                    }
                                    else
                                    {
                                        Logger.Warn("reading snapshot fail:" + readStatus);
                                        if (onError != null)
                                        {
                                            onError(GameServiceError.FailedLoadSharedData("failed to read : " + readStatus));
                                        }
                                    }
                                });
                            }
                            else
                            {
                                Logger.Warn("loading snapshot failed : " + status);
                                if (onError != null)
                                {
                                    onError(GameServiceError.FailedLoadSharedData("failed to load : " + status));
                                }
                            }
                        });
        }

        // RVA: 0x1EA7120
        public override void SaveSharedData(string name, GameServiceSharedData sharedData, Action onSuccess, Action<GameServiceError> onError)
        {
                        SavedGameMetadataUpdate update = new SavedGameMetadataUpdate.Builder().WithUpdatedDescription(sharedData.Description).Build();
                        byte[] xmlData = sharedData.GetXmlData();
                        PlayGamesPlatform.Instance.SavedGame.CommitUpdate(sharedData.MetaData, update, xmlData, (SavedGameRequestStatus status, ISavedGameMetadata metaData) =>
                        {
                            if (status == SavedGameRequestStatus.Success)
                            {
                                Logger.Info("save snapshot success");
                                sharedData.MetaData = metaData;
                                if (OnSuccess != null)
                                {
                                    OnSuccess();
                                }
                            }
                            else
                            {
                                Logger.Warn("save snapshot error:" + status);
                                if (OnError != null)
                                {
                                    OnError(GameServiceError.FailedSaveSharedData("failed to save : " + status));
                                }
                            }
                        });
        }
    }
}
