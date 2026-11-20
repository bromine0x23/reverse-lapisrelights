// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.HeadTargetPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<HeadTargetPlayableBehaviour>.Create(graph, 0)
//        → headDirection(0x20) / lookAtTarget(0x10,Resolve) / weightCurve(0x18)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class HeadTargetPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public IKHeadController headDirection;
        public ExposedReference<Transform> lookAtTarget;
        public AnimationCurve weight;
        public ClipCaps clipCaps { get; }

        // RVA: 0x13D8BEC
        public ClipCaps get_clipCaps()
        {
            return ClipCaps.None;
        }

        // RVA: 0x13D8BF4
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<HeadTargetPlayableBehaviour> playable =
                ScriptPlayable<HeadTargetPlayableBehaviour>.Create(graph, 0);
            HeadTargetPlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.headDirection = headDirection;
            behaviour.lookAtTarget = lookAtTarget.Resolve(graph.GetResolver());
            behaviour.weightCurve = weight;
            return playable;
        }

        // RVA: 0x13D8D08
        public HeadTargetPlayableAsset()
        {
        }
    }
}
