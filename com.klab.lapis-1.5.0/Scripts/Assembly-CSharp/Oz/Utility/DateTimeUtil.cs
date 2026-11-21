// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.DateTimeUtil
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

namespace Oz.Utility
{
    public static class DateTimeUtil
    {
        public static DateTime S_TimeSice1970;
        public static bool S_TimeHasSet;
        public static int TimeDifference { get; }

        // RVA: 0x13E2024
        public static double GetCurrentTime()
        {
            if (!S_TimeHasSet)
            {
                S_TimeSice1970 = new DateTime(1970, 1, 1).ToLocalTime();
                S_TimeHasSet = true;
            }

            return (DateTime.Now - S_TimeSice1970).TotalSeconds;
        }

        // RVA: 0x13E217C
        public static bool IsSameDay(long millisec1, long millisec2)
        {
            DateTime time1 = new DateTime(millisec1 * 10000).ToLocalTime();
            DateTime time2 = new DateTime(millisec2 * 10000).ToLocalTime();

            if (time1.Year != time2.Year)
            {
                return false;
            }
            if (time1.Month != time2.Month)
            {
                return false;
            }

            return time1.Day == time2.Day;
        }

        // RVA: 0x13E225C
        public static string GetCurrentDay(long millisec)
        {
            DateTime dateTime = TimeZone.CurrentTimeZone
                .ToLocalTime(new DateTime(1970, 1, 1))
                .AddMilliseconds(millisec);

            // 原代码在此丢弃了一次 ToString("T") 的返回值
            dateTime.ToString("T");
            return dateTime.ToString("yyyy-MM-dd HH:mm:ss");
        }

        // RVA: 0x13E2354
        public static int get_TimeDifference()
        {
            TimeSpan offset = new DateTimeOffset(
                new DateTime(2017, 1, 1, 0, 0, 0, DateTimeKind.Utc)).Offset;

            return offset.Hours * 3600 + offset.Minutes * 60 + offset.Seconds;
        }

        // RVA: 0x13E2410
        static DateTimeUtil()
        {
        }
    }
}
