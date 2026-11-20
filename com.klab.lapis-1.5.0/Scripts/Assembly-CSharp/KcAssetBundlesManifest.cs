// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  KcAssetBundlesManifest
//  来源：Il2CppDumper 元数据 + 反汇编
//        ctor 0x1325FA8、GetAssetBundleFileName 0x1325FB0、
//        GetAssetBundleLoadPath 0x13260D0、GetAssetBundleFilePath 0x1326168
// =============================================================================

using System.Collections.Generic;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Resource;

internal class KcAssetBundlesManifest : DefaultAssetBundlesManifest
{
    public KcAssetBundlesManifest(IPackageManifest manifest)
        : base(manifest)
    {
    }

    private bool GetAssetBundleFileName(string assetBundleName, out string assetBundlePath)
    {
        IAssetBundleInfo info = null;
        if (m_AssetBundleInfos.TryGetValue(assetBundleName, out info))
        {
            assetBundlePath = info.Name;
            return true;
        }

        assetBundlePath = string.Empty;
        return false;
    }

    private string GetAssetBundleLoadPath(string assetBundleName)
    {
        IAssetBundleInfo info = null;
        if (m_AssetBundleInfos.TryGetValue(assetBundleName, out info))
        {
            return PathUtility.GetPersistentDataPath();
        }

        return string.Empty;
    }

    public override string GetAssetBundleFilePath(string assetBundleName)
    {
        string assetBundlePath;
        if (GetAssetBundleFileName(assetBundleName, out assetBundlePath))
        {
            return GetAssetBundleLoadPath(assetBundleName) + assetBundlePath;
        }

        return string.Empty;
    }
}
