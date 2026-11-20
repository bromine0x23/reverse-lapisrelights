// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.IKHintPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<IKHintPlayableBehaviour>.Create(graph, 0)
//        → ikController/ikHint/ikTarget(Resolve)/ikPositionWeightCurve
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class IKHintPlayableAsset : IKBaseAsset
    {
        public AvatarIKHint ikHint;
        public ExposedReference<Transform> ikTarget;
        public AnimationCurve ikPositionWeightCurve;

        // RVA: 0x13D97FC
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<IKHintPlayableBehaviour> playable =
                ScriptPlayable<IKHintPlayableBehaviour>.Create(graph, 0);
            IKHintPlayableBehaviour behaviour = playable.GetBehaviour();

            behaviour.ikController = ikController;
            behaviour.ikHint = ikHint;
            behaviour.ikTarget = ikTarget.Resolve(graph.GetResolver());
            behaviour.ikPositionWeightCurve = ikPositionWeightCurve;

            return playable;
        }

        // RVA: 0x13D9918
        public IKHintPlayableAsset()
        {
        }
    }
}
