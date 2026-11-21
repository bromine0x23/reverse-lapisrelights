// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.Config
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

namespace Jackpot.Network
{
    public class Config
    {
        private const int DefaultWebConnectionPoolSize = 5;
        private const float DefaultTimeout = 10;
        private const float DefaultMaxTimeout = 60;
        private const int DefaultRetryCount = 0;
        private const int DefaultMaxRetryCount = 3;
        private const float DefaultProgressInterval = 0.5;
        private const int DefaultBundleVersion = 1;
        private const bool DefaultSyncRequest = False;
        private const bool DefaultStubRequest = False;
        private static readonly HTTPRequestType[] DefaultHTTPRequestTypesUsingWebClient;
        public static int WebConnectionPoolSize { get; set; }
        public static float Timeout { get; set; }
        public static float MaxTimeout { get; set; }
        public static int RetryCount { get; set; }
        public static int MaxRetryCount { get; set; }
        public static float ProgressInterval { get; set; }
        public static int BundleVersion { get; set; }
        public static bool SyncRequest { get; set; }
        public static bool StubRequest { get; set; }
        public static Func<HTTPRequest, StubRequestResult> StubRequestProviderFunc { get; set; }
        public static HTTPRequestType[] HTTPRequestTypesUsingWebClient { get; set; }
        public static bool isCertificationSkip { get; set; }
























        // RVA: 0x19F8334
        public static void Clean()
        {
            FillDefault();
            HTTPService.Clean();
            DefaultStubRequestProvider.Clean();
        }

        // RVA: 0x19F88A4
        static Config()
        {
            DefaultHTTPRequestTypesUsingWebClient = new HTTPRequestType[]
            {
                HTTPRequestType.Binary,
                HTTPRequestType.Download,
                HTTPRequestType.Text
            };
            FillDefault();
        }

        // RVA: 0x19F83DC
        private static void FillDefault()
        {
            WebConnectionPoolSize = 5;
            Timeout = 10f;
            MaxTimeout = 60f;
            RetryCount = 0;
            MaxRetryCount = 3;
            ProgressInterval = 0.5f;
            BundleVersion = 1;
            SyncRequest = false;
            StubRequest = false;
            StubRequestProviderFunc = DefaultStubRequestProvider.Request;
            HTTPRequestTypesUsingWebClient = DefaultHTTPRequestTypesUsingWebClient;
            isCertificationSkip = false;
        }

        // RVA: 0x19F893C
        public Config()
        {
        }
    }
}
