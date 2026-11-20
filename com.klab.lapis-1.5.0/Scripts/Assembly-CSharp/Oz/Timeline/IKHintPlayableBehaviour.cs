// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.IKHintPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: ikController.ApplyIKHint(ikHint, ikTarget.position, weight)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class IKHintPlayableBehaviour : PlayableBehaviour
    {
        public IKBodyController ikController;
        public AvatarIKHint ikHint;
        public Transform ikTarget;
        public AnimationCurve ikPositionWeightCurve;

        // RVA: 0x13D9920
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (ikController != null)
            {
                float weight = 0f;
                if (ikPositionWeightCurve != null)
                {
                    weight = ikPositionWeightCurve.Evaluate(
                        (float)playable.GetTime() / (float)playable.GetDuration());
                }

                if (ikTarget != null)
                {
                    ikController.ApplyIKHint(ikHint, ikTarget.position, weight);
                }
            }
        }

        // RVA: 0x13D9A48
        public IKHintPlayableBehaviour()
        {
        }
    }
}
