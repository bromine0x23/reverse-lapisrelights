// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.IMaterialPropertyBlockModifier
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

namespace Oz.Timeline
{
    public interface IMaterialPropertyBlockModifier : ITimelineBinding
    {
        public abstract void SetMaterialProperty(string name, float value);
        public abstract void SetMaterialProperty(string name, Vector4 value);
        public abstract void SetMaterialProperty(string name, Color value);
        public abstract void ClearMaterialPropertyBlock();
    }
}
