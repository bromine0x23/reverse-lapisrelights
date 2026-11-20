// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialPropertyBlockTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>材质属性块轨：把 Track 绑定的 IMaterialPropertyBlockModifier 注入片段与 Mixer。</summary>
    public class MaterialPropertyBlockTrack : TrackAsset
    {
        // RVA: 0x13DB3C4
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            if (go != null)
            {
                PlayableDirector director = go.GetComponent<PlayableDirector>();
                IMaterialPropertyBlockModifier binding =
                    TrackAssetExtensions.GetBindingInterface(this, director) as IMaterialPropertyBlockModifier;

                foreach (TimelineClip clip in GetClips())
                {
                    MaterialPropertyBlockPlayableAsset asset = clip.asset as MaterialPropertyBlockPlayableAsset;
                    if (asset != null && binding != null)
                    {
                        asset.modifier = binding;
                    }
                }

                ScriptPlayable<MaterialPropertyBlockMixerPlayableBehaviour> playable =
                    ScriptPlayable<MaterialPropertyBlockMixerPlayableBehaviour>.Create(graph, inputCount);
                MaterialPropertyBlockMixerPlayableBehaviour behaviour = playable.GetBehaviour();
                if (binding != null)
                {
                    behaviour.modifier = binding;
                }
                return playable;
            }

            return base.CreateTrackMixer(graph, go, inputCount);
        }

        // RVA: 0x13DB790
        public MaterialPropertyBlockTrack()
        {
        }
    }
}
