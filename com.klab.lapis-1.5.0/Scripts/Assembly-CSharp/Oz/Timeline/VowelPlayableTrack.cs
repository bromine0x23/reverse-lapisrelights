// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.VowelPlayableTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + IDA 反汇编核对
//        0x13DEAD0: LDR X8,[ExpressionAnimator+0x98]（<Voice>）→ STR [behaviour+0x10]
//        = behaviour.voiceVowel = animator.Voice
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class VowelPlayableTrack : TrackAsset
    {
        // RVA: 0x13DE9AC
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<VowelTrackBehaviour> playable =
                ScriptPlayable<VowelTrackBehaviour>.Create(graph, inputCount);
            VowelTrackBehaviour behaviour = playable.GetBehaviour();

            if (go != null)
            {
                PlayableDirector director = go.GetComponent<PlayableDirector>();
                ExpressionAnimator animator =
                    TrackAssetExtensions.GetBindingComponent<ExpressionAnimator>(this, director);
                if (animator != null)
                {
                    behaviour.voiceVowel = animator.Voice;
                }
            }
            return playable;
        }

        // RVA: 0x13DEB28
        public VowelPlayableTrack()
        {
        }
    }
}
