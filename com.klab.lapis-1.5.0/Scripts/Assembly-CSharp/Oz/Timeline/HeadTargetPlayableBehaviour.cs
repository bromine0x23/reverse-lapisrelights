// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.HeadTargetPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: weightCurve.Evaluate(GetTime/GetDuration) →
//        headDirection.ApplyTimelineLookAtTarget(lookAtTarget.position, weight)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class HeadTargetPlayableBehaviour : PlayableBehaviour
    {
        public Transform lookAtTarget;
        public AnimationCurve weightCurve;
        public IKHeadController headDirection;

        // RVA: 0x13D8D70
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            float weight = 0f;
            if (weightCurve != null)
            {
                weight = weightCurve.Evaluate((float)playable.GetTime() / (float)playable.GetDuration());
            }

            if (headDirection != null && lookAtTarget != null)
            {
                headDirection.ApplyTimelineLookAtTarget(lookAtTarget.position, weight);
            }
        }

        // RVA: 0x13D8ECC
        public HeadTargetPlayableBehaviour()
        {
        }
    }
}
