// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EyeBlinkTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + IDA 反汇编核对
//        （0x13D82C8: STR X8, [X20,#0x18] → EyeBlinkPlayableAsset.ClipIdx）
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>眨眼轨：为每个片段的 asset 记录序号，并创建眨眼 Mixer。</summary>
    public class EyeBlinkTrack : TrackAsset
    {
        // RVA: 0x13D8194
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<EyeBlinkMixerPlayableBehaviour> playable =
                ScriptPlayable<EyeBlinkMixerPlayableBehaviour>.Create(graph, inputCount);
            EyeBlinkMixerPlayableBehaviour behaviour = playable.GetBehaviour();

            if (go != null)
            {
                // 0x13D8250: X20 = GetBehaviour()；0x13D82B8–0x13D82C8:
                // behaviour.<0x18> = binding.<0x38>
                PlayableDirector director = go.GetComponent<PlayableDirector>();
                Component binding = TrackAssetExtensions.GetBindingComponent(this, director);
                if (binding != null)
                {
                    behaviour.bindingComponent = binding.GetComponent<ExpressionAnimator>();
                }
            }

            foreach (TimelineClip clip in GetClips())
            {
                EyeBlinkPlayableAsset asset = clip.asset as EyeBlinkPlayableAsset;
                if (asset != null)
                {
                    asset.Mixer = behaviour;
                }
            }
            return playable;
        }

        // RVA: 0x13D848C
        public EyeBlinkTrack()
        {
        }
    }
}
