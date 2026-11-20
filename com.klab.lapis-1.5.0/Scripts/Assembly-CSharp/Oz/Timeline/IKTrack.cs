// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.IKTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + IDA 反汇编核对
//        0x13D9AE0: GetBindingComponent<Actor>(this, go.GetComponent<PlayableDirector>())
//        0x13D9C8C–0x13D9C9C: X8 = [Actor+0x30] → [X8+0x40] → STR [asset+0x18]
//        = actor.MotionSystem.IKTimelineController → asset.ikController
//        0x13D9Dxx: 末尾 TrackAsset.CreateTrackMixer(this, graph, go, inputCount)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>IK 轨：把绑定 Actor 的 IK 控制器写入每个片段的 asset，Mixer 由基类创建。</summary>
    public class IKTrack : TrackAsset
    {
        // RVA: 0x13D9A50
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
                        IKBaseAsset asset = clip.asset as IKBaseAsset;
                        if (asset != null)
                        {
                            asset.ikController = actor.MotionSystem.IKTimelineController;
                        }
                    }
                }
            }
            return base.CreateTrackMixer(graph, go, inputCount);
        }

        // RVA: 0x13D9E18
        public IKTrack()
        {
        }
    }
}
