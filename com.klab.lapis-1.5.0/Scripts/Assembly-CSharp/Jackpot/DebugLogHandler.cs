// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.DebugLogHandler
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
    internal class DebugLogHandler : ILoggerHandler
    {
        private readonly bool isDebugBuild;

        // RVA: 0x19E2264
        public static void Initialize()
        {
            if (Debug.isDebugBuild)
            {
                Logger.AddHandler(new DebugLogHandler(Debug.isDebugBuild));
            }
        }

        // RVA: 0x19E2348
        public DebugLogHandler(bool isDebugBuild)
        {
        }

        // RVA: 0x19E24A0
        public void HandleLog(LoggerReport report)
        {
            try
            {
                if (isDebugBuild)
                {
                    Platform.Log(report);
                }
            }
            catch (Exception e)
            {
                Debug.LogError("DebugLogHandler Error: " + e.ToString());
                if (report != null)
                {
                    Debug.LogError(report.ToString());
                }
            }
        }
    }
}
