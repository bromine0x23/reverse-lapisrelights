// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.State<T>
//  来源：Il2CppDumper 元数据 + 共享泛型实例反汇编
//        get_ID / set_ID / .ctor / Enter / Exit / Update 的实例 RVA 见下（State<object> 一组）
// =============================================================================

namespace Oz.GameFramework.Runtime
{
    /// <summary>状态机中的状态基类，<typeparamref name="T"/> 为状态/命令枚举类型。</summary>
    public class State<T>
    {
        public T ID { get; private set; }

        // 共享泛型 RVA 0x1E44554（State<object>..ctor）：写入 ID 后基类构造
        public State(T id)
        {
            ID = id;
        }

        // 共享泛型 RVA 0x1E445A8（State<object>.Enter）：空实现，由子类重写
        public virtual void Enter(T previousState)
        {
        }

        // 共享泛型 RVA 0x1E445AC（State<object>.Exit）：空实现，由子类重写
        public virtual void Exit(T nextState)
        {
        }

        // 共享泛型 RVA 0x1E445B0（State<object>.Update）：空实现，由子类重写
        public virtual void Update()
        {
        }
    }
}
