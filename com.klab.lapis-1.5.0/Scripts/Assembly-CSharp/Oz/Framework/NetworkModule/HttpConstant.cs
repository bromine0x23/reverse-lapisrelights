// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.HttpConstant
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================


namespace Oz.Framework.NetworkModule
{
    /// <summary>HTTP 头字段名常量。</summary>
    public class HttpConstant
    {
        public static string X_PLAYER_ID_META_KEY;
        public static string X_APP_VERSION_META_KEY;
        public static string X_RES_VERSION_META_KEY;
        public static string X_APP_PLATFORM_META_KEY;
        public static string X_SERVICE_SLUG_META_KEY;
        public static string X_SIGNATURE_META_KEY;
        public static string X_APP_LANG_META_KEY;
        public static string X_APP_PATH;
        public static string X_APP_VIRTUAL_UT;

        // RVA: 0x2EE0878
        public HttpConstant()
        {
        }

        // RVA: 0x2EE0880
        static HttpConstant()
        {
            X_PLAYER_ID_META_KEY = "x-player-id";
            X_APP_VERSION_META_KEY = "x-app-version";
            X_RES_VERSION_META_KEY = "x-res-version";
            X_APP_PLATFORM_META_KEY = "x-app-platform";
            X_SERVICE_SLUG_META_KEY = "x-service-slug";
            X_SIGNATURE_META_KEY = "x-app-signature";
            X_APP_LANG_META_KEY = "x-app-lang";
            X_APP_PATH = "x-app-path";
            X_APP_VIRTUAL_UT = "x-app-virtual-ut";
        }
    }
}
