// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.BooleanDisposable
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
    public class BooleanDisposable : IDisposable
    {
        public bool IsDisposed { get; private set; }


        // RVA: 0x1786C58
        public BooleanDisposable()
        {
        }

        // RVA: 0x1786C80
        public void Dispose()
        {
            IsDisposed = true;
        }
    }
}
