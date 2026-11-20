// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.SpringBonePlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<SpringBonePlayableBehaviour>.Create(graph, 0)
//        → windPower(0x10) / windRot(0x14) / disFrequent(0x20) / springMgr(0x28)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class SpringBonePlayableAsset : SpringBoneBaseAsset
    {
        public float windPower;
        public Vector3 windRot;
        public float disFrequent;

        // RVA: 0x13DC7B0
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<SpringBonePlayableBehaviour> playable =
                ScriptPlayable<SpringBonePlayableBehaviour>.Create(graph, 0);
            SpringBonePlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.windPower = windPower;
            behaviour.windRot = windRot;
            behaviour.disFrequent = disFrequent;
            behaviour.springMgr = springMgr;
            return playable;
        }

        // RVA: 0x13DC8A8
        public SpringBonePlayableAsset()
        {
        }
    }
}
