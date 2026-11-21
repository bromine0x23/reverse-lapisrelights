// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.TaggedPathSet
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
    public class TaggedPathSet
    {
        public string Tag { get; private set; }
        public string Path { get; private set; }




        // RVA: 0x16BC624
        public void .ctor(string tag, string path)
        {
            Tag = tag;
            Path = path;
        }
    }
}
