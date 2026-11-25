// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  TimeLine.Clip
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  Timeline 片段基类：创建 ScriptPlayable 并绑定运行期上下文。
// =============================================================================

using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace TimeLine
{
    [Serializable]
    public class Clip : PlayableAsset, ITimelineClipAsset, IPropertyPreview
    {
        public bool Await;
        public TimelineClip clipInfo;
        public Mixer mixer;
        public Behaviour behaviour;

        public virtual ClipCaps clipCaps
        {
            // RVA: 0x144D5A0
            get { return ClipCaps.All; }
        }

        // RVA: 0x144D5A8
        public override Playable CreatePlayable(PlayableGraph graph, GameObject go)
        {
            ScriptPlayable<Behaviour> playable = ScriptPlayable<Behaviour>.Create(graph, go, 0);
            SetContext(playable.GetBehaviour());
            return playable;
        }

        // RVA: 0x144D684
        public virtual void SetContext(Behaviour behaviour)
        {
            this.behaviour = behaviour;
            Behaviour.Context context = behaviour.context;
            context.behaviour = behaviour;
            context.clip = this;
            context.mixer = mixer;
            context.track = mixer.context.track;
            context.director = mixer.context.director;
            context.BindObject = mixer.context.BindObject;
            behaviour.SetContext(this);
        }

        // RVA: 0x144D740
        public virtual void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
        }

        // RVA: 0x144D744
        public Clip()
        {
        }
    }
}
