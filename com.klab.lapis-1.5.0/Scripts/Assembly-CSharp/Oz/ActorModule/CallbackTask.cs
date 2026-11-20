// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.CallbackTask
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Check: Time.time >= m_TriggerTime；Execute: m_Callback.Invoke()
// =============================================================================

using System;
using UnityEngine;

namespace Oz.ActorModule
{
    public class CallbackTask : IBehaviourTask
    {
        private float m_TriggerTime;
        private Action m_Callback;

        // RVA: 0x16AF20C
        public CallbackTask(Action callback, float triggerTime)
        {
            m_Callback = callback;
            m_TriggerTime = triggerTime;
        }

        // RVA: 0x16B0A6C
        public bool Check()
        {
            return Time.time >= m_TriggerTime;
        }

        // RVA: 0x16B0A9C
        public void Execute()
        {
            if (m_Callback != null)
            {
                m_Callback.Invoke();
            }
        }
    }
}
