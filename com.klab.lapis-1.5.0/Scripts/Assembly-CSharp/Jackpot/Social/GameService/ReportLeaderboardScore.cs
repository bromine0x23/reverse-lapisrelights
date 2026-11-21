// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.ReportLeaderboardScore
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
    public class ReportLeaderboardScore
    {
        public string LeaderboardId { get; private set; }
        public long Score { get; private set; }




        // RVA: 0x16B6438
        public void .ctor(string leaderboardId, long score)
        {
            LeaderboardId = leaderboardId;
            Score = score;
        }

        // RVA: 0x16B6470
        public void ReportScore()
        {
            ILogger logger = Logger.Get<ReportLeaderboardScore>();
            logger.Info("start to report store to leaderboard.");
            PlatformGameService.Instance.ReportLeaderboardScore(Score, BoardId,
                ReportResult => logger.Info("success:" + ReportResult.BoardId + "," + ReportResult.Score),
                Error => logger.Error(Error.Message));
        }
    }
}
