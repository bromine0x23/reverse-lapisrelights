// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.DefaultAssetBundlesManifest
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using System.IO;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>AssetBundle 清单实现：包名 → 包信息，以及序号 → 包名。</summary>
    public class DefaultAssetBundlesManifest : IAssetBundleManifest
    {
        protected Dictionary<string, IAssetBundleInfo> m_AssetBundleInfos;
        protected Dictionary<int, string> m_Index2AssetBudnleName;

        /// <summary>由平台清单构建索引（包名 → 包信息，序号 → 包名）。</summary>
        // RVA: 0x2E68B40
        public DefaultAssetBundlesManifest(IPackageManifest manifest)
        {
            m_AssetBundleInfos = new Dictionary<string, IAssetBundleInfo>();
            m_Index2AssetBudnleName = new Dictionary<int, string>();

            IPackageInfo[] packageInfos = manifest.GetAllPackageInfos();
            for (int i = 0; i < packageInfos.Length; i++)
            {
                IAssetBundleInfo info = packageInfos[i] as IAssetBundleInfo;
                if (info == null)
                {
                    continue;
                }
                m_AssetBundleInfos.Add(info.Name, info);
                m_Index2AssetBudnleName.Add(manifest.GetPackageIndex(info.Name), info.Name);
            }
        }

        // RVA: 0x2E68EBC
        public string GetAssetBundleName(int index)
        {
            string name;
            if (!m_Index2AssetBudnleName.TryGetValue(index, out name))
            {
                return string.Empty;
            }
            return name;
        }

        // RVA: 0x2E68F4C
        public bool Exist(string assetBundleName)
        {
            return m_AssetBundleInfos.ContainsKey(assetBundleName);
        }

        // RVA: 0x2E68FB4
        public string[] GetAssetBundlesWithFlag(ePackageFlag flag)
        {
            List<string> names = new List<string>();
            foreach (IAssetBundleInfo info in m_AssetBundleInfos.Values)
            {
                if (info.HasFlag(flag))
                {
                    names.Add(info.Name);
                }
            }
            return names.ToArray();
        }

        /// <summary>拼出 StreamingAssets 下的 AssetBundle 绝对路径。</summary>
        // RVA: 0x2E6915C
        public virtual string GetAssetBundleFilePath(string assetBundleName)
        {
            IAssetBundleInfo info;
            if (!m_AssetBundleInfos.TryGetValue(assetBundleName, out info) || info == null)
            {
                return string.Empty;
            }
            return Path.Combine(PathUtility.GetStreamingAssetsPath(), info.GetFilePath());
        }

        // RVA: 0x2E693F0
        public int GetAssetBundleEncKey(string assetBundleName)
        {
            IAssetBundleInfo info;
            if (!m_AssetBundleInfos.TryGetValue(assetBundleName, out info) || info == null)
            {
                return 0;
            }
            return info.EncryptKey;
        }

        // RVA: 0x2E694E4
        public int[] GetDependencies(string assetBundleName)
        {
            IAssetBundleInfo info;
            if (!m_AssetBundleInfos.TryGetValue(assetBundleName, out info) || info == null)
            {
                return null;
            }
            return info.Dependencies;
        }
    }
}
