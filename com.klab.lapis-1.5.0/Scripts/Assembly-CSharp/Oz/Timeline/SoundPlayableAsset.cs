// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.SoundPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<SoundPlayableBehaviour>.Create(graph, 0)
//        → behaviour.eventName (0x18) / behaviour.bankName (0x20)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class SoundPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public string eventName;
        public string bankName;
        public ClipCaps clipCaps { get; }

        // RVA: 0x13DC0D8
        public ClipCaps get_clipCaps()
        {
            return ClipCaps.None;
        }

        // RVA: 0x13DC0E0
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<SoundPlayableBehaviour> playable =
                ScriptPlayable<SoundPlayableBehaviour>.Create(graph, 0);
            SoundPlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.eventName = eventName;
            behaviour.bankName = bankName;
            return playable;
        }

        // RVA: 0x13DC1C0
        public SoundPlayableAsset()
        {
        }
    }
}
