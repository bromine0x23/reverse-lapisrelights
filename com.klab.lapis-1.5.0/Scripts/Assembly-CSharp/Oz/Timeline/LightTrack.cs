// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.LightTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>灯光轨：仅创建 Mixer，无需取 Behaviour。</summary>
    public class LightTrack : TrackAsset
    {
        // RVA: 0x13DA3C4
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            return ScriptPlayable<LightMixerPlayableBehaviour>.Create(graph, inputCount);
        }

        // RVA: 0x13DA45C
        public LightTrack()
        {
        }
    }
}
