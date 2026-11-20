// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.RequestNode / RequestCallbackNode
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.Events;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>请求组中的一个请求节点（句柄由静态计数器分配）。</summary>
    public class RequestNode
    {
        private static int handleCount;

        public int Handle { get; private set; }
        public RequestGroup Group { get; private set; }
        public RequestInfo ResInfo { get; private set; }

        // RVA: 0x2E69B04
        public RequestNode(RequestGroup group, RequestInfo resInfo)
        {
            Handle = ++handleCount;
            Group = group;
            ResInfo = resInfo;
        }

        /// <summary>完成时回调本节点，再通知所属请求组。</summary>
        // RVA: 0x2E6A310
        public void OnComplete(AssetRef loaded)
        {
            AssignLoaded(Group.Handle, Handle, loaded);
            Group.OnRequestNodeComplete(Handle);
        }

        /// <summary>基类节点不处理结果（供派生类重写）。</summary>
        // RVA: 0x2E6A35C
        public virtual void AssignLoaded(int groupHandle, int nodeHandle, AssetRef loaded)
        {
        }
    }
}
