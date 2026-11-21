// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.GameService.ReportingLeaderboard
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
    public class ReportingLeaderboard
    {
        public long Score { get; private set; }
        public string BoardId { get; private set; }




        // RVA: 0x16B40B4
        public void .ctor(long score, string boardId)
        {
            Score = score;
            BoardId = boardId;
        }
    }
}
