// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.IKBodyOffsetPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<IKBodyOffsetPlayableBehaviour>.Create(graph, 0)
//        → ikController/ikBodyPositionOffset(Vector3)/ikBodyPositionOffsetWeightCurve
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class IKBodyOffsetPlayableAsset : IKBaseAsset
    {
        public Vector3 ikBodyPositionOffset;
        public AnimationCurve ikBodyPositionOffsetWeightCurve;

        // RVA: 0x13D9314
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<IKBodyOffsetPlayableBehaviour> playable =
                ScriptPlayable<IKBodyOffsetPlayableBehaviour>.Create(graph, 0);
            IKBodyOffsetPlayableBehaviour behaviour = playable.GetBehaviour();

            behaviour.ikController = ikController;
            behaviour.ikBodyPositionOffset = ikBodyPositionOffset;
            behaviour.ikBodyPositionOffsetWeightCurve = ikBodyPositionOffsetWeightCurve;

            return playable;
        }

        // RVA: 0x13D9404
        public IKBodyOffsetPlayableAsset()
        {
        }
    }
}
