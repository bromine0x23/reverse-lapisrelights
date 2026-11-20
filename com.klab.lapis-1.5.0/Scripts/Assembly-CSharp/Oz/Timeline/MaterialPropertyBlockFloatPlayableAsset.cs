// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialPropertyBlockFloatPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<...Float...>.Create(graph, template, 0)
//        → behaviour.modifier / behaviour.propertyName
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class MaterialPropertyBlockFloatPlayableAsset : MaterialPropertyBlockPlayableAsset
    {
        public MaterialPropertyBlockFloatPlayableBehaviour template;

        // RVA: 0x13DAFA4
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<MaterialPropertyBlockFloatPlayableBehaviour> playable =
                ScriptPlayable<MaterialPropertyBlockFloatPlayableBehaviour>.Create(graph, template, 0);
            MaterialPropertyBlockFloatPlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.modifier = modifier;
            behaviour.propertyName = propertyName;
            return playable;
        }

        // RVA: 0x13DB08C
        public MaterialPropertyBlockFloatPlayableAsset()
        {
        }
    }
}
