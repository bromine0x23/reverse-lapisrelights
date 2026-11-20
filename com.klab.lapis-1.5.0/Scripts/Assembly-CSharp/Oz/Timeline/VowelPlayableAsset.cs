// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.VowelPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<VowelPlayableBehaviour>.Create(graph, 0)
//        → behaviour.sobj = sobj (0x10)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class VowelPlayableAsset : PlayableAsset
    {
        public VowelScriptObject sobj;

        // RVA: 0x13DE8C0
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<VowelPlayableBehaviour> playable =
                ScriptPlayable<VowelPlayableBehaviour>.Create(graph, 0);
            VowelPlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.sobj = sobj;
            return playable;
        }

        // RVA: 0x13DE998
        public VowelPlayableAsset()
        {
        }
    }
}
