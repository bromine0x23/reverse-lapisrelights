// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.OverrideInfo
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

namespace Oz.ActorModule
{
    public class OverrideInfo
    {
        public string originClip;
        public string overrideClip;

        // RVA: 0x13F500C
        public OverrideInfo(string originClip, string overrideClip)
        {
            this.originClip = originClip;
            this.overrideClip = overrideClip;
        }
    }
}
