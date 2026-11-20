// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.Request
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>一个资源请求（按 <see cref="RequestInfo"/> 合并多个请求节点）。</summary>
    public class Request
    {
        private static int handleCount;

        public int Handle { get; private set; }
        public RequestInfo ResInfo { get; private set; }
        public Coroutine coroutine;
        public List<RequestNode> Nodes;

        // RVA: 0x2E69890
        public bool IsEmpty
        {
            get { return Nodes.Count < 1; }
        }

        // RVA: 0x2E698E8
        public Request(RequestInfo info)
        {
            Handle = ++handleCount;
            ResInfo = info;
            Nodes = new List<RequestNode>();
        }

        // RVA: 0x2E6998C
        public void AddNode(RequestNode node)
        {
            Nodes.Add(node);
        }

        /// <summary>移除属于指定请求组的节点（倒序遍历）。</summary>
        // RVA: 0x2E699F4
        public void RemoveNodes(int groupHandle)
        {
            for (int i = Nodes.Count - 1; i >= 0; i--)
            {
                RequestNode node = Nodes[i];
                if (node == null)
                {
                    break;
                }
                if (node.Group == null)
                {
                    break;
                }
                if (node.Group.Handle == groupHandle)
                {
                    Nodes.RemoveAt(i);
                }
            }
        }
    }
}
