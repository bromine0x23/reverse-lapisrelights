// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.PlatformGameService
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
    public class PlatformGameService : MonoBehaviour
    {
        private static PlatformGameService instance;
        private ILogger logger;
        private AbstractGameService gameService;
        private ContextQueue<ReportAchievementContext> achievementReportQueue;
        public static PlatformGameService Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new GameObject("PlatformGameService").AddComponent<PlatformGameService>();
                }

                return instance;
            }
        }
        public bool IsInitialized { get; private set; }



        // RVA: 0x16B5320
        private void Awake()
        {
            UnityEngine.Object.DontDestroyOnLoad(this);
            logger = Logger.Get<PlatformGameService>();
            IsInitialized = false;
            gameService = null;
            achievementReportQueue = null;
        }

        // RVA: 0x16B53C8
        private void Update()
        {
            if (IsInitialized && achievementReportQueue != null)
            {
                achievementReportQueue.ProcessQueue();
            }
        }

        // RVA: 0x16B5434
        private void OnDestroy()
        {
            if (IsInitialized && gameService != null)
            {
                gameService.Dispose();
            }

            instance = null;
        }

        // RVA: 0x16B54A4
        public void Initialize(SuccessAuthenticationDelegate successAuthentication, FailureAuthenticationDelegate failureAuthentication, bool showDefaultAchievementCompletionBanner, bool enableSharedData = False)
        {
            if (IsInitialized)
            {
                logger.Info("Already initialized");
                return;
            }

            logger.Info("Initialize PlatformGameService");
            switch (Application.platform)
            {
                case RuntimePlatform.Android:
                    gameService = new GameServiceAndroid(successAuthentication, failureAuthentication, enableSharedData);
                    break;
                case RuntimePlatform.IPhonePlayer:
                    gameService = new GameServiceIos(successAuthentication, failureAuthentication, false);
                    break;
                default:
                    gameService = new GameServiceEditor(successAuthentication, failureAuthentication, false);
                    break;
            }

            achievementReportQueue = new ContextQueue<ReportAchievementContext>(gameService);
            IsInitialized = true;
        }

        // RVA: 0x16B56D0
        public void Authenticate()
        {
            if (!IsInitialized)
            {
                logger.Error("PlatformGameService has not been initialized yet.");
                throw new InvalidOperationException();
            }
            gameService.Authenticate();
        }

        // RVA: 0x16B578C
        public void Authenticate(SuccessAuthenticationDelegate successAuthentication, FailureAuthenticationDelegate failureAuthentication)
        {
            if (!IsInitialized)
            {
                logger.Error("PlatformGameService has not been initialized yet.");
                throw new InvalidOperationException();
            }
            gameService.Authenticate(successAuthentication, failureAuthentication);
        }

        // RVA: 0x16B585C
        public bool IsSignedIn()
        {
            return gameService.IsSignedIn();
        }

        // RVA: 0x16B587C
        public string PlayerIdentifier()
        {
            if (!IsInitialized)
            {
                logger.Error("PlatformGameService has not been initialized yet.");
                throw new InvalidOperationException();
            }

            string text = gameService.PlayerIdentifier();
            if (string.IsNullOrEmpty(text))
            {
                logger.Warn("PlayerIdentifier is empty: Not SignedIn");
            }

            return text;
        }

        // RVA: 0x16B59F4
        public void ShowAchievements()
        {
            if (!IsInitialized)
            {
                logger.Error("PlatformGameService has not been initialized yet.");
                throw new InvalidOperationException();
            }
            gameService.ShowAchievements();
        }

        // RVA: 0x16B5AB0
        public void ShowAchievements(Action signOutCallback)
        {
            if (!IsInitialized)
            {
                logger.Error("PlatformGameService has not been initialized yet.");
                throw new InvalidOperationException();
            }
            gameService.ShowAchievements(signOutCallback);
        }

        // RVA: 0x16B5B80
        public void ShowLeaderboards()
        {
            if (!IsInitialized)
            {
                logger.Error("PlatformGameService has not been initialized yet.");
                throw new InvalidOperationException();
            }
            gameService.ShowLeaderboards();
        }

        // RVA: 0x16B5C40
        public void ShowLeaderboards(Action signOutCallback)
        {
            if (!IsInitialized)
            {
                logger.Error("PlatformGameService has not been initialized yet.");
                throw new InvalidOperationException();
            }
            gameService.ShowLeaderboards(signOutCallback);
        }

        // RVA: 0x16B5D10
        public void ReportAchievement(ReportAchievementContext context)
        {
            if (!IsInitialized)
            {
                logger.Error("PlatformGameService has not been initialized yet.");
                throw new InvalidOperationException();
            }
            achievementReportQueue.Enqueue(context);
        }

        // RVA: 0x16B5E10
        public void ReportLeaderboardScore(long score, string boardId, Action<ReportingLeaderboard> onSuccess, Action<GameServiceError> onError)
        {
            if (!IsInitialized)
            {
                logger.Error("PlatformGameService has not been initialized yet.");
                throw new InvalidOperationException();
            }
            gameService.ReportLeaderboardScore(score, boardId, onSuccess, onError);
        }

        // RVA: 0x16B5F34
        public void LoadSharedData(string name, Action<GameServiceSharedData> onSuccess, Action<GameServiceError> onError)
        {
            gameService.LoadSharedData(name, onSuccess, onError);
        }

        // RVA: 0x16B5F58
        public PlatformGameService()
        {
        }
    }
}
