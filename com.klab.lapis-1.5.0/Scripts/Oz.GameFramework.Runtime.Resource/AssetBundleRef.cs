// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.AssetBundleRef
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>AssetBundle 句柄与引用/依赖计数。</summary>
    public class AssetBundleRef
    {
        private AssetBundleStream m_DesStream;
        private bool m_AllDependenciesLoaded;

        public AssetBundle Bundle { get; private set; }
        public int RefCount { get; private set; }
        public int DepCount { get; private set; }

        /// <summary>引用或依赖任一大于 0 即视为仍存活。</summary>
        // RVA: 0x2E67540
        public bool Alive
        {
            get { return RefCount > 0 || DepCount > 0; }
        }

        public bool AllDependenciesLoaded
        {
            // RVA: 0x2E68008
            get { return m_AllDependenciesLoaded; }
        }

        // RVA: 0x2E67EBC
        public AssetBundleRef(AssetBundle assetBundle)
        {
            Bundle = assetBundle;
            RefCount = 0;
            DepCount = 0;
            m_AllDependenciesLoaded = false;
        }

        // RVA: 0x2E67E7C
        public AssetBundleRef(AssetBundle assetBundle, AssetBundleStream desStream)
        {
            Bundle = assetBundle;
            RefCount = 0;
            DepCount = 0;
            m_DesStream = desStream;
            m_AllDependenciesLoaded = false;
        }

        /// <summary>增加引用并标记依赖已全部加载。</summary>
        // RVA: 0x2E677EC
        public int IncRef()
        {
            m_AllDependenciesLoaded = true;
            return ++RefCount;
        }

        // RVA: 0x2E6752C
        public int DecRef()
        {
            return --RefCount;
        }

        // RVA: 0x2E67EEC
        public int IncDep()
        {
            return ++DepCount;
        }

        // RVA: 0x2E67F00
        public int DecDep()
        {
            return --DepCount;
        }

        /// <summary>卸载 AssetBundle 并释放底层流。</summary>
        // RVA: 0x2E67294
        public void Unload(bool unloadAllLoadedObjects)
        {
            if (Bundle != null)
            {
                Bundle.Unload(unloadAllLoadedObjects);
                Bundle = null;
            }
            if (m_DesStream != null)
            {
                m_DesStream.Dispose();
                m_DesStream = null;
            }
        }
    }
}
