// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.ExpressionMixerPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: 首次从 playerData(GameObject) 取 ExpressionAnimator，
//        ClearChanges() 后按权重 MixExpression(expression, mouthOpen, weight)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class ExpressionMixerPlayableBehaviour : PlayableBehaviour
    {
        public ExpressionAnimator bindingAnimator { get; set; }

        // RVA: 0x13D76B4
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            base.ProcessFrame(playable, info, playerData);

            if (bindingAnimator == null)
            {
                GameObject go = playerData as GameObject;
                if (go != null)
                {
                    bindingAnimator = go.GetComponent<ExpressionAnimator>();
                }
            }

            if (bindingAnimator == null)
            {
                return;
            }

            bindingAnimator.ClearChanges();

            int inputCount = playable.GetInputCount();
            for (int i = 0; i < inputCount; i++)
            {
                float weight = playable.GetInputWeight(i);
                if (weight > 0f && playable.GetPlayState() == PlayState.Playing)
                {
                    ScriptPlayable<ExpressionPlayableBehaviour> input =
                        (ScriptPlayable<ExpressionPlayableBehaviour>)playable.GetInput(i);
                    ExpressionPlayableBehaviour behaviour = input.GetBehaviour();
                    if (behaviour != null)
                    {
                        bindingAnimator.MixExpression(behaviour.expression, behaviour.mouthOpen, weight);
                    }
                }
            }
        }

        // RVA: 0x13D796C
        public override void OnGraphStop(Playable playable)
        {
            if (bindingAnimator != null)
            {
                bindingAnimator.ClearChanges();
            }
        }

        // RVA: 0x13D7A00
        public ExpressionMixerPlayableBehaviour()
        {
        }
    }
}
