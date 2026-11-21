// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  JackpotExamples.NotificationMessageExample
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

namespace JackpotExamples
{
    public class NotificationMessageExample
    {
        public string custom_key_01;
        public string custom_key_02;
        public string custom_key_03;
        public string custom_key_04;
        public string custom_key_05;

        // RVA: 0x16BF920
        public NotificationMessageExample(string message)
        {
                        JsonUtility.FromJsonOverwrite(message, this);
        }

        // RVA: 0x16BFD8C
        private void Initialize(Dictionary<string, object> dict)
        {
                        if (dict.ContainsKey("custom_key_01"))
                        {
                            custom_key_01 = (string)dict["custom_key_01"];
                        }

                        if (dict.ContainsKey("custom_key_02"))
                        {
                            custom_key_02 = (string)dict["custom_key_02"];
                        }

                        if (dict.ContainsKey("custom_key_03"))
                        {
                            custom_key_03 = (string)dict["custom_key_03"];
                        }

                        if (dict.ContainsKey("custom_key_04"))
                        {
                            custom_key_04 = (string)dict["custom_key_04"];
                        }

                        if (dict.ContainsKey("custom_key_05"))
                        {
                            custom_key_05 = (string)dict["custom_key_05"];
                        }
        }

        // RVA: 0x16BFF90
        public override string ToString()
        {
                        return string.Format("custom_key_01 : {0}, custom_key_02 : {1}, custom_key_03 : {2}, custom_key_04 : {3}, custom_key_05 : {4}", custom_key_01, custom_key_02, custom_key_03, custom_key_04, custom_key_05);
        }
    }
}
