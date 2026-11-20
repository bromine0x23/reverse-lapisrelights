// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.SpringBoneHairSwitchAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<SpringBoneHairSwitchBehaviour>.Create(graph, 0)
//        → behaviour.swtichOn(0x10) / behaviour.springMgr(0x18)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class SpringBoneHairSwitchAsset : SpringBoneBaseAsset
    {
        public bool swtichOn;

        // RVA: 0x13DC54C
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<SpringBoneHairSwitchBehaviour> playable =
                ScriptPlayable<SpringBoneHairSwitchBehaviour>.Create(graph, 0);
            SpringBoneHairSwitchBehaviour behaviour = playable.GetBehaviour();
            behaviour.swtichOn = swtichOn;
            behaviour.springMgr = springMgr;
            return playable;
        }

        // RVA: 0x13DC62C
        public SpringBoneHairSwitchAsset()
        {
        }
    }
}
