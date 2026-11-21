// =============================================================================
//  Lapis Re:Lights 1.5.0 — Debugger.dll
//  LuaInterface.ILogger
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

namespace LuaInterface
{
    public interface ILogger
    {
        public abstract void Log(string msg, string stack, LogType type);
    }
}
