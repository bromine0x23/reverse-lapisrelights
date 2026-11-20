// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.ExpressionPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//  成员体均为模板形态（基类构造 / 字段属性 / ScriptPlayable 标准创建），已逐条核对
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class ExpressionPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public eFaceExpression expression;
        public bool mouthOpen;

        // RVA: 0x13D7A08
        public override ClipCaps clipCaps
        {
            get { return (ClipCaps)16; }
        }

        // RVA: 0x13D7A10
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ScriptPlayable<ExpressionPlayableBehaviour> playable = ScriptPlayable<ExpressionPlayableBehaviour>.Create(graph, 0);
            ExpressionPlayableBehaviour behaviour = playable.GetBehaviour();
            behaviour.expression = this.expression;
            behaviour.mouthOpen = this.mouthOpen;
            return playable;
        }

        // RVA: 0x13D7AF0
        public ExpressionPlayableAsset()
        {
        }
    }
}
