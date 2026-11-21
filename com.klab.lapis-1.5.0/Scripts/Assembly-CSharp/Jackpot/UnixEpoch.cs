// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.UnixEpoch
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

namespace Jackpot
{
    public class UnixEpoch
    {
        private static readonly DateTime epochTime;

        // RVA: 0x16BD414
        public static DateTime ToDateTime(long unixTimeStamp)
        {
            return epochTime.AddSeconds(unixTimeStamp).ToLocalTime();
        }

        // RVA: 0x16BD4B0
        public static long FromDateTime(DateTime dateTime)
        {
            return (long)(dateTime.ToUniversalTime() - epochTime).TotalSeconds;
        }

        // RVA: 0x16BD55C
        public UnixEpoch()
        {
        }

        // RVA: 0x16BD564
        static UnixEpoch()
        {
            epochTime = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
        }
    }
}
