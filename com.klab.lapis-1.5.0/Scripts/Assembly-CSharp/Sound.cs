// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Sound
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Oz.Timeline;

[Serializable]
public class Sound : ScenarioClip
{
    public List<Sound.SoundItem> Sounds;
    public bool StopAll;
    public string BGM;

    // RVA: 0x17D90FC
    public override Playable CreatePlayable(PlayableGraph graph, GameObject go)
    {
        ScriptPlayable<ScenarioBehaviour> playable = ScriptPlayable<ScenarioBehaviour>.Create(graph, go, 0);
        SetContext(playable.GetBehaviour());
        return playable;
    }

    // RVA: 0x17D91D8
    public Sound()
    {
        Sounds = new List<SoundItem>();
    }

    [Serializable]
    public class SoundItem
    {
        public float LifeTime;
        public string EventName;
        public bool apply;

        // RVA: 0x17D9248
        public SoundItem()
        {
        }
    }
}
