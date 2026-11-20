// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Kc.Utility.PathUtil
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.IO;
using System.Text;
using Kc.Config;
using Oz.GameFramework.Runtime;
using UnityEngine;

namespace Kc.Utility
{
    /// <summary>平台相关的路径/短哈希计算。</summary>
    public class PathUtil
    {
        /// <summary>
        /// 取得实际存在的资源路径。若持久化目录中不存在，则在
        /// StreamingAssets / PersistentData 根目录下重新拼接；
        /// 仍然不存在且为 AssetBundle 时，回退到日语资源目录。
        /// </summary>
        // RVA: 0x1EE3A08
        public static string GetExistAssetPath(string persistentPath, ref string assetPath, bool isAssetBundle = true)
        {
            if (!File.Exists(persistentPath))
            {
                string streamingAssetsPath = PathUtility.GetStreamingAssetsPath();
                // 路径不在 StreamingAssets 下时以 StreamingAssets 为根，否则用持久化目录
                string basePath = persistentPath.IndexOf(streamingAssetsPath) == -1
                    ? PathUtility.GetStreamingAssetsPath()
                    : PathUtility.GetPersistentDataPath();

                persistentPath = Path.Combine(basePath, assetPath);

                if (!File.Exists(persistentPath) && isAssetBundle)
                {
                    // 常量枚举装箱后 ToString()，即 Language.JP → "JP"
                    string langName = KcAppSetting.Language.JP.ToString();
                    string currentLang = KcAppSetting.CurrentLang;
                    // 去掉路径中的当前语言前缀，替换为日语
                    assetPath = langName + assetPath.Substring(currentLang.Length);
                    return Path.Combine(PathUtility.GetStreamingAssetsPath(), assetPath);
                }
            }
            return persistentPath;
        }

        /// <summary>
        /// 资源短哈希（11 字符 SHA1 前缀），前缀字母区分平台：
        /// iOS 为 "I"，其余为 "A"。
        /// </summary>
        // RVA: 0x1EE3BE4
        public static string GetShortHash(string hash, string version, string name)
        {
            string platformName = GetPlatformName(Application.platform);
            string platformCode = "A";
            if (platformName == "iOS")
            {
                platformCode = "I";
            }
            byte[] bytes = Encoding.UTF8.GetBytes(hash + version + name);
            string sha1 = CryptographyUtil.GetSha1BytesHash(bytes);
            return platformCode + sha1.Substring(0, 11);
        }

        // RVA: 0x1EE3D0C
        public static string GetPlatformName()
        {
            return GetPlatformName(Application.platform);
        }

        // RVA: 0x1EE3D24
        public static string GetPlatformName(RuntimePlatform platform)
        {
            switch (platform)
            {
                case RuntimePlatform.OSXPlayer:
                    return "OSX";
                case RuntimePlatform.WindowsPlayer:
                    return "Windows";
                case RuntimePlatform.IPhonePlayer:
                    return "iOS";
                case RuntimePlatform.Android:
                    return "Android";
                case RuntimePlatform.WebGLPlayer:
                    return "WebGL";
                default:
                    return null;
            }
        }

        // RVA: 0x1EE3DD0
        public PathUtil()
        {
        }
    }
}
