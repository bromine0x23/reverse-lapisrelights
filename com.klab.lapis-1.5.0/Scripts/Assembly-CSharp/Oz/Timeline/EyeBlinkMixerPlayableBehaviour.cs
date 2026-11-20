// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EyeBlinkMixerPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame 按当前 clip 的输入权重 / 播放状态决定眨眼比率；
//        写入 m_EyeBlinkRate(0x18) 即 ExpressionAnimator.SetBlinkRatio(0x16B2E44)。
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class EyeBlinkMixerPlayableBehaviour : PlayableBehaviour
    {
        private EyeBlinkPlayableBehaviour clip;
        private ExpressionAnimator _bindingComponent;
        public ExpressionAnimator bindingComponent { get; set; }

        // RVA: 0x13D7CEC
        public void EnterClip(EyeBlinkPlayableBehaviour behaviour)
        {
            clip = behaviour;
        }

        // RVA: 0x13D7CF4
        public ExpressionAnimator get_bindingComponent()
        {
            return _bindingComponent;
        }

        // RVA: 0x13D7CFC
        public void set_bindingComponent(ExpressionAnimator value)
        {
            _bindingComponent = value;
        }

        // RVA: 0x13D7D04
        public override void OnGraphStart(Playable playable)
        {
            if (_bindingComponent != null)
            {
                _bindingComponent.SetAutoBlink(false);
            }
        }

        // RVA: 0x13D7D9C
        public override void OnGraphStop(Playable playable)
        {
            if (_bindingComponent != null)
            {
                _bindingComponent.SetAutoBlink(true);
            }
        }

        // RVA: 0x13D7E34
        private void SetBlinkProcessFrame(EyeBlinkPlayableAsset asset, Playable playable)
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x13D7E38
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            base.ProcessFrame(playable, info, playerData);

            if (clip == null)
            {
                return;
            }

            int clipIdx = clip.Asset.ClipIdx;
            if (playable.GetInputWeight(clipIdx) > 0f && playable.GetPlayState() == PlayState.Playing)
            {
                Playable input = playable.GetInput(clipIdx);
                if (clip.blinkCurve != null && _bindingComponent != null)
                {
                    _bindingComponent.SetBlinkRatio(
                        clip.blinkCurve.Evaluate((float)input.GetTime() / (float)input.GetDuration()));
                }
            }
            else if (_bindingComponent != null)
            {
                _bindingComponent.SetBlinkRatio(1f);
            }
        }

        // RVA: 0x13D8040
        public EyeBlinkMixerPlayableBehaviour()
        {
        }
    }
}
