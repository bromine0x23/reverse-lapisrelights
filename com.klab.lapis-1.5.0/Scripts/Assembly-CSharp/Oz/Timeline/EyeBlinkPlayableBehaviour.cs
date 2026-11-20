// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EyeBlinkPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        OnBehaviourPlay: Asset.Mixer.EnterClip(this)（原为对 clip 字段的直接赋值，
//        由 IL2CPP 内联 EnterClip(0x13D7CEC) 得到）
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class EyeBlinkPlayableBehaviour : PlayableBehaviour
    {
        public AnimationCurve blinkCurve;
        public EyeBlinkPlayableAsset Asset { get; internal set; }

        // RVA: 0x13D8154
        public EyeBlinkPlayableAsset get_Asset()
        {
            return Asset;
        }

        // RVA: 0x13D815C
        internal void set_Asset(EyeBlinkPlayableAsset value)
        {
            Asset = value;
        }

        // RVA: 0x13D8164
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            if (Asset != null)
            {
                Asset.Mixer.EnterClip(this);
            }
        }

        // RVA: 0x13D818C
        public EyeBlinkPlayableBehaviour()
        {
        }
    }
}
