// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.KlabId.ScopeType
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

namespace Jackpot.Social.KlabId
{
    public class ScopeType : Enumeration<string>
    {
        public static readonly ScopeType TransferUserData;
        public static readonly ScopeType ReferenceUserId;
        public static readonly ScopeType ReferenceUserData;

        // RVA: 0x16B8640
        private ScopeType(string value, string name)
            : base(value, name)
        {
        }

        // RVA: 0x16B86A8
        private static void .cctor()
        {
            TransferUserData = new ScopeType("TransferUserData", "transfer_user_data");
            ReferenceUserId = new ScopeType("ReferenceUserId", "reference_user_id");
            ReferenceUserData = new ScopeType("ReferenceUserData", "reference_user_data");
        }
    }
}
