// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.OlsonMapper
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

namespace Jackpot
{
    public class OlsonMapper
    {
        private static Dictionary<string, string> olsonMap;

        // RVA: 0x1E9DDA0
        public static string Find(string timeZoneId)
        {
            if (string.IsNullOrEmpty(timeZoneId))
            {
                throw new ArgumentNullException(string.Format("timeZoneId was null. timeZoneId:{0}", timeZoneId));
            }

            return olsonMap[timeZoneId];
        }

        // RVA: 0x1E9DE88
        public OlsonMapper()
        {
        }

        // RVA: 0x1E9DE90
        static OlsonMapper()
        {
            olsonMap = new Dictionary<string, string>
            {
                { "Dateline Standard Time", "Etc/GMT+12" },
                { "UTC-11", "Etc/GMT+11" },
                { "Hawaiian Standard Time", "Pacific/Honolulu" },
                { "Alaskan Standard Time", "America/Anchorage" },
                { "Pacific Standard Time (Mexico)", "America/Santa_Isabel" },
                { "Pacific Standard Time", "America/Los_Angeles" },
                { "US Mountain Standard Time", "America/Phoenix" },
                { "Mountain Standard Time (Mexico)", "America/Chihuahua" },
                { "Mountain Standard Time", "America/Denver" },
                { "Central Standard Time (Mexico)", "America/Mexico_City" },
                { "Canada Central Standard Time", "America/Regina" },
                { "Central America Standard Time", "America/Guatemala" },
                { "Central Standard Time", "America/Chicago" },
                { "US Eastern Standard Time", "America/Indianapolis" }
            };
        }
    }
}
