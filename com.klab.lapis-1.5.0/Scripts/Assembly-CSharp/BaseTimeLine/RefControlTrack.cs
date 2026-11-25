// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  BaseTimeLine.RefControlTrack
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using TimeLine;

namespace BaseTimeLine
{
    [TrackClipType(typeof(RefControlClip))]
    public class RefControlTrack : Track
    {
        // RVA: 0x1996684
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<RefControlMixer> playable = ScriptPlayable<RefControlMixer>.Create(graph, inputCount);
            SetContext(playable.GetBehaviour(), go);
            return playable;
        }

        // RVA: 0x1996778
        public RefControlTrack()
        {
        }
    }
}
