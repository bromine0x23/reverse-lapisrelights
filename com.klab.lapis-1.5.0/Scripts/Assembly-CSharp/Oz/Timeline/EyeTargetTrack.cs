// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EyeTargetTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + IDA 反汇编核对
//        0x13D8894: STR X8,[X21,#0x10]  → behaviour.expressionSystem
//        0x13D8A04: STR X8,[X21,#0x18]  → asset.expressionSystem
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>视线目标轨：绑定 ExpressionSystem 并注入到每个片段 asset。</summary>
    public class EyeTargetTrack : TrackAsset
    {
        // RVA: 0x13D8760
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<EyeTargetMixerPlayableBehaviour> playable =
                ScriptPlayable<EyeTargetMixerPlayableBehaviour>.Create(graph, inputCount);
            EyeTargetMixerPlayableBehaviour behaviour = playable.GetBehaviour();

            if (go != null)
            {
                PlayableDirector director = go.GetComponent<PlayableDirector>();
                Component binding = TrackAssetExtensions.GetBindingComponent(this, director);
                if (binding != null)
                {
                    behaviour.expressionSystem = binding.GetComponent<ExpressionSystem>();
                }
            }

            foreach (TimelineClip clip in GetClips())
            {
                EyeTargetPlayableAsset asset = clip.asset as EyeTargetPlayableAsset;
                if (asset != null)
                {
                    asset.expressionSystem = behaviour.expressionSystem;
                }
            }
            return playable;
        }

        // RVA: 0x13D8A60
        public EyeTargetTrack()
        {
        }
    }
}
