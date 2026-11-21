// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameFramework.Runtime.IReferenceable
//  来源：Il2CppDumper 元数据（签名精确）
// =============================================================================

namespace Oz.GameFramework.Runtime
{
    public interface IReferenceable<T>
    {
        T Index { get; }
        int RefCount { get; }
        void IncRef();
        void DecRef();
        void Dispose();
    }
}
