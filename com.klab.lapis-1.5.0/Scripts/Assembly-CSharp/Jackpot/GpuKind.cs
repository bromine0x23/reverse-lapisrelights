// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.GpuKind
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
    public enum GpuKind
    {
        Unknown = 0,
        Apple = 1,
        ApplePowerVR = 2,
        AndroidPowerVR = 4,
        Adreno3xxAndUnder = 8,
        Adreno4xxAndOver = 16,
        Mali = 32,
        MaliOther = 64,
        Tegra = 128,
        TegraK1OrX1 = 256,
        OtherOpenGLES2xAndUnder = 512,
        OtherOpenGLES3xAndOver = 1024,
        Other = 2048
    }
}
