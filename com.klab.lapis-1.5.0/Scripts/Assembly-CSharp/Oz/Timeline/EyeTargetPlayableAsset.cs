// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EyeTargetPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<EyeTargetPlayableBehaviour>.Create(graph, 0)
//        → behaviour.expressionSystem(0x10) / behaviour.lookAtTarget(0x18,Resolve)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class EyeTargetPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        [SerializeField]
        public ExposedReference<Transform> lookAtTarget;
        public ClipCaps clipCaps { get; }
        public ExpressionSystem expressionSystem { get; set; }
        // RVA: 0x13D8610
        public ClipCaps get_clipCaps()
        {
            return ClipCaps.None;
        }



        // RVA: 0x13D8628
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<EyeTargetPlayableBehaviour> playable =
                ScriptPlayable<EyeTargetPlayableBehaviour>.Create(graph, 0);
            EyeTargetPlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.expressionSystem = expressionSystem;
            behaviour.lookAtTarget = lookAtTarget.Resolve(graph.GetResolver());
            return playable;
        }

        // RVA: 0x13D8734
        public EyeTargetPlayableAsset()
        {
        }
    }
}
