// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.SpringBoneHairSwitchBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: springMgr.HairEnabled = swtichOn
//        OnBehaviourPlay: springMgr.Paused = true，再调基类
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class SpringBoneHairSwitchBehaviour : PlayableBehaviour
    {
        public bool swtichOn;
        public SpringManager springMgr;

        // RVA: 0x13DC634
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (springMgr != null)
            {
                springMgr.HairEnabled = swtichOn;
            }
        }

        // RVA: 0x13DC6CC
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            if (springMgr != null)
            {
                springMgr.Paused = true;
            }
            base.OnBehaviourPlay(playable, info);
        }

        // RVA: 0x13DC7A8
        public SpringBoneHairSwitchBehaviour()
        {
        }
    }
}
