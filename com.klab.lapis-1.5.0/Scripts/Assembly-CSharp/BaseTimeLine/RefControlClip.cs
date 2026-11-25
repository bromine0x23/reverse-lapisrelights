// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  BaseTimeLine.RefControlClip
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using TimeLine;

namespace BaseTimeLine
{
    [Serializable]
    public class RefControlClip : Clip
    {
        public List<RefControlClip.ControlItem> Items;

        public override ClipCaps clipCaps
        {
            // RVA: 0x1996474
            get { return ClipCaps.None; }
        }

        // RVA: 0x199647C
        public override Playable CreatePlayable(PlayableGraph graph, GameObject go)
        {
            ScriptPlayable<RefControlBehaviour> playable = ScriptPlayable<RefControlBehaviour>.Create(graph, go, 0);
            SetContext(playable.GetBehaviour());
            return playable;
        }

        // RVA: 0x1996558
        public override void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
        }

        // RVA: 0x199655C
        public RefControlClip()
        {
            Items = new List<ControlItem>();
        }

        [Serializable]
        public class ControlItem
        {
            public SceneReference Reference;
            public SceneReference Postion;
            public RangeFloat LifeTime;
            public bool On;
            public bool SetAsChild;
            public bool apply;

            // RVA: 0x19965CC
            public ControlItem()
            {
                Reference = new SceneReference();
                Postion = new SceneReference();
                LifeTime = new RangeFloat(0f, 1.1f);
            }
        }
    }
}
