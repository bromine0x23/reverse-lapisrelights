// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.PathUtility
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Text;
using UnityEngine;

namespace Oz.GameFramework.Runtime
{
    /// <summary>持久化目录 / StreamingAssets 路径与资源名换算。</summary>
    public class PathUtility
    {
        public const string ASSETBUNDLE_EXTENSION = ".bdl";
        public const string SOUNDBANK_EXTENSION = ".bnk";
        public const string HASH_EXTENSION = ".hash";

        // RVA: 0x2E92E84
        public static string GetPersistentDataURI()
        {
            return "file://" + Application.persistentDataPath + "/";
        }

        // RVA: 0x2E92EEC
        public static string GetPersistentDataPath()
        {
            return Application.persistentDataPath + "/";
        }

        /// <summary>
        /// StreamingAssets 的 URI：编辑器用工程目录，Android 用 jar:file://...!/assets/，
        /// iOS 用 file://.../Raw/，其他移动/主机平台用 file://.../StreamingAssets/。
        /// </summary>
        // RVA: 0x2E92F40
        public static string GetStreamingAssetsURI()
        {
            if (Application.isEditor)
            {
                string dir = Environment.CurrentDirectory.Replace("\\", "/");
                return "file://" + dir + "/Assets/StreamingAssets/";
            }
            if (!Application.isMobilePlatform && !Application.isConsolePlatform)
            {
                return "file://" + Application.streamingAssetsPath;
            }

            string dataPath = Application.dataPath;
            switch (Application.platform)
            {
                case RuntimePlatform.Android:
                    return "jar:file://" + dataPath + "!/assets/";
                case RuntimePlatform.IPhonePlayer:
                    return "file://" + dataPath + "/Raw/";
                default:
                    return "file://" + dataPath + "/StreamingAssets/";
            }
        }

        // RVA: 0x2E9308C
        public static string GetStreamingAssetsPath()
        {
            if (Application.isEditor)
            {
                string dir = Environment.CurrentDirectory.Replace("\\", "/");
                return dir + "/Assets/StreamingAssets/";
            }
            if (!Application.isMobilePlatform && !Application.isConsolePlatform)
            {
                return Application.streamingAssetsPath;
            }

            string dataPath = Application.dataPath;
            switch (Application.platform)
            {
                case RuntimePlatform.Android:
                    return dataPath + "!assets/";
                case RuntimePlatform.IPhonePlayer:
                    return dataPath + "/Raw/";
                default:
                    return dataPath + "/StreamingAssets/";
            }
        }

        /// <summary>去掉 ".bdl" 后缀得到 AssetBundle 名。</summary>
        // RVA: 0x2E93190
        public static bool AssetBundleFileNameToAssetBundleName(string assetBundleFileName, out string assetBundleName)
        {
            if (assetBundleFileName.EndsWith(ASSETBUNDLE_EXTENSION))
            {
                int index = assetBundleFileName.LastIndexOf(ASSETBUNDLE_EXTENSION, StringComparison.Ordinal);
                assetBundleName = assetBundleFileName.Remove(index);
                return true;
            }
            assetBundleName = string.Empty;
            return false;
        }

        /// <summary>去掉 ".bnk" 后缀得到 SoundBank 名。</summary>
        // RVA: 0x2E93248
        public static bool SoundBankFileNameToSoundBankName(string soundBankFileName, out string soundBankName)
        {
            if (soundBankFileName.EndsWith(SOUNDBANK_EXTENSION))
            {
                int index = soundBankFileName.LastIndexOf(SOUNDBANK_EXTENSION, StringComparison.Ordinal);
                soundBankName = soundBankFileName.Remove(index);
                return true;
            }
            soundBankName = string.Empty;
            return false;
        }

        /// <summary>资源路径（"dir/name"）→ (AssetBundle 名, 资源名)。</summary>
        // RVA: 0x2E93300
        public static bool ResourcePathToBundlePath(string resourcePath, out string assetBundleName, out string assetName)
        {
            if (resourcePath.Contains("/") && !resourcePath.EndsWith("/"))
            {
                assetBundleName = AssetPathToABName(ResPathToBundleAssetPath(resourcePath));
                assetName = ResPathToAssetName(resourcePath);
                return !string.IsNullOrEmpty(assetBundleName) && !string.IsNullOrEmpty(assetName);
            }

            Debug.LogWarning("Invalid resource path: " + resourcePath);
            assetBundleName = string.Empty;
            assetName = string.Empty;
            return false;
        }

        // RVA: 0x2E9344C
        public static string ResPathToABName(string resourcePath)
        {
            return AssetPathToABName(ResPathToBundleAssetPath(resourcePath));
        }

        /// <summary>取最后一个 '/' 之后的资源名（小写）。</summary>
        // RVA: 0x2E93460
        public static string ResPathToAssetName(string resourcePath)
        {
            int index = resourcePath.LastIndexOf('/');
            if (index == -1)
            {
                return string.Empty;
            }
            return resourcePath.Remove(0, index + 1).ToLower();
        }

        // RVA: 0x2E934FC
        public static string ResPathToBundleAssetPath(string resourcePath)
        {
            return "Assets/Products/Resources/" + resourcePath;
        }

        /// <summary>取最后一个 '/' 之前的路径（小写）作为 AssetBundle 名。</summary>
        // RVA: 0x2E93550
        public static string AssetPathToABName(string assetPath)
        {
            int index = assetPath.LastIndexOf('/');
            if (index == -1)
            {
                return string.Empty;
            }
            return assetPath.Substring(0, index).ToLower();
        }

        /// <summary>从 Transform 向上拼出层级路径（不含根节点，形如 "a/b/c"）。</summary>
        // RVA: 0x2E935EC
        public static string CalculateTransformPath(Transform transform)
        {
            if (transform == null)
            {
                return string.Empty;
            }

            StringBuilder sb = new StringBuilder(transform.name);
            while (true)
            {
                if (transform.parent == null)
                {
                    break;
                }
                if (transform.parent == transform.root)
                {
                    break;
                }
                sb.Insert(0, "/");
                sb.Insert(0, transform.parent.name);
                transform = transform.parent;
            }
            return sb.ToString();
        }

        // RVA: 0x2E937D8
        public PathUtility()
        {
        }
    }
}
