// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.LoggerReport
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
    public class LoggerReport
    {
        public DateTime Date { get; private set; }
        public LogLevel LogLevel { get; private set; }
        public string CallerName { get; private set; }
        public string Message { get; private set; }








        // RVA: 0x19F50B4
        public void .ctor(LogLevel level, string callerName, string message)
        {
            Date = DateTime.Now;
            LogLevel = level;
            CallerName = callerName;
            Message = message;
        }

        // RVA: 0x19F53CC
        public override string ToString()
        {
            return string.Format("[{0}][{1}][{2}]{3}", Date.ToString(), LogLevel, CallerName, Message);
        }
    }
}
