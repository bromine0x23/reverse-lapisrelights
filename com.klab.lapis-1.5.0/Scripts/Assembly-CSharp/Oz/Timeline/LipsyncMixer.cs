// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.LipsyncMixer
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        EnterClip: 双槽轮转（clipA ← clipB，clipB ← 新片段）
//        SetVowelWeight: voiceVowel.SetVowelWeight(asset.Index - 1, weight * asset.Weight)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class LipsyncMixer : PlayableBehaviour
    {
        public VoiceVowel voiceVowel;
        private LipsyncBehaviour clipA;
        private LipsyncBehaviour clipB;

        // RVA: 0x13DAAE8
        public void EnterClip(LipsyncBehaviour lipsyncBehaviour)
        {
            if (clipA != null)
            {
                if (clipB != null)
                {
                    clipA = clipB;
                }
                clipB = lipsyncBehaviour;
            }
            else
            {
                clipA = lipsyncBehaviour;
            }
        }

        // RVA: 0x13DAB10
        public override void PrepareFrame(Playable playable, FrameData info)
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x13DAB14
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x13DACDC
        private void SetVowelWeight(LipsyncAsset asset, Playable playable)
        {
            if (asset == null)
            {
                return;
            }

            float weight = playable.GetInputWeight(asset.ClipIdx);
            if (weight > 0f && voiceVowel != null)
            {
                voiceVowel.SetVowelWeight((Vowel)(asset.Index - 1), weight * asset.Weight);
            }
        }

        // RVA: 0x13DAD94
        public LipsyncMixer()
        {
        }
    }
}
