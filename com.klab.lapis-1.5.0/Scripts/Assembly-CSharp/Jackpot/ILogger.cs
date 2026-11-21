// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.ILogger
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
    public interface ILogger
    {
        public abstract void Debug(string message);
        public abstract void Debug(object obj, object[] moreObjects);
        public abstract void Info(string message);
        public abstract void Info(object obj, object[] moreObjects);
        public abstract void Warn(string message);
        public abstract void Warn(object obj, object[] moreObjects);
        public abstract void Error(string message);
        public abstract void Error(object obj, object[] moreObjects);
        public abstract void Fatal(string message);
        public abstract void Fatal(object obj, object[] moreObjects);
    }
}
