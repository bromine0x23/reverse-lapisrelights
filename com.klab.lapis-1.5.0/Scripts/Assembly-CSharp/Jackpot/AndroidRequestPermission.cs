// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.AndroidRequestPermission
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot
{
    public class AndroidRequestPermission
    {
        private static Action GrantedRequestPermission;
        private static Action DeniedRequestPermission;
        private static Action<int, string> NeedExplainRequestPermission;
        private static AndroidJavaObject plugin;

        // RVA: 0x176A7EC
        public static void add_GrantedRequestPermission(Action value)
        {
                        GrantedRequestPermission b;
                        GrantedRequestPermission c;
                        do
                        {
                            b = GrantedRequestPermission;
                            c = (Action)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref GrantedRequestPermission, c, b) != b);
        }

        // RVA: 0x176A8D8
        public static void remove_GrantedRequestPermission(Action value)
        {
                        GrantedRequestPermission b;
                        GrantedRequestPermission c;
                        do
                        {
                            b = GrantedRequestPermission;
                            c = (Action)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref GrantedRequestPermission, c, b) != b);
        }

        // RVA: 0x176A9C4
        public static void add_DeniedRequestPermission(Action value)
        {
                        DeniedRequestPermission b;
                        DeniedRequestPermission c;
                        do
                        {
                            b = DeniedRequestPermission;
                            c = (Action)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref DeniedRequestPermission, c, b) != b);
        }

        // RVA: 0x176AAB4
        public static void remove_DeniedRequestPermission(Action value)
        {
                        DeniedRequestPermission b;
                        DeniedRequestPermission c;
                        do
                        {
                            b = DeniedRequestPermission;
                            c = (Action)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref DeniedRequestPermission, c, b) != b);
        }

        // RVA: 0x176ABA4
        public static void add_NeedExplainRequestPermission(Action<int, string> value)
        {
                        NeedExplainRequestPermission b;
                        NeedExplainRequestPermission c;
                        do
                        {
                            b = NeedExplainRequestPermission;
                            c = (Action<int, string>)Delegate.Combine(b, value);
                        }
                        while (Interlocked.CompareExchange(ref NeedExplainRequestPermission, c, b) != b);
        }

        // RVA: 0x176AC94
        public static void remove_NeedExplainRequestPermission(Action<int, string> value)
        {
                        NeedExplainRequestPermission b;
                        NeedExplainRequestPermission c;
                        do
                        {
                            b = NeedExplainRequestPermission;
                            c = (Action<int, string>)Delegate.Remove(b, value);
                        }
                        while (Interlocked.CompareExchange(ref NeedExplainRequestPermission, c, b) != b);
        }

        // RVA: 0x176AD84
        static AndroidRequestPermission()
        {
                        plugin = new AndroidJavaClass("com.klab.jackpot.UnityPermissionBridge");
        }

        // RVA: 0x176ADFC
        public static void Finish()
        {
                        plugin.CallStatic("finish", Array.Empty<object>());
        }

        // RVA: 0x176AF14
        public static void StartRequestPermission(string permission)
        {
                        plugin.CallStatic("startRequestPermission", permission, new AndroidRequestPermission.AndroidRequestPermissionListener());
        }

        // RVA: 0x176B0B4
        public static void RequestPermission(string permission)
        {
                        plugin.CallStatic("requestPermission", permission);
        }

        // RVA: 0x176B1A0
        public static void OpenSettings()
        {
                        plugin.CallStatic("openSettings", Array.Empty<object>());
        }

        // RVA: 0x176B2B8
        public AndroidRequestPermission()
        {
        }

        public class AndroidRequestPermissionListener
        {
            public void requestPermissionGranted()
            {
                MainThreadDispatcher.Post(delegate
                {
                    GrantedRequestPermission?.Invoke();
                });
            }

            public void requestPermissionDenied()
            {
                MainThreadDispatcher.Post(delegate
                {
                    DeniedRequestPermission?.Invoke();
                });
            }

            public void requestPermissionNeedExplain(int kind, string permission)
            {
                MainThreadDispatcher.Post(delegate
                {
                    NeedExplainRequestPermission?.Invoke(kind, permission);
                });
            }
        }
    }
}
