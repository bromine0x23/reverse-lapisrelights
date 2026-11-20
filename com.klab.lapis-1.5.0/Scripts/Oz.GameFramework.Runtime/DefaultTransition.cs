// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.DefaultTransition<TState>
//  来源：Il2CppDumper 元数据 + 共享泛型实例反汇编
//        Begin 0x1E41B04（DefaultTransition<object>）：无条件立即调用 Complete()
//        .ctor 0x1E41B28：空构造（由 StateMachine.AddTransition 调用 Initialize 填充）
// =============================================================================

namespace Oz.GameFramework.Runtime
{
    /// <summary>默认迁移：启动即完成，条件判定由 <see cref="StateMachine{TState,TCommand}"/> 负责。</summary>
    public class DefaultTransition<TState> : Transition<TState>
    {
        public override void Begin()
        {
            Complete();
        }
    }
}
