// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.ScreenUtil
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
    public static class ScreenUtil
    {
        public static ScreenOrientation lastOrientation;
        public static int Width { get; }
        public static int Height { get; }

        // RVA: 0x13E855C
        public static void SetOrientation(int orientation)
        {
            lastOrientation = (ScreenOrientation)orientation;
            Screen.orientation = (ScreenOrientation)orientation;
        }

        // RVA: 0x13E85D0
        public static int GetOrientation()
        {
            return (int)Screen.orientation;
        }

        // RVA: 0x13E85D8
        public static int get_Width()
        {
            return Screen.width;
        }

        // RVA: 0x13E85E0
        public static int get_Height()
        {
            return Screen.height;
        }

        // RVA: 0x13E85E8
        static ScreenUtil()
        {
            lastOrientation = ScreenOrientation.AutoRotation;
        }
    }
}
