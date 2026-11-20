// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.IKBodyOffsetPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: ikController.ApplyBodyPositionOffset(ikBodyPositionOffset, weight)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class IKBodyOffsetPlayableBehaviour : PlayableBehaviour
    {
        public IKBodyController ikController;
        public Vector3 ikBodyPositionOffset;
        public AnimationCurve ikBodyPositionOffsetWeightCurve;

        // RVA: 0x13D940C
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (ikController != null && ikBodyPositionOffsetWeightCurve != null)
            {
                float weight = ikBodyPositionOffsetWeightCurve.Evaluate(
                    (float)playable.GetTime() / (float)playable.GetDuration());
                ikController.ApplyBodyPositionOffset(ikBodyPositionOffset, weight);
            }
        }

        // RVA: 0x13D9538
        public IKBodyOffsetPlayableBehaviour()
        {
        }
    }
}
