// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.ActorStateTrack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//  成员体均为模板形态（基类构造 / 字段属性 / ScriptPlayable 标准创建），已逐条核对
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class ActorStateTrack : Track
    {
        public int lastPostion;

        // RVA: 0x13D6098
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<ActorStateMixer> playable = ScriptPlayable<ActorStateMixer>.Create(graph, inputCount);
            ActorStateMixer behaviour = playable.GetBehaviour();
            SetContext(behaviour, go);
            return playable;
        }

        // RVA: 0x13D618C
        public ActorStateTrack()
        {
        }
    }
}
