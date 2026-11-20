// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.AppConst
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.GameFramework.Runtime
{
    /// <summary>全局运行参数（ScriptableObject，运行时从 Resources 加载 "AppConst"）。</summary>
    public class AppConst : ScriptableObject
    {
        public const string APP_CONST_PATH = "AppConst";

        private static AppConst m_Current;

        private byte[] m_RgbKey;
        private byte[] m_RgbIV;
        private bool m_CompressLuaData;
        private string m_Language;
        private string m_Platform;
        private List<string> m_BootInfoUri;
        private bool m_LRUEnable;
        private bool m_AssetBundleMode;
        private bool m_SDKMode;
        private bool m_ExtractMode;
        private List<string> m_CdnDomains;
        private List<string> m_ServerListURLs;

        // RVA: 0x2E90108
        private static AppConst Current
        {
            get
            {
                if (m_Current == null)
                {
                    m_Current = Resources.Load<AppConst>(APP_CONST_PATH);
                }
                return m_Current;
            }
        }

        /// <summary>AES 密钥（32 字节，代码内常量）。</summary>
        public static byte[] rgbKey
        {
            // RVA: 0x2E901C0
            get { return Current.m_RgbKey; }
        }

        /// <summary>AES IV（16 字节，代码内常量）。</summary>
        public static byte[] rgbIV
        {
            // RVA: 0x2E901E0
            get { return Current.m_RgbIV; }
        }

        public static bool CompressLuaData
        {
            // RVA: 0x2E90200
            get { return Current.m_CompressLuaData; }
            // RVA: 0x2E90220
            set { Current.m_CompressLuaData = value; }
        }

        public static string Language
        {
            // RVA: 0x2E90250
            get { return Current.m_Language; }
            // RVA: 0x2E90270
            set { Current.m_Language = value; }
        }

        public static string Platform
        {
            // RVA: 0x2E9029C
            get { return Current.m_Platform; }
            // RVA: 0x2E902BC
            set { Current.m_Platform = value; }
        }

        public static List<string> BootInfoUri
        {
            // RVA: 0x2E902E8
            get { return Current.m_BootInfoUri; }
            // RVA: 0x2E90308
            set { Current.m_BootInfoUri = value; }
        }

        public static bool LRUEnable
        {
            // RVA: 0x2E90334
            get { return Current.m_LRUEnable; }
            // RVA: 0x2E90354
            set { Current.m_LRUEnable = value; }
        }

        public static bool AssetBundleMode
        {
            // RVA: 0x2E90384
            get { return Current.m_AssetBundleMode; }
            // RVA: 0x2E903A4
            set { Current.m_AssetBundleMode = value; }
        }

        public static bool SDKMode
        {
            // RVA: 0x2E903D4
            get { return Current.m_SDKMode; }
            // RVA: 0x2E903F4
            set { Current.m_SDKMode = value; }
        }

        public static bool ExtractMode
        {
            // RVA: 0x2E90424
            get { return Current.m_ExtractMode; }
            // RVA: 0x2E90444
            set { Current.m_ExtractMode = value; }
        }

        public static List<string> CdnDomains
        {
            // RVA: 0x2E90474
            get { return Current.m_CdnDomains; }
            // RVA: 0x2E90494
            set { Current.m_CdnDomains = value; }
        }

        public static List<string> ServerListURLs
        {
            // RVA: 0x2E904C0
            get { return Current.m_ServerListURLs; }
            // RVA: 0x2E904E0
            set { Current.m_ServerListURLs = value; }
        }

        // RVA: 0x2E9050C
        public AppConst()
        {
            // 原始为 RuntimeHelpers.InitializeArray，字段默认值位于 global-metadata.dat：
            //   m_RgbKey <- <PrivateImplementationDetails>.664D6B3A...B52（Metadata offset 0x52D906，32B）
            //   m_RgbIV  <- <PrivateImplementationDetails>.96053D1A...3A5（Metadata offset 0x52D926，16B）
            m_RgbKey = new byte[]
            {
                0x9E, 0xC4, 0x73, 0xAE, 0x66, 0x2F, 0x4E, 0x2A,
                0x59, 0x2A, 0x50, 0x2B, 0x90, 0x3C, 0x9E, 0xC4,
                0x73, 0xAE, 0x66, 0x2F, 0x4E, 0x2A, 0x8D, 0x85,
                0x7E, 0xA7, 0x59, 0x27, 0x50, 0xBB, 0x90, 0x3C,
            };
            m_RgbIV = new byte[]
            {
                0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7,
                0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF,
            };
            m_BootInfoUri = new List<string>();
            m_CdnDomains = new List<string>();
            m_ServerListURLs = new List<string>();
        }
    }
}
