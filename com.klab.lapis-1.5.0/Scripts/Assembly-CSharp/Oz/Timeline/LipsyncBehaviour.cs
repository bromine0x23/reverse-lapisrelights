// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.LipsyncBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        OnBehaviourPlay: Asset.Mixer.EnterClip(this)（IL2CPP 内联了 EnterClip 的槽位轮转）
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class LipsyncBehaviour : PlayableBehaviour
    {
        public LipsyncAsset Asset { get; private set; }


        // RVA: 0x13DA9E8
        public LipsyncBehaviour(LipsyncAsset asset)
        {
            Asset = asset;
        }

        // RVA: 0x13DAA98
        public LipsyncBehaviour()
        {
        }

        // RVA: 0x13DAAA0
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            Asset.Mixer.EnterClip(this);
        }
    }
}
