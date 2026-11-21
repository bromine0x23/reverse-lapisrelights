// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EyeBlinkPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<EyeBlinkPlayableBehaviour>.Create(graph, 0)
//        → behaviour.Asset = this (0x18) / behaviour.blinkCurve = blinkCurve (0x10)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class EyeBlinkPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public AnimationCurve blinkCurve;
        public ClipCaps clipCaps { get; }
        public int ClipIdx { get; internal set; }
        public EyeBlinkMixerPlayableBehaviour Mixer { get; internal set; }
        // RVA: 0x13D8048
        public ClipCaps get_clipCaps()
        {
            return ClipCaps.None;
        }





        // RVA: 0x13D8070
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<EyeBlinkPlayableBehaviour> playable =
                ScriptPlayable<EyeBlinkPlayableBehaviour>.Create(graph, 0);
            EyeBlinkPlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.Asset = this;
            behaviour.blinkCurve = blinkCurve;
            return playable;
        }

        // RVA: 0x13D814C
        public EyeBlinkPlayableAsset()
        {
        }
    }
}
