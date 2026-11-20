// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.BlendWeight
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
    public class BlendWeight
    {
        public BlendShapeHandle Handle;
        public float Weight;

        // RVA: 0x16B0898
        public BlendWeight(BlendShapeHandle handle, float weight)
        {
            Handle = handle;
            Weight = weight;
        }
    }
}
