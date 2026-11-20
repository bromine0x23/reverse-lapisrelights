// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.AssetBundleInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.IO;
using Kc.Config;
using Kc.Utility;
using Oz.GameFramework.Runtime;

namespace Oz.GameKit.Version
{
    /// <summary>AssetBundle 包信息（清单中的一项）。</summary>
    public class AssetBundleInfo : IPackageInfoKc, IPackageInfo, IAssetBundleInfo
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public ulong Size { get; set; }
        public string ShortHash { get; set; }
        public int Flags { get; set; }
        public string Version { get; set; }
        public int[] Dependencies { get; set; }
        public int EncryptKey { get; set; }
        public bool IsActivityAsset { get; set; }
        public string Hash { get; set; }

        // RVA: 0x187D218
        public AssetBundleInfo()
        {
        }

        /// <summary>当前语言路径：{lang}/AssetBundles/{Name}.bdl。</summary>
        // RVA: 0x187D27C
        public string GetFilePath()
        {
            return string.Format("{0}/AssetBundles/{1}", KcAppSetting.CurrentLang, Name + ".bdl");
        }

        // RVA: 0x187D320
        public string GetFilePathByLang(string lang)
        {
            return string.Format("{0}/AssetBundles/{1}", lang, Name + ".bdl");
        }

        // RVA: 0x187D3A0
        public string GetFilePathByLangTSV(string lang)
        {
            return Path.Combine(PathUtil.GetPlatformName(), GetFilePath());
        }

        /// <summary>活动资源文件名：MD5(Name + Version) + ".bdl"。</summary>
        // RVA: 0x187D428
        private string ActivityPathName
        {
            get { return CryptographyUtil.GetMd5(Name + Version, 0) + ".bdl"; }
        }

        /// <summary>下载路径：{version}/{platform}/{FilePath 或 活动资源路径}。</summary>
        // RVA: 0x187D4C0
        public string GetDownloadPath(string version)
        {
            string platformName = PathUtil.GetPlatformName();
            string filePath = IsActivityAsset
                ? string.Format("{0}/AssetBundles/{1}", KcAppSetting.CurrentLang, ActivityPathName)
                : GetFilePath();
            return string.Format("{0}/{1}/{2}", version, platformName, filePath);
        }

        // RVA: 0x187D59C
        public void AddFlag(ePackageFlag flag)
        {
            Flags |= (int)flag;
        }

        /// <summary>flag 为 0 时以 bit0 是否清零作为“未标记”判定。</summary>
        // RVA: 0x187D5AC
        public bool HasFlag(ePackageFlag flag)
        {
            if ((int)flag == 0)
            {
                return (Flags & 1) == 0;
            }
            return (Flags & (int)flag) != 0;
        }

        /// <summary>flag 为 0 时置位 bit0（与 HasFlag 的语义配对）。</summary>
        // RVA: 0x187D5CC
        public void RemoveFlag(ePackageFlag flag)
        {
            if ((int)flag == 0)
            {
                Flags |= 1;
            }
            else
            {
                Flags &= ~(int)flag;
            }
        }
    }
}
