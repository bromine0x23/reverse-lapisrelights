// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.NetworkUtil
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

namespace Oz.Utility
{
    public class NetworkUtil
    {
        public static bool IsCarrier { get; }
        public static bool IsWifi { get; }
        public static bool NetAvailable { get; }

        // RVA: 0x13E8168
        public static bool get_IsCarrier()
        {
            return Application.internetReachability == NetworkReachability.ReachableViaCarrierDataNetwork;
        }

        // RVA: 0x13E8188
        public static bool get_IsWifi()
        {
            return Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork;
        }

        // RVA: 0x13E81A8
        public static bool get_NetAvailable()
        {
            return Application.internetReachability != NetworkReachability.NotReachable;
        }

        // RVA: 0x13E81C8
        public static string GetServiceSlugValue(string host)
        {
            if (host.LastIndexOf("/") < 0)
            {
                return string.Empty;
            }

            return host.Substring(host.LastIndexOf("/") + 1);
        }

        // RVA: 0x13E8270
        public NetworkUtil()
        {
        }
    }
}
