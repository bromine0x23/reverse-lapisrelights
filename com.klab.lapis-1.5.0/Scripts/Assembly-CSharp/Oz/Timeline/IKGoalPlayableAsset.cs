// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.IKGoalPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<IKGoalPlayableBehaviour>.Create(graph, 0)
//        → 逐字段拷贝 ikController/ikGoal/ikTarget(Resolve)/两条权重曲线
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class IKGoalPlayableAsset : IKBaseAsset
    {
        public AvatarIKGoal ikGoal;
        public ExposedReference<Transform> ikTarget;
        public AnimationCurve ikPositionWeightCurve;
        public AnimationCurve ikRotationWeightCurve;

        // RVA: 0x13D9540
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<IKGoalPlayableBehaviour> playable =
                ScriptPlayable<IKGoalPlayableBehaviour>.Create(graph, 0);
            IKGoalPlayableBehaviour behaviour = playable.GetBehaviour();

            behaviour.ikController = ikController;
            behaviour.ikGoal = ikGoal;
            behaviour.ikTarget = ikTarget.Resolve(graph.GetResolver());
            behaviour.ikPositionWeightCurve = ikPositionWeightCurve;
            behaviour.ikRotationWeightCurve = ikRotationWeightCurve;

            return playable;
        }

        // RVA: 0x13D9664
        public IKGoalPlayableAsset()
        {
        }
    }
}
