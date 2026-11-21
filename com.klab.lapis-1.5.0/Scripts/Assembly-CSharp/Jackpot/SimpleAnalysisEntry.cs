// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.SimpleAnalysisEntry
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
    public class SimpleAnalysisEntry
    {
        private readonly string key;
        private readonly string value;
        private readonly bool valid;
        public string Key { get { return key; } }
        public string Value { get { return value; } }
        public bool IsValid { get { return valid; } }
        // RVA: 0x1EA4EA8
        public string get_Key()
        {
            return key;
        }

        // RVA: 0x1EA4EB0
        public string get_Value()
        {
            return value;
        }


        // RVA: 0x1EA4EC0
        public void .ctor(string key, string value, bool valid)
        {
            this.key = key;
            this.value = value;
            this.valid = valid;
        }
    }
}
