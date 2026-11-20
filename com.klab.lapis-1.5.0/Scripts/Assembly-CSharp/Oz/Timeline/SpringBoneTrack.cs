// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.SpringBoneTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    /// <summary>
    /// 弹簧骨骼轨：把绑定对象上的 SpringManager 注入每个 SpringBone 片段的 asset，
    /// 随后交回基类创建 Mixer。
    /// </summary>
    public class SpringBoneTrack : TrackAsset
    {
        // RVA: 0x13DCA44
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            if (go != null)
            {
                PlayableDirector director = go.GetComponent<PlayableDirector>();
                GameObject bindingGo = TrackAssetExtensions.GetBindingGameObject(this, director);
                if (bindingGo != null)
                {
                    SpringManager component = bindingGo.GetComponentInChildren<SpringManager>();
                    if (component != null)
                    {
                        foreach (TimelineClip clip in GetClips())
                        {
                            SpringBoneBaseAsset asset = clip.asset as SpringBoneBaseAsset;
                            if (asset != null)
                            {
                                asset.springManager = component;
                            }
                        }
                    }
                }
            }
            return base.CreateTrackMixer(graph, go, inputCount);
        }

        // RVA: 0x13DCFAC
        public SpringBoneTrack()
        {
        }
    }
}
