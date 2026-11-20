// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.SpringBonePlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: springMgr.ApplyWind(windRot, windPower) + StartDisorder(disFrequent)
//        OnBehaviourPlay: springMgr.Paused = true，再调基类
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class SpringBonePlayableBehaviour : PlayableBehaviour
    {
        public float windPower;
        public Vector3 windRot;
        public float disFrequent;
        public SpringManager springMgr;

        // RVA: 0x13DC8B0
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (springMgr != null)
            {
                springMgr.ApplyWind(windRot, windPower);
                springMgr.StartDisorder(disFrequent);
            }
        }

        // RVA: 0x13DC960
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            if (springMgr != null)
            {
                springMgr.Paused = true;
            }
            base.OnBehaviourPlay(playable, info);
        }

        // RVA: 0x13DCA3C
        public SpringBonePlayableBehaviour()
        {
        }
    }
}
