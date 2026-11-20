// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Kc.Config.KcAppSetting
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Text;
using System.Text.RegularExpressions;
using UnityEngine;

namespace Kc.Config
{
    /// <summary>
    /// 全局配置（ScriptableObject，运行时从 Resources 加载 "KcAppSetting"）。
    /// 同时承载服务器地址、平台密钥、SQLite/协议加密开关等静态配置。
    /// </summary>
    [CreateAssetMenu]
    public class KcAppSetting : ScriptableObject
    {
        /// <summary>界面/资源语言。</summary>
        public enum Language
        {
            CN = 0,
            JP = 1,
            EN = 2,
            TW = 3
        }

        public const string KC_APP_CONST_PATH = "KcAppSetting";

        private static KcAppSetting m_Current;

        [SerializeField]
        private bool luaEncrypt;
        [SerializeField]
        private string l10nPath;
        [SerializeField]
        private string assetBundleOutputPath;
        [SerializeField]
        private string androidCdnURL;
        [SerializeField]
        private string iosCdnURL;
        [SerializeField]
        private string editorCdnURL;
        [SerializeField]
        private string l10nCode;
        [SerializeField]
        private bool enabledDebugMenu;
        [SerializeField]
        private bool developBuild;
        [SerializeField]
        private string googleStoreUrl;
        [SerializeField]
        private string iosStoreUrl;
        [SerializeField]
        private bool useSecrityAsset;
        [SerializeField]
        private bool useUrlCompress;

        public static string ApiEndPoint;
        public static string ApiEndPointHttpOneSlug;
        public static int ApiPort;
        public static string KlabIdEndpointUrl;
        public static string KlabIdClientId;
        public static string KLabIdUrlScheme;
        public static byte[] StartUpKey;
        public static string RsaPublicKey;
        public static byte[] SessionKey;
        public static bool EnablePlatformGameService;
        public static bool EnableSqlLiteEncrypt;
        public static bool EnableProtocolEncrypt;
        public static uint SqliteKey1;
        public static uint SqliteKey2;
        public static uint SqliteKey3;

        // RVA: 0x1EDFFD4
        private static KcAppSetting Current
        {
            get
            {
                if (m_Current == null)
                {
                    m_Current = Resources.Load<KcAppSetting>(KC_APP_CONST_PATH);
                }
                return m_Current;
            }
        }

        /// <summary>当前语言代码（"CN"/"JP"/"EN"/"TW"），由 PlayerPrefs 记忆。</summary>
        // RVA: 0x1EE00E0 / 0x1EE0270
        public static string CurrentLang
        {
            get
            {
                if (!PlayerPrefs.HasKey("CurrentLanguage"))
                {
                    // 未记录时按当前 l10nCode 解析一次并写入 PlayerPrefs
                    object parsed = Enum.Parse(typeof(Language), Current.l10nCode);
                    PlayerPrefs.SetInt("CurrentLanguage", (int)parsed);
                }
                return ((Language)PlayerPrefs.GetInt("CurrentLanguage")).ToString();
            }
            set
            {
                Language lang;
                if (Enum.TryParse<Language>(value, out lang))
                {
                    PlayerPrefs.SetInt("CurrentLanguage", (int)lang);
                    PlayerPrefs.Save();
                }
            }
        }

        // RVA: 0x1EE0318
        public static KcAppSetting.Language GetCurrentLang()
        {
            return (Language)Enum.Parse(typeof(Language), CurrentLang);
        }

        // RVA: 0x1EE0424
        public static string CDNURL
        {
            get { return Current.androidCdnURL; }
        }

        // RVA: 0x1EE0490
        public static string AndroidCdnURL
        {
            set { Current.androidCdnURL = value; }
        }

        // RVA: 0x1EE0500
        public static string IosCdnURL
        {
            set { Current.iosCdnURL = value; }
        }

        // RVA: 0x1EE0570
        public static string EditorCdnURL
        {
            set { Current.editorCdnURL = value; }
        }

        // RVA: 0x1EE05E0 / 0x1EE064C
        public static bool UseSecrityAsset
        {
            get { return Current.useSecrityAsset; }
            set { Current.useSecrityAsset = value; }
        }

        // RVA: 0x1EE06C0 / 0x1EE072C
        public static bool UseUrlCompress
        {
            get { return Current.useUrlCompress; }
            set { Current.useUrlCompress = value; }
        }

        // RVA: 0x1EE0814 / 0x1EE07A0
        public static bool LuaEncrypt
        {
            get { return Current.luaEncrypt; }
            set { Current.luaEncrypt = value; }
        }

        // RVA: 0x1EE0880
        public static string GoogleStoreUrl
        {
            get { return Current.googleStoreUrl; }
        }

        // RVA: 0x1EE08EC
        public static string IosStoreUrl
        {
            get { return Current.iosStoreUrl; }
        }

        /// <summary>开发模式下强制开启调试菜单。</summary>
        // RVA: 0x1EE0958 / 0x1EE0A60
        public static bool EnabledDebugMenu
        {
            get { return DevelopBuild || Current.enabledDebugMenu; }
            set { Current.enabledDebugMenu = value; }
        }

        // RVA: 0x1EE0AD4 / 0x1EE0B40
        public static string L10nCode
        {
            get { return Current.l10nCode; }
            set { Current.l10nCode = value; }
        }

        // RVA: 0x1EE09F4 / 0x1EE0BB0
        public static bool DevelopBuild
        {
            get { return Current.developBuild; }
            set { Current.developBuild = value; }
        }

        // RVA: 0x1EE0C24 / 0x1EE0C90
        public static string L10nPath
        {
            get { return Current.l10nPath; }
            set { Current.l10nPath = value; }
        }

        // RVA: 0x1EE0D00 / 0x1EE0D6C
        public static string AssetBundleOutputPath
        {
            get { return Current.assetBundleOutputPath; }
            set { Current.assetBundleOutputPath = value; }
        }

        // RVA: 0x1EE0DDC
        public static string NoticeEndPoint
        {
            get { return ApiEndPoint; }
        }

        /// <summary>
        /// HttpOne 网关地址：{http|https}://{ApiEndPoint}:{ApiPort}{ApiEndPointHttpOneSlug}。
        /// ApiEndPoint 为纯 IP 时使用 http。
        /// </summary>
        // RVA: 0x1EE0E44
        public static string HttpOneEndPoint
        {
            get
            {
                string scheme = "https://";
                string apiEndPoint = ApiEndPoint;
                if (Regex.IsMatch(apiEndPoint, "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"))
                {
                    scheme = "http://";
                }
                object[] args = new object[5];
                args[0] = scheme;
                args[1] = ApiEndPoint;
                args[2] = ":";
                args[3] = ApiPort;
                args[4] = ApiEndPointHttpOneSlug;
                return string.Concat(args);
            }
        }

        /// <summary>维护公告地址：{scheme}://{host}:{ApiPort}/200metadata.json。</summary>
        // RVA: 0x1EE1080
        public static string MaintainUrl
        {
            get
            {
                string scheme = "https://";
                string host = ApiEndPoint.Split(new char[] { '/' })[0];
                if (Regex.IsMatch(host, "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"))
                {
                    scheme = "http://";
                }
                object[] args = new object[5];
                args[0] = scheme;
                args[1] = host;
                args[2] = ":";
                args[3] = ApiPort;
                args[4] = "/200metadata.json";
                return string.Concat(args);
            }
        }

        /// <summary>资源更新根地址：https://{host}/assets/。</summary>
        // RVA: 0x1EE1304
        public static string UpdateURL
        {
            get
            {
                string host = ApiEndPoint.Split(new char[] { '/' })[0];
                return "https://" + host + "/assets/";
            }
        }

        // RVA: 0x1EE13E4 / 0x1EE14A4
        public static bool? IsAutoGPGSSignIn
        {
            get
            {
                if (!PlayerPrefs.HasKey("IsAutoGPGSSignIn"))
                {
                    return null;
                }
                return Convert.ToBoolean(PlayerPrefs.GetInt("IsAutoGPGSSignIn"));
            }
            set
            {
                if (value.HasValue)
                {
                    PlayerPrefs.SetInt("IsAutoGPGSSignIn", Convert.ToInt32(value.Value));
                }
                else
                {
                    PlayerPrefs.DeleteKey("IsAutoGPGSSignIn");
                }
            }
        }

        /// <summary>SQLite 客户端主密钥（可选语言库密钥），存于 PlayerPrefs。</summary>
        // RVA: 0x1EE1580
        public static string GetSqlClientKey(bool isLang = false)
        {
            return PlayerPrefs.GetString(isLang ? KlabVfs.MASTER_LANG_KEY : KlabVfs.MASTER_KEY, "");
        }

        // RVA: 0x1EE1620
        public KcAppSetting()
        {
        }

        // RVA: 0x1EE1628
        static KcAppSetting()
        {
            ApiEndPoint = "prod-lapis.you-zhe.com/production";
            ApiEndPointHttpOneSlug = "/game.Lapis/Call";
            ApiPort = 443;
            KlabIdEndpointUrl = "https://www.id.klabgames.net";
            KlabIdClientId = "lapis-jp-prod";
            KLabIdUrlScheme = "com.klab.lapis";
            StartUpKey = Encoding.UTF8.GetBytes("jaP7eO2ZwjkLOJ52ztULZ5G46z3cWZWo");
            RsaPublicKey = "<RSAKeyValue><Modulus>wGGKQ/NgdtLhISSeyohcCk50qbyth4m+iTvZuk9V4FloWFttaHdfTuEGrDcYPFyR2dS6tkCnBnk1jcC1aOpSqnbHMCJWpcmX9wSdSJrGPsPiR2XtuS/RHMCR4SMAneV26q9Znd/rZ/FHNSRE5/XdyRkZoeETAthuv3U1VJ7FPJc=</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>";
            // 原始为 RuntimeHelpers.InitializeArray(SessionKey, field)：
            // field = <PrivateImplementationDetails>.0713EC4ED90FBC961E94939B05BA70CDB5C9DF76
            // （global-metadata.dat Metadata offset 0x5355BC，32 字节）
            SessionKey = new byte[]
            {
                0x0B, 0xF7, 0xC1, 0xED, 0xB9, 0x27, 0x82, 0xE0,
                0x74, 0xEF, 0x61, 0xF9, 0x2D, 0x6D, 0x6C, 0xE2,
                0x6C, 0xC8, 0x1A, 0xCD, 0x6E, 0xAA, 0x0D, 0xEA,
                0x7B, 0xFD, 0x39, 0x30, 0xBD, 0x8C, 0x11, 0x9F,
            };
            EnablePlatformGameService = true;
            EnableSqlLiteEncrypt = true;
            EnableProtocolEncrypt = true;
        }
    }
}
