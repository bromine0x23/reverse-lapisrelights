// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.ObjectRef / AssetRef
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>带引用计数的资源对象包装。</summary>
    public class ObjectRef
    {
        protected Object m_Object;
        private bool m_DontDisposeOnUnloadAll;

        public int RefCount { get; private set; }

        public bool DontDisposeOnUnloadAll
        {
            get { return m_DontDisposeOnUnloadAll; }
            set { m_DontDisposeOnUnloadAll = value; }
        }

        /// <summary>引用数大于 0 且底层对象未销毁。</summary>
        // RVA: 0x2E697E4
        public bool IsVaild
        {
            get { return RefCount >= 1 && m_Object != null; }
        }

        // RVA: 0x2E682A8
        internal ObjectRef(Object obj)
        {
            m_Object = obj;
            RefCount = 0;
            m_DontDisposeOnUnloadAll = false;
        }

        // RVA: 0x2E68770
        internal int IncRef()
        {
            return ++RefCount;
        }

        // RVA: 0x2E6899C
        internal int DecRef()
        {
            return --RefCount;
        }

        // RVA: 0x2E689B0
        internal void ClearRef()
        {
            RefCount = 0;
        }

        // RVA: 0x2E689B8
        internal void Dispose()
        {
            RefCount = 0;
            m_Object = null;
        }
    }
}
