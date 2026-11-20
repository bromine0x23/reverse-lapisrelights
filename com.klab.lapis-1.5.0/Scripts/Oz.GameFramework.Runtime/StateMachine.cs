// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.StateMachine<TState, TCommand>
//  来源：Il2CppDumper 元数据 + 共享泛型实例反汇编
//        ctor 0x1E435A4 / AddTransition 0x1E43774 / Begin 0x1E43980 / End 0x1E43A74
//        Trigger 0x1E43AD8 / OnTransitionComplete 0x1E43C04 / Update 0x1E43CAC
//        AddTransition<T>（三参）= 0x1368C6C
// =============================================================================

using System;
using System.Collections.Generic;

namespace Oz.GameFramework.Runtime
{
    /// <summary>
    /// 状态机：持有状态表与「(from, command) → to」迁移表。
    /// </summary>
    public class StateMachine<TState, TCommand>
    {
        private Dictionary<TState, State<TState>> m_States;
        private Dictionary<TState, Dictionary<TCommand, Transition<TState>>> m_Transitions;
        private TState m_CurrentState;
        private Transition<TState> m_CurrentTransition;

        public bool IsTransition
        {
            get { return m_CurrentTransition != null; }
        }

        public StateMachine(State<TState>[] states)
        {
            m_States = new Dictionary<TState, State<TState>>();
            m_Transitions = new Dictionary<TState, Dictionary<TCommand, Transition<TState>>>();
            for (int i = 0; i < states.Length; i++)
            {
                m_States[states[i].ID] = states[i];
            }
        }

        /// <summary>注册一条无条件的直接迁移。</summary>
        public void AddTransition<T>(TState from, TState to, TCommand cmd) where T : Transition<TState>, new()
        {
            AddTransitionImpl(new T(), from, to, cmd, null);
        }

        /// <summary>注册一条带条件的迁移（使用内置 DefaultTransition）。</summary>
        public void AddTransition(TState from, TState to, TCommand cmd, Func<bool> condition)
        {
            AddTransitionImpl(new DefaultTransition<TState>(), from, to, cmd, condition);
        }

        private void AddTransitionImpl(Transition<TState> transition, TState from, TState to, TCommand cmd,
            Func<bool> condition)
        {
            transition.Initialize(from, to, OnTransitionComplete, condition);
            Dictionary<TCommand, Transition<TState>> commands;
            if (!m_Transitions.TryGetValue(from, out commands))
            {
                commands = new Dictionary<TCommand, Transition<TState>>();
                m_Transitions[from] = commands;
            }
            commands[cmd] = transition;
        }

        public void Begin(TState state)
        {
            m_CurrentState = state;
            State<TState> s;
            if (m_States.TryGetValue(state, out s))
            {
                s.Enter(state);
            }
        }

        public void End()
        {
            State<TState> s;
            if (m_States.TryGetValue(m_CurrentState, out s))
            {
                s.Exit(m_CurrentState);
            }
            m_CurrentState = default(TState);
        }

        /// <summary>按命令触发迁移；条件不满足时保持当前状态。</summary>
        public void Trigger(TCommand cmd)
        {
            if (m_CurrentTransition != null)
            {
                return;
            }
            Dictionary<TCommand, Transition<TState>> commands;
            if (!m_Transitions.TryGetValue(m_CurrentState, out commands))
            {
                return;
            }
            Transition<TState> transition;
            if (!commands.TryGetValue(cmd, out transition) || !transition.CheckCondition())
            {
                return;
            }
            m_CurrentTransition = transition;
            transition.Begin();
        }

        private void OnTransitionComplete(Transition<TState> transition)
        {
            State<TState> from;
            if (m_States.TryGetValue(m_CurrentState, out from))
            {
                from.Exit(transition.To);
            }
            m_CurrentState = transition.To;
            State<TState> to;
            if (m_States.TryGetValue(transition.To, out to))
            {
                to.Enter(transition.From);
            }
            m_CurrentTransition = null;
        }

        public void Update()
        {
            if (m_CurrentTransition != null)
            {
                return;
            }
            State<TState> state;
            if (m_States.TryGetValue(m_CurrentState, out state))
            {
                state.Update();
            }
        }

    }
}
