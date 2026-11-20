// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialPropertyBlockVectorPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<...Vector...>.Create(graph, template, 0)
//        → behaviour.modifier / behaviour.propertyName
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class MaterialPropertyBlockVectorPlayableAsset : MaterialPropertyBlockPlayableAsset
    {
        public MaterialPropertyBlockVectorPlayableBehaviour template;

        // RVA: 0x13DB7F8
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<MaterialPropertyBlockVectorPlayableBehaviour> playable =
                ScriptPlayable<MaterialPropertyBlockVectorPlayableBehaviour>.Create(graph, template, 0);
            MaterialPropertyBlockVectorPlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.modifier = modifier;
            behaviour.propertyName = propertyName;
            return playable;
        }

        // RVA: 0x13DB8E0
        public MaterialPropertyBlockVectorPlayableAsset()
        {
        }
    }
}
