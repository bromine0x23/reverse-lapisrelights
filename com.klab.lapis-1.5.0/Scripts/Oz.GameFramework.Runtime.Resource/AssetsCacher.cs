// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.AssetsCacher
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>已加载资源缓存（活跃表 + 可选 LRU 二级缓存）。</summary>
    public class AssetsCacher
    {
        public static int LRU_CAP;
        public static LRUCache<AssetRef> LRUCache;

        private Dictionary<RequestInfo, AssetRef> m_AliveAssets;
        private LRUCache<AssetRef> m_LRUCache;

        // RVA: 0x2E682DC
        public AssetsCacher()
        {
            m_AliveAssets = new Dictionary<RequestInfo, AssetRef>();
            m_LRUCache = new LRUCache<AssetRef>(LRU_CAP);
            LRUCache = m_LRUCache;
        }

        /// <summary>关闭 LRU 时清空二级缓存。</summary>
        // RVA: 0x2E683BC
        public void EnableLRUCache(bool isEnable)
        {
            if (!isEnable)
            {
                m_LRUCache.Clear();
            }
        }

        // RVA: 0x2E68434
        public bool IsCached(RequestInfo info)
        {
            if (info == null)
            {
                return false;
            }
            if (ResourceManager.USE_LRU && m_LRUCache.ContainsKey(info))
            {
                return true;
            }
            return m_AliveAssets.ContainsKey(info);
        }

        /// <summary>已存在则忽略；否则以 RefCount=0 加入活跃表。</summary>
        // RVA: 0x2E68548
        public void PutIntoCache(RequestInfo info, Object asset, bool loadByAsync)
        {
            if (m_AliveAssets.ContainsKey(info))
            {
                return;
            }
            m_AliveAssets.Add(info, new AssetRef(info, asset));
        }

        /// <summary>优先取 LRU（取出即移出并加引用），否则取活跃表并加引用。</summary>
        // RVA: 0x2E68614
        public AssetRef GetFromCache(RequestInfo info)
        {
            if (ResourceManager.USE_LRU)
            {
                AssetRef cached = m_LRUCache.Get(info);
                if (cached != null)
                {
                    cached.IncRef();
                    m_LRUCache.RemoveNode(cached);
                    return cached;
                }
            }

            AssetRef assetRef;
            if (!m_AliveAssets.TryGetValue(info, out assetRef) || assetRef == null)
            {
                return null;
            }
            assetRef.IncRef();
            return assetRef;
        }

        /// <summary>
        /// 归还引用：引用归零（或强制）时，LRU 开启则转入二级缓存并在淘汰时卸载对应
        /// AssetBundle；LRU 关闭则直接从活跃表移除并释放。
        /// </summary>
        // RVA: 0x2E68784
        public bool RemoveFromCache(AssetRef assetRef, bool forceRemove = false)
        {
            if (assetRef == null || (assetRef.RefCount < 1 && !forceRemove))
            {
                return false;
            }
            assetRef.DecRef();

            if (ResourceManager.USE_LRU)
            {
                assetRef.ClearRef();
                if (m_LRUCache.ContainsKey(assetRef.Info))
                {
                    return false;
                }

                AssetRef evicted = m_LRUCache.Set(assetRef);
                if (evicted != null)
                {
                    m_AliveAssets.Remove(evicted.Info);

                    string bundleName;
                    string assetName;
                    if (AppConst.AssetBundleMode
                        && PathUtility.ResourcePathToBundlePath(evicted.Info.path, out bundleName, out assetName))
                    {
                        ResourceManager.m_AssetBundleLoader.UnloadAssetBundle(bundleName, true);
                    }
                }
                return false;
            }

            m_AliveAssets.Remove(assetRef.Info);
            assetRef.Dispose();
            return true;
        }

        // RVA: 0x2E689C4
        public Dictionary<RequestInfo, AssetRef> GetAllCachedAssets()
        {
            return m_AliveAssets;
        }

        /// <summary>释放全部缓存项（逐个 Dispose）并清空。</summary>
        // RVA: 0x2E689CC
        public void Clear()
        {
            foreach (AssetRef assetRef in m_AliveAssets.Values)
            {
                assetRef.Dispose();
            }
            m_AliveAssets.Clear();
        }

        // RVA: 0x2E68AEC
        static AssetsCacher()
        {
            LRU_CAP = 10;
        }
    }
}
