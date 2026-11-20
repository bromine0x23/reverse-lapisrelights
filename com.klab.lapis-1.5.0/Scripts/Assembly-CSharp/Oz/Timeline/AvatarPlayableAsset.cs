// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.AvatarPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<AvatarPlayableBehaviour>.Create(graph, 0)，
//        avatarSetting 非空时 behaviour.avatarPart = AvatarPart.Build(avatarSetting, false)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class AvatarPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public AvatarSetting avatarSetting;
        public ClipCaps clipCaps { get; }

        // RVA: 0x13D6528
        public ClipCaps get_clipCaps()
        {
            return ClipCaps.None;
        }

        // RVA: 0x13D6530
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<AvatarPlayableBehaviour> playable =
                ScriptPlayable<AvatarPlayableBehaviour>.Create(graph, 0);
            AvatarPlayableBehaviour behaviour = playable.GetBehaviour();
            if (avatarSetting != null)
            {
                behaviour.avatarPart = AvatarPart.Build(avatarSetting, false);
            }
            return playable;
        }

        // RVA: 0x13D6674
        public AvatarPlayableAsset()
        {
        }
    }
}
