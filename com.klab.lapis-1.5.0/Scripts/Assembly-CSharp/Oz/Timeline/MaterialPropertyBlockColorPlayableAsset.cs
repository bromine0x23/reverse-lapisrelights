// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialPropertyBlockColorPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<...Color...>.Create(graph, template, 0)
//        → behaviour.modifier / behaviour.propertyName
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class MaterialPropertyBlockColorPlayableAsset : MaterialPropertyBlockPlayableAsset
    {
        public MaterialPropertyBlockColorPlayableBehaviour template;

        // RVA: 0x13DAD9C
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<MaterialPropertyBlockColorPlayableBehaviour> playable =
                ScriptPlayable<MaterialPropertyBlockColorPlayableBehaviour>.Create(graph, template, 0);
            MaterialPropertyBlockColorPlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.modifier = modifier;
            behaviour.propertyName = propertyName;
            return playable;
        }

        // RVA: 0x13DAE84
        public MaterialPropertyBlockColorPlayableAsset()
        {
        }
    }
}
