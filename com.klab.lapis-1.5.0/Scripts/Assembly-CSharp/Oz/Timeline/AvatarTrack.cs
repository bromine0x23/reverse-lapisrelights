// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.AvatarTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>Avatar 轨：把 Track 绑定的组件注入 Mixer 的 avatarSystem。</summary>
    public class AvatarTrack : TrackAsset
    {
        // RVA: 0x13D66A0
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<AvatarMixerPlayableBehaviour> playable =
                ScriptPlayable<AvatarMixerPlayableBehaviour>.Create(graph, inputCount);
            AvatarMixerPlayableBehaviour behaviour = playable.GetBehaviour();

            if (go != null)
            {
                PlayableDirector director = go.GetComponent<PlayableDirector>();
                AvatarSystem binding = TrackAssetExtensions.GetBindingComponent(this, director) as AvatarSystem;
                if (binding != null)
                {
                    behaviour.avatarSystem = binding;
                }
            }
            return playable;
        }

        // RVA: 0x13D681C
        public AvatarTrack()
        {
        }
    }
}
