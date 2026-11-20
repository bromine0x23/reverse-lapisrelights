// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.RequestInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>资源请求键：路径 + 类型。</summary>
    public class RequestInfo
    {
        public string path { get; private set; }
        public Type type { get; private set; }

        // RVA: 0x2E6A180
        public RequestInfo(string path, Type type)
        {
            this.path = path;
            this.type = type;
        }

        // RVA: 0x2E6A1B8
        public override int GetHashCode()
        {
            return (path + type).GetHashCode();
        }

        // RVA: 0x2E6A20C
        public override bool Equals(object obj)
        {
            RequestInfo other = obj as RequestInfo;
            if (other == null)
            {
                return false;
            }
            return other.path == path && other.type == type;
        }
    }
}
