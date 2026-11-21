// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.GuidEqualityComparer
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
    public class GuidEqualityComparer : IEqualityComparer<Guid>
    {

        // RVA: 0x19F286C
        public bool Equals(Guid x, Guid y)
        {
            return x.Equals(y);
        }

        // RVA: 0x19F28A0
        public int GetHashCode(Guid obj)
        {
            return obj.GetHashCode();
        }

        // RVA: 0x19F28C8
        public GuidEqualityComparer()
        {
        }
    }
}
