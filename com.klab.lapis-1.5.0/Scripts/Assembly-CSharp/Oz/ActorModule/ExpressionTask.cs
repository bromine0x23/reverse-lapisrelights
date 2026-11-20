// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.ExpressionTask
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Check: Time.time >= m_TriggerTime
//        Execute: ExpressionSystem.CrossFade(m_Event.m_Expression, m_MouthOpen, m_TransitionDuration)
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class ExpressionTask : IBehaviourTask
    {
        private ExpressionSystem m_ExpressionSystem;
        private ExpressionEvent m_Event;
        private float m_TriggerTime;

        // RVA: 0x13F0138
        public ExpressionTask(ExpressionSystem expressionSystem, ExpressionEvent expressionEvent, float triggerTime)
        {
            m_ExpressionSystem = expressionSystem;
            m_Event = expressionEvent;
            m_TriggerTime = triggerTime;
        }

        // RVA: 0x13F0180
        public bool Check()
        {
            return Time.time >= m_TriggerTime;
        }

        // RVA: 0x13F01B0
        public void Execute()
        {
            m_ExpressionSystem.CrossFade(
                m_Event.m_Expression,
                m_Event.m_MouthOpen,
                m_Event.m_TransitionDuration);
        }
    }
}
