// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.AnimUtil
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
    public static class AnimUtil
    {

        // RVA: 0x13E12DC
        public static AnimationState GetAnimState(Animation anim, string clip_name)
        {
            return anim[clip_name];
        }

        // RVA: 0x13E12F4
        public static void SetAnimTime(Animation anim, string clip_name, float time)
        {
            anim[clip_name].time = time;
        }

        // RVA: 0x13E132C
        public static void SetAnimSpeed(Animation anim, string clip_name, float speed)
        {
            anim[clip_name].speed = speed;
        }
    }
}
