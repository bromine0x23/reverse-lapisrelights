// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.PlatformMessage.PlatformMessageSetting
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

namespace Jackpot.PlatformMessage
{
    public static class PlatformMessageSetting
    {
        public const string ReceiverName = "PlatformMessageReceiver";
        private static AndroidJavaClass bridgeClass;
        public static GameObject Receiver { get; set; }
        public static bool Initialized { get { return Receiver != null; } }
        public static Uri LastOpenUrl
        {
            get
            {
                string url = GetLastOpenUrlString();
                return string.IsNullOrEmpty(url) ? null : new Uri(url);
            }
        }



        public static void Init<T1>()
        {
            Init(new Type[]
            {
                typeof(T1)
            });
        }

        public static void Init<T1, T2>()
        {
            Init(new Type[]
            {
                typeof(T1), typeof(T2)
            });
        }

        public static void Init<T1, T2, T3>()
        {
            Init(new Type[]
            {
                typeof(T1), typeof(T2), typeof(T3)
            });
        }

        public static void Init<T1, T2, T3, T4>()
        {
            Init(new Type[]
            {
                typeof(T1), typeof(T2), typeof(T3), typeof(T4)
            });
        }

        // RVA: 0x1E9F254
        public static void Init(Type[] types)
        {
            if (Initialized)
            {
                return;
            }

            Receiver = new GameObject(ReceiverName);
            if (types != null && types.Length > 0)
            {
                for (int i = 0; i < types.Length; i++)
                {
                    Receiver.AddComponent(types[i]);
                }
            }

            UnityEngine.Object.DontDestroyOnLoad(Receiver);
        }

        // RVA: 0x1E9F554
        private static string GetLastOpenUrlString()
        {
            return bridgeClass.CallStatic<string>("getLastOpenUrlString", new object[0]);
        }

        // RVA: 0x1E9F674
        private static void .cctor()
        {
            bridgeClass = new AndroidJavaClass("com.klab.jackpot.platformmessage.UnityBridge");
        }
    }
}
