// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.LipSyncTrack2
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + IDA 反汇编核对
//        0x13DA560: ScriptPlayable<LipsyncMixer>.Create(graph, inputCount)
//        0x13DA570: GetBehaviour() → behaviour
//        0x13DA5B0: GetBindingComponent<ExpressionAnimator>(this, director)
//        0x13DA5EC–0x13DA5F0: X8 = [ExpressionAnimator+0x98] → STR [behaviour+0x10]
//        = animator.Voice → behaviour.voiceVowel
//        0x13DA714: STR W21, [asset+0x38]  → asset.ClipIdx = i++
//        0x13DA71C: STR X,   [asset+0x30]  → asset.Mixer = behaviour
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>口型同步轨：取绑定表情系统的 Voice 注入 Mixer，并把 Mixer 与序号写入片段。</summary>
    public sealed class LipSyncTrack2 : TrackAsset
    {
        // RVA: 0x13DA4C4
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<LipsyncMixer> playable = ScriptPlayable<LipsyncMixer>.Create(graph, inputCount);
            LipsyncMixer behaviour = playable.GetBehaviour();

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

            int clipIndex = 0;
            foreach (TimelineClip clip in GetClips())
            {
                LipsyncAsset asset = (LipsyncAsset)clip.asset;
                asset.ClipIdx = clipIndex++;
                asset.Mixer = behaviour;
            }
            return playable;
        }

        // RVA: 0x13DA894
        public LipSyncTrack2()
        {
        }
    }
}
