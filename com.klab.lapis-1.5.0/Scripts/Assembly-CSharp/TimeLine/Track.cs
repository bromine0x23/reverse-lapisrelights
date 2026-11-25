// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  TimeLine.Track
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  轨道基类：创建 Mixer，并把同轨片段绑定到运行期上下文。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace TimeLine
{
    public abstract class Track : TrackAsset
    {
        // RVA: 0x144DF30
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<Mixer> playable = ScriptPlayable<Mixer>.Create(graph, inputCount);
            SetContext(playable.GetBehaviour(), go);
            return playable;
        }

        // RVA: 0x144E024
        public virtual void SetContext(Mixer mixer, GameObject go)
        {
            mixer.context.track = this;
            mixer.context.director = go.GetComponent<PlayableDirector>();
            mixer.context.BindObject = GetBindingObject(mixer.context.director);

            foreach (TimelineClip clipInfo in GetClips())
            {
                Clip clip = clipInfo.asset as Clip;
                if (clip != null)
                {
                    clip.clipInfo = clipInfo;
                    clip.mixer = mixer;
                }
            }
        }

        // RVA: 0x144E334
        public virtual Object GetBindingObject(PlayableDirector director)
        {
            return director.GetGenericBinding(this);
        }

        // RVA: 0x144E358
        protected Track()
        {
        }
    }
}
