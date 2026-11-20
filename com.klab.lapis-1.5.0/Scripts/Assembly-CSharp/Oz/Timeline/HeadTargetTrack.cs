// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.HeadTargetTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + IDA 反汇编核对
//        0x13D8F58: GetBindingComponent<Actor>(this, go.GetComponent<PlayableDirector>())
//        0x13D90A4–0x13D90DC: clip.asset 的 `as` 转换（X26）
//        0x13D9110–0x13D9120: X8 = [Actor+0x30] → [X8+0x38] → STR [X26+0x18]
//        = actor.MotionSystem.HeadDirection → asset.headDirection
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>头部朝向轨：把绑定 Actor 的头部控制器写入每个片段的 asset。</summary>
    public class HeadTargetTrack : TrackAsset
    {
        // RVA: 0x13D8ED4
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            if (go != null)
            {
                PlayableDirector director = go.GetComponent<PlayableDirector>();
                Actor actor = TrackAssetExtensions.GetBindingComponent<Actor>(this, director);
                if (actor != null)
                {
                    foreach (TimelineClip clip in GetClips())
                    {
                        HeadTargetPlayableAsset asset = clip.asset as HeadTargetPlayableAsset;
                        if (asset != null)
                        {
                            asset.headDirection = actor.MotionSystem.HeadDirection;
                        }
                    }
                }
            }
            return base.CreateTrackMixer(graph, go, inputCount);
        }

        // RVA: 0x13D929C
        public HeadTargetTrack()
        {
        }
    }
}
