// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.RequestGroup
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using UnityEngine.Events;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>请求组：一次 Begin/End 之间提交的请求集合，带进度与完成回调。</summary>
    public class RequestGroup
    {
        private static int handleCount;

        private int _totalRequest;
        private Dictionary<int, RequestNode> _requestNodes;
        private UnityAction<int> _onComplete;
        private UnityAction<int, float> _onProgress;

        public int Handle { get; private set; }

        public bool IsComplete { get; private set; }

        /// <summary>1 - 未完成节点数 / 总节点数；无请求时为 0。</summary>
        // RVA: 0x2E69C24
        public float Progress
        {
            get
            {
                if (_totalRequest < 1)
                {
                    return 0f;
                }
                return 1f - (float)_requestNodes.Count / (float)_totalRequest;
            }
        }

        // RVA: 0x2E69CAC
        public bool IsEmpty
        {
            get { return _requestNodes.Count < 1; }
        }

        // RVA: 0x2E69D24
        public RequestGroup(UnityAction<int, float> onProgress, UnityAction<int> onComplete)
        {
            _onComplete = onComplete;
            _onProgress = onProgress;
            Handle = ++handleCount;
            IsComplete = false;
            _requestNodes = new Dictionary<int, RequestNode>();
        }

        /// <summary>把所有节点按请求键归并到 <paramref name="requestsToLoad"/> 的请求中。</summary>
        // RVA: 0x2E69DD0
        public void Prepare(Dictionary<RequestInfo, Request> requestsToLoad)
        {
            foreach (RequestNode node in _requestNodes.Values)
            {
                Request request;
                if (!requestsToLoad.TryGetValue(node.ResInfo, out request))
                {
                    request = new Request(node.ResInfo);
                    requestsToLoad[node.ResInfo] = request;
                }
                request.AddNode(node);
            }
            _totalRequest = _requestNodes.Count;
        }

        /// <summary>新增一个回调型请求节点，返回节点句柄。</summary>
        // RVA: 0x2E69FB8
        public int AddRequestNode(RequestInfo resInfo, UnityAction<int, int, AssetRef> callback)
        {
            RequestCallbackNode node = new RequestCallbackNode(this, resInfo, callback);
            _requestNodes.Add(node.Handle, node);
            return node.Handle;
        }

        /// <summary>节点完成：移除并上报进度。</summary>
        // RVA: 0x2E6A058
        public void OnRequestNodeComplete(int requestNodeHandle)
        {
            _requestNodes.Remove(requestNodeHandle);
            if (_onProgress != null)
            {
                _onProgress(Handle, Progress);
            }
        }

        // RVA: 0x2E6A0FC
        public void OnComplete()
        {
            if (_onComplete != null)
            {
                _onComplete(Handle);
            }
        }
    }
}
