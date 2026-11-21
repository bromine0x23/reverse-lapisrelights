// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.BlendShapeHandle
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
    public class BlendShapeHandle
    {
        public string ShapeName;
        public int ShapeIndex;

        // RVA: 0x16B099C
        public BlendShapeHandle(string shape, int index)
        {
            ShapeName = shape;
            ShapeIndex = index;
        }
    }
}
