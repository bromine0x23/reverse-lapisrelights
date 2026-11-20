// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.MotionTask
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + IDA 反汇编核对
//        ctor 未写入 m_TriggerTime（0x13F4F68/0x13F4F6C/0x13F4F70 仅写 0x10/0x18/0x24/0x28），
//        与二进制一致地保留该行为。
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class MotionTask : IBehaviourTask
    {
        private MotionSystem m_MotionSystem;
        private AnimationClip m_AnimationClip;
        private float m_TriggerTime;
        private float m_CrossFadeTime;
        private bool m_fixedTime;

        // RVA: 0x13F4F34
        public MotionTask(
            MotionSystem motionSystem,
            AnimationClip animationClip,
            float crossFadeTime,
            float triggerTime,
            bool isFixedTime = false)
        {
            m_MotionSystem = motionSystem;
            m_AnimationClip = animationClip;
            m_CrossFadeTime = crossFadeTime;
            m_fixedTime = isFixedTime;
        }

        // RVA: 0x13F4F88
        public void SetPlayImmediately()
        {
            m_CrossFadeTime = 0f;
            m_MotionSystem.Play(m_AnimationClip);
        }

        // RVA: 0x13F4FAC
        public bool Check()
        {
            return Time.time >= m_TriggerTime;
        }

        // RVA: 0x13F4FDC
        public void Execute()
        {
            if (m_fixedTime)
            {
                m_MotionSystem.CrossFadeFixedTime(m_AnimationClip, m_CrossFadeTime);
            }
            else
            {
                m_MotionSystem.CrossFade(m_AnimationClip, m_CrossFadeTime);
            }
        }
    }
}
