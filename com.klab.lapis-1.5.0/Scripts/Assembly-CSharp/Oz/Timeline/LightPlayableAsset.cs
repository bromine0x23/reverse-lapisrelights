// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.LightPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<LightPlayableBehaviour>.Create(graph, template, 0)
//        get_clipCaps = 23 = Looping | Holding | Extrapolation | SpeedMultiplier
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class LightPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public LightPlayableBehaviour template;
        public ClipCaps clipCaps { get; }

        // RVA: 0x13DA260
        public ClipCaps get_clipCaps()
        {
            return ClipCaps.Looping | ClipCaps.Holding | ClipCaps.Extrapolation | ClipCaps.SpeedMultiplier;
        }

        // RVA: 0x13DA268
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            return ScriptPlayable<LightPlayableBehaviour>.Create(graph, template, 0);
        }

        // RVA: 0x13DA308
        public LightPlayableAsset()
        {
        }
    }
}
