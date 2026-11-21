// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.ExpressionTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>表情轨：把 Track 绑定的 ExpressionAnimator 注入 Mixer。</summary>
    public class ExpressionTrack : TrackAsset
    {
        // RVA: 0x13D7B00
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<ExpressionMixerPlayableBehaviour> playable =
                ScriptPlayable<ExpressionMixerPlayableBehaviour>.Create(graph, inputCount);
            ExpressionMixerPlayableBehaviour behaviour = playable.GetBehaviour();

            if (go != null)
            {
                PlayableDirector director = go.GetComponent<PlayableDirector>();
                ExpressionAnimator binding =
                    TrackAssetExtensions.GetBindingComponent(this, director) as ExpressionAnimator;
                if (binding != null)
                {
                    behaviour.bindingAnimator = binding;
                }
            }
            return playable;
        }

        // RVA: 0x13D7C84
        public ExpressionTrack()
        {
        }
    }
}
