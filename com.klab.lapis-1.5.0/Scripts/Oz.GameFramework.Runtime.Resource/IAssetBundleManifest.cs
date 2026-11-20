// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.IAssetBundleManifest
//  来源：Il2CppDumper 元数据（接口，无方法体）
// =============================================================================

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>AssetBundle 清单查询接口。</summary>
    public interface IAssetBundleManifest
    {
        string GetAssetBundleName(int index);

        bool Exist(string assetBundleName);

        int[] GetDependencies(string assetBundleName);

        string[] GetAssetBundlesWithFlag(ePackageFlag flag);

        string GetAssetBundleFilePath(string assetBundleName);

        int GetAssetBundleEncKey(string assetBundleName);
    }
}
