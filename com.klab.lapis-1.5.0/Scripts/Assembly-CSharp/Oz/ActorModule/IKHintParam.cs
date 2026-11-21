// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.IKHintParam
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

namespace Oz.ActorModule
{
    public struct IKHintParam
    {
        public AvatarIKHint iKHint;
        public Vector3 position;
        public float weight;

        // RVA: 0x13F15E0
        public IKHintParam(AvatarIKHint iKHint, Vector3 position, float weight)
        {
            this.iKHint = iKHint;
            this.position = position;
            this.weight = weight;
        }
    }
}
