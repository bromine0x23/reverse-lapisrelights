// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.Transition<TState>
//  来源：Il2CppDumper 元数据（泛型类型，方法无独立 RVA）
// =============================================================================

using System;

namespace Oz.GameFramework.Runtime
{
    /// <summary>状态迁移基类（共享泛型 RVA：Initialize 0x1E44718 / CheckCondition 0x1E44798 / Complete 0x1E447FC）。</summary>
    public abstract class Transition<TState>
    {
        private Func<bool> m_ConditionFunc;
        private Action<Transition<TState>> m_OnComplete;

        public TState From { get; private set; }

        public TState To { get; private set; }

        /// <summary>迁移开始（由具体迁移实现，如播放动画/加载场景）。</summary>
        public abstract void Begin();

        internal void Initialize(TState from, TState to, Action<Transition<TState>> onComplete, Func<bool> condition)
        {
            From = from;
            To = to;
            m_OnComplete = onComplete;
            m_ConditionFunc = condition;
        }

        /// <summary>无条件时视为满足。</summary>
        public bool CheckCondition()
        {
            return m_ConditionFunc == null || m_ConditionFunc();
        }

        protected void Complete()
        {
            if (m_OnComplete != null)
            {
                m_OnComplete(this);
            }
        }

        protected Transition()
        {
        }
    }
}
