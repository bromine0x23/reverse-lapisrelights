// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.RequestCallbackNode
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.Events;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>以委托回调形式接收结果的请求节点。</summary>
    public class RequestCallbackNode : RequestNode
    {
        public UnityAction<int, int, AssetRef> Callback { get; private set; }

        // RVA: 0x2E69ADC
        public RequestCallbackNode(RequestGroup group, RequestInfo resInfo, UnityAction<int, int, AssetRef> callback)
            : base(group, resInfo)
        {
            Callback = callback;
        }

        // RVA: 0x2E69B84
        public override void AssignLoaded(int groupHandle, int nodeHandle, AssetRef loaded)
        {
            if (Callback != null)
            {
                Callback(groupHandle, nodeHandle, loaded);
            }
        }
    }
}
