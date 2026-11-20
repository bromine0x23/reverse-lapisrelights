// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.IKGoalPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: 两条权重曲线按 GetTime/GetDuration 求值，
//        再 ikController.ApplyIKGoal(ikGoal, ikTarget.position, pw, ikTarget.rotation, rw)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class IKGoalPlayableBehaviour : PlayableBehaviour
    {
        public IKBodyController ikController;
        public AvatarIKGoal ikGoal;
        public Transform ikTarget;
        public AnimationCurve ikPositionWeightCurve;
        public AnimationCurve ikRotationWeightCurve;

        // RVA: 0x13D966C
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (ikController != null)
            {
                float time = (float)playable.GetTime() / (float)playable.GetDuration();

                if (ikPositionWeightCurve != null && ikRotationWeightCurve != null && ikTarget != null)
                {
                    ikController.ApplyIKGoal(
                        ikGoal,
                        ikTarget.position,
                        ikPositionWeightCurve.Evaluate(time),
                        ikTarget.rotation,
                        ikRotationWeightCurve.Evaluate(time));
                }
            }
        }

        // RVA: 0x13D97F4
        public IKGoalPlayableBehaviour()
        {
        }
    }
}
