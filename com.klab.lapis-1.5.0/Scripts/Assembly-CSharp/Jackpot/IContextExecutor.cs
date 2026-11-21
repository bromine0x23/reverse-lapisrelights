// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.IContextExecutor
//  来源：Il2CppDumper 元数据（签名精确）
// =============================================================================

namespace Jackpot
{
    public interface IContextExecutor<T>
    {
        bool CanExecute(T context);
        void Execute(T context);
    }
}
