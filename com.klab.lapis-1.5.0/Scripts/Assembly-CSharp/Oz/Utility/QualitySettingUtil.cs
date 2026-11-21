// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.QualitySettingUtil
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
    public static class QualitySettingUtil
    {

        // RVA: 0x13E8328
        public static void SetSkinWeights(int skinWeights)
        {
            QualitySettings.skinWeights = skinWeights;
        }

        // RVA: 0x13E8330
        public static void SetQualityLevel(int level)
        {
            QualitySettings.SetQualityLevel(level);
        }

        // RVA: 0x13E8338
        public static void SetShadows(bool enable)
        {
            QualitySettings.shadows = enable ? ShadowQuality.All : ShadowQuality.Disable;
        }

        // RVA: 0x13E834C
        public static bool GetShadows()
        {
            return QualitySettings.shadows != ShadowQuality.Disable;
        }

        // RVA: 0x13E836C
        public static void SetMasterTextureLimit(int limit)
        {
            QualitySettings.masterTextureLimit = limit;
        }
    }
}
