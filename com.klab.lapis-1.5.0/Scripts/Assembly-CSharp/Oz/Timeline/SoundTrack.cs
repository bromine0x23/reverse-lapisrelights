// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.SoundTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>声音轨：直接复用基类的 Mixer 创建逻辑。</summary>
    public class SoundTrack : TrackAsset
    {
        // RVA: 0x13DC4CC
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            return base.CreateTrackMixer(graph, go, inputCount);
        }

        // RVA: 0x13DC4D4
        public SoundTrack()
        {
        }
    }
}
