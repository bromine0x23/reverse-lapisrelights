// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.DialogTack
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//  成员体均为模板形态（基类构造 / 字段属性 / ScriptPlayable 标准创建），已逐条核对
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class DialogTack : Track
    {

        // RVA: 0x13D7410
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            ScriptPlayable<ScenarioMixer> playable = ScriptPlayable<ScenarioMixer>.Create(graph, inputCount);
            ScenarioMixer behaviour = playable.GetBehaviour();
            SetContext(behaviour, go);
            return playable;
        }

        // RVA: 0x13D7504
        public DialogTack()
        {
        }
    }
}
