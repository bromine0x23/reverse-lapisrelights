// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.{SoundTrack,LightTrack,AvatarTrack,ExpressionTrack}
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
                AvatarSystem binding = (AvatarSystem)TrackAssetExtensions.GetBindingComponent(this, director);
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

    /// <summary>表情轨：把 Track 绑定的 ExpressionAnimator 注入 Mixer。</summary>
    public class ExpressionTrack : TrackAsset
    {
        // RVA: 0x13D7B00
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<ExpressionMixerPlayableBehaviour> playable =
                ScriptPlayable<ExpressionMixerPlayableBehaviour>.Create(graph, inputCount);
            ExpressionMixerPlayableBehaviour behaviour = playable.GetBehaviour();

            if (go != null)
            {
                PlayableDirector director = go.GetComponent<PlayableDirector>();
                ExpressionAnimator binding =
                    (ExpressionAnimator)TrackAssetExtensions.GetBindingComponent(this, director);
                if (binding != null)
                {
                    behaviour._bindingAnimator = binding;
                }
            }
            return playable;
        }

        // RVA: 0x13D7C84
        public ExpressionTrack()
        {
        }
    }
}
