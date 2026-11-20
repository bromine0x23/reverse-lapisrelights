// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.AssetBundleLoader
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>AssetBundle 加载/卸载（含依赖处理与引用计数）。</summary>
    public class AssetBundleLoader
    {
        private Dictionary<string, AssetBundleRef> m_LoadedAssetBundles;
        private IAssetBundleManifest m_Manifest;

        // RVA: 0x2E66F5C
        public AssetBundleLoader()
        {
            m_LoadedAssetBundles = new Dictionary<string, AssetBundleRef>();
        }

        /// <summary>保存清单并预加载所有 local 包。</summary>
        // RVA: 0x2E66FD0
        public void Initialize(IAssetBundleManifest manifest)
        {
            m_Manifest = manifest;

            string[] localBundles = manifest.GetAssetBundlesWithFlag(ePackageFlag.local);
            for (int i = 0; i < localBundles.Length; i++)
            {
                LoadAssetBundle(localBundles[i]);
            }
        }

        // RVA: 0x2E67170
        public void Destroy()
        {
            foreach (AssetBundleRef bundleRef in m_LoadedAssetBundles.Values)
            {
                bundleRef.Unload(true);
            }
            m_LoadedAssetBundles.Clear();
        }

        // RVA: 0x2E67348
        public AssetBundleRef GetLoadedAssetBundle(string assetBundleName)
        {
            AssetBundleRef bundleRef;
            m_LoadedAssetBundles.TryGetValue(assetBundleName, out bundleRef);
            return bundleRef;
        }

        /// <summary>同步加载资源（包未加载或已卸载返回 null）。</summary>
        // RVA: 0x2E673C8
        public Object LoadAssetSync(string assetBundleName, string assetName, Type type)
        {
            AssetBundleRef bundleRef = GetLoadedAssetBundle(assetBundleName);
            if (bundleRef == null || bundleRef.Bundle == null)
            {
                return null;
            }
            return bundleRef.Bundle.LoadAsset(assetName, type);
        }

        /// <summary>减少引用；归零且无依赖时真正卸载（必要时连带卸载依赖）。</summary>
        // RVA: 0x2E674A0
        public void UnloadAssetBundle(string assetBundleName, bool unloadAllLoadedObjectsbool = false)
        {
            AssetBundleRef bundleRef = GetLoadedAssetBundle(assetBundleName);
            if (bundleRef == null)
            {
                return;
            }
            if (bundleRef.DecRef() == 0 && bundleRef.DepCount <= 0)
            {
                UnloadAssetBundleInternal(assetBundleName, unloadAllLoadedObjectsbool);
                if (bundleRef.AllDependenciesLoaded)
                {
                    UnloadAllDependencies(assetBundleName, unloadAllLoadedObjectsbool);
                }
            }
        }

        /// <summary>加载 AssetBundle：已加载则按需补依赖，否则先建依赖链再加载本体。</summary>
        // RVA: 0x2E670E8
        public AssetBundleRef LoadAssetBundle(string assetBundleName)
        {
            AssetBundleRef bundleRef = GetLoadedAssetBundle(assetBundleName);
            if (bundleRef != null)
            {
                if (!bundleRef.AllDependenciesLoaded)
                {
                    LoadAllDependencies(assetBundleName);
                }
            }
            else
            {
                LoadAllDependencies(assetBundleName);
                bundleRef = LoadAssetBundleInternal(assetBundleName);
                if (bundleRef == null)
                {
                    return null;
                }
            }

            bundleRef.IncRef();
            return bundleRef;
        }

        /// <summary>异步加载资源（包未加载或已卸载返回 null）。</summary>
        // RVA: 0x2E67D0C
        public AssetBundleRequest LoadAssetAsync(string assetBundleName, string assetName, Type type)
        {
            AssetBundleRef bundleRef = GetLoadedAssetBundle(assetBundleName);
            if (bundleRef == null || bundleRef.Bundle == null)
            {
                return null;
            }
            return bundleRef.Bundle.LoadAssetAsync(assetName, type);
        }

        /// <summary>
        /// 真正加载包文件：有加密 key 时走 <see cref="AssetBundleStream"/> + LoadFromStream，
        /// 否则 LoadFromFile；成功则登记到已加载表。
        /// </summary>
        // RVA: 0x2E679A8
        private AssetBundleRef LoadAssetBundleInternal(string assetBundleName)
        {
            if (GetLoadedAssetBundle(assetBundleName) != null)
            {
                return GetLoadedAssetBundle(assetBundleName);
            }

            string filePath = m_Manifest.GetAssetBundleFilePath(assetBundleName);
            if (string.IsNullOrEmpty(filePath))
            {
                return null;
            }

            AssetBundleRef bundleRef = null;
            int encKey = m_Manifest.GetAssetBundleEncKey(assetBundleName);
            if (encKey != 0)
            {
                AssetBundleStream stream = new AssetBundleStream(filePath, System.IO.FileMode.Open, encKey);
                AssetBundle bundle = AssetBundle.LoadFromStream(stream);
                if (bundle != null)
                {
                    bundleRef = new AssetBundleRef(bundle, stream);
                }
                else
                {
                    Debug.LogError("Load AssetBundle: " + filePath + " failed.");
                    stream.Dispose();
                }
            }
            else
            {
                AssetBundle bundle = AssetBundle.LoadFromFile(filePath);
                if (bundle != null)
                {
                    bundleRef = new AssetBundleRef(bundle);
                }
            }

            if (bundleRef != null)
            {
                m_LoadedAssetBundles.Add(assetBundleName, bundleRef);
                return bundleRef;
            }

            Debug.LogError("Load AssetBundle: " + filePath + " failed.");
            return null;
        }

        // RVA: 0x2E67808
        private void LoadAllDependencies(string assetBundleName)
        {
            int[] dependencies = m_Manifest.GetDependencies(assetBundleName);
            for (int i = 0; i < dependencies.Length; i++)
            {
                string dependencyName = m_Manifest.GetAssetBundleName(dependencies[i]);
                AssetBundleRef dependency = LoadAssetBundleInternal(dependencyName);
                if (dependency != null)
                {
                    dependency.IncDep();
                }
            }
        }

        /// <summary>递减依赖计数，降为 0 且无人引用时卸载该依赖包。</summary>
        // RVA: 0x2E675F8
        private void UnloadAllDependencies(string assetBundleName, bool unloadAllLoadedObjectsbool = false)
        {
            int[] dependencies = m_Manifest.GetDependencies(assetBundleName);
            for (int i = 0; i < dependencies.Length; i++)
            {
                string dependencyName = m_Manifest.GetAssetBundleName(dependencies[i]);
                AssetBundleRef dependency = GetLoadedAssetBundle(dependencyName);
                if (dependency != null)
                {
                    int depCount = dependency.DecDep();
                    if (depCount <= 0 && dependency.RefCount <= 0)
                    {
                        UnloadAssetBundleInternal(dependencyName, unloadAllLoadedObjectsbool);
                    }
                }
            }
        }

        // RVA: 0x2E67564
        private void UnloadAssetBundleInternal(string assetBundleName, bool unloadAllLoadedObjectsbool = false)
        {
            AssetBundleRef bundleRef = GetLoadedAssetBundle(assetBundleName);
            if (bundleRef != null)
            {
                bundleRef.Unload(unloadAllLoadedObjectsbool);
                m_LoadedAssetBundles.Remove(assetBundleName);
            }
        }

        // RVA: 0x2E67F14
        public bool ExistAssetBundleName(string assetBundleName)
        {
            return m_Manifest.Exist(assetBundleName);
        }
    }
}
