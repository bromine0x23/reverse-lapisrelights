// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.ExpressionEffectTask
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Check: Time.time >= m_TriggerTime
//        Execute: ExpressionSystem.PlayEffect(m_Event.m_EffectName)
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class ExpressionEffectTask : IBehaviourTask
    {
        private ExpressionSystem m_ExpressionSystem;
        private ExpressionEffectEvent m_Event;
        private float m_TriggerTime;

        // RVA: 0x13EED9C
        public ExpressionEffectTask(
            ExpressionSystem expressionSystem,
            ExpressionEffectEvent effectEvent,
            float triggerTime)
        {
            m_ExpressionSystem = expressionSystem;
            m_Event = effectEvent;
            m_TriggerTime = triggerTime;
        }

        // RVA: 0x13EEDE4
        public bool Check()
        {
            return Time.time >= m_TriggerTime;
        }

        // RVA: 0x13EEE14
        public void Execute()
        {
            m_ExpressionSystem.PlayEffect(m_Event.m_EffectName);
        }
    }
}
