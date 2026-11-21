// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.LastAccessTimePathSet
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

namespace Jackpot
{
    public class LastAccessTimePathSet
    {
        public string Path { get; private set; }
        public DateTime LastAccessTime { get; private set; }




        // RVA: 0x19EDB74
        public void .ctor(string path, DateTime dateTime)
        {
            Path = path;
            LastAccessTime = dateTime;
        }
    }
}
