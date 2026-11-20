// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.AssetRef
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>资源引用：额外携带请求信息，<see cref="Asset"/> 为加载结果。</summary>
    public class AssetRef : ObjectRef
    {
        public RequestInfo Info { get; private set; }

        /// <summary>加载到的资源对象。</summary>
        public Object Asset
        {
            // RVA: 0x2E6825C
            get { return m_Object; }
        }

        // RVA: 0x2E68264
        internal AssetRef(RequestInfo info, Object asset) : base(asset)
        {
            Info = info;
        }
    }
}
