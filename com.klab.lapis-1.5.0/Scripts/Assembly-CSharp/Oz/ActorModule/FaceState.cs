// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.FaceState
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
    public class FaceState
    {
        public eFaceExpression Expression;
        public BlendParts BrowBlend;
        public BlendParts EyeBlend;
        public BlendParts MouthBlendOpen;
        public BlendParts MouthBlendHalfClose;
        public BlendParts MouthBlendClose;
        public bool AutoBlink;
        public float CheekPower;
        public float ForeheadShade;
        public float EyeHighlight;
        public float EyeScale;

        // RVA: 0x13F0244
        public FaceState()
        {
        }
    }
}
