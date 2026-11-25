// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.ScenarioClip
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using TimeLine;

namespace Oz.Timeline
{
    [Serializable]
    public class ScenarioClip : Clip
    {
        public override ClipCaps clipCaps
        {
            // RVA: 0x13DBEF0
            get { return ClipCaps.ClipIn; }
        }

        // RVA: 0x13DBEF8
        public override Playable CreatePlayable(PlayableGraph graph, GameObject go)
        {
            ScriptPlayable<ScenarioBehaviour> playable = ScriptPlayable<ScenarioBehaviour>.Create(graph, go, 0);
            SetContext(playable.GetBehaviour());
            return playable;
        }

        // RVA: 0x13D6DDC
        public ScenarioClip()
        {
        }
    }
}
