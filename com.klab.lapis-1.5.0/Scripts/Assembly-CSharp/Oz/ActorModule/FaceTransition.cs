// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.FaceTransition
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ctor 为 brow/eye/mouth 各建 BlendTransition[]（src.Weight → dest.Weight）；
//        UpdateWeight 按 deltaTime 推进 time 并归一化为 weight；
//        Set* 用 Mathf.Lerp(src, dest, weight) 写回 ref 参数。
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class FaceTransition
    {
        public float weight;
        public float time;
        public float duration;
        public BlendTransition[] browList;
        public BlendTransition[] eyeList;
        public BlendTransition[] mouthList;
        public float srcCheekPower;
        public float destCheekPower;
        public float srcForeheadShade;
        public float destForeheadShade;
        public float srcEyeHighlight;
        public float destEyeHighlight;
        public float srcEyeScale;
        public float destEyeScale;
        public bool isDone { get; }

        // RVA: 0x13F024C
        public FaceTransition(
            float duration,
            BlendWeight[] srcBrowList,
            BlendWeight[] srcEyeList,
            BlendWeight[] srcMouthList,
            float srcCheekPower,
            float srcForeheadShade,
            float srcEyeHighlight,
            float srcEyeScale,
            BlendWeight[] destBrowList,
            BlendWeight[] destEyeList,
            BlendWeight[] destMouthList,
            float destCheekPower,
            float destForeheadShade,
            float destEyeHighlight,
            float destEyeScale)
        {
            this.duration = duration;
            time = 0f;

            browList = new BlendTransition[srcBrowList.Length];
            for (int i = 0; i < browList.Length; i++)
            {
                browList[i] = new BlendTransition(
                    srcBrowList[i].Handle, srcBrowList[i].Weight, destBrowList[i].Weight);
            }

            eyeList = new BlendTransition[srcEyeList.Length];
            for (int i = 0; i < eyeList.Length; i++)
            {
                eyeList[i] = new BlendTransition(
                    srcEyeList[i].Handle, srcEyeList[i].Weight, destEyeList[i].Weight);
            }

            mouthList = new BlendTransition[srcMouthList.Length];
            for (int i = 0; i < mouthList.Length; i++)
            {
                mouthList[i] = new BlendTransition(
                    srcMouthList[i].Handle, srcMouthList[i].Weight, destMouthList[i].Weight);
            }

            this.srcCheekPower = srcCheekPower;
            this.destCheekPower = destCheekPower;
            this.srcForeheadShade = srcForeheadShade;
            this.destForeheadShade = destForeheadShade;
            this.srcEyeHighlight = srcEyeHighlight;
            this.destEyeHighlight = destEyeHighlight;
            this.srcEyeScale = srcEyeScale;
            this.destEyeScale = destEyeScale;
        }

        // RVA: 0x13F0540
        public void UpdateWeight()
        {
            time += Time.deltaTime;
            weight = duration <= 0f ? 1f : Mathf.Clamp01(time / duration);
        }

        // RVA: 0x13F05E0
        public void SetBlendWeight(BlendWeight[] browList, BlendWeight[] eyeList, BlendWeight[] mouthList)
        {
            if (browList != null)
            {
                for (int i = 0; i < browList.Length; i++)
                {
                    browList[i].Weight = this.browList[i].GetWeight(weight);
                }
            }

            if (eyeList != null)
            {
                for (int i = 0; i < eyeList.Length; i++)
                {
                    eyeList[i].Weight = this.eyeList[i].GetWeight(weight);
                }
            }

            if (mouthList != null)
            {
                for (int i = 0; i < mouthList.Length; i++)
                {
                    mouthList[i].Weight = this.mouthList[i].GetWeight(weight);
                }
            }
        }

        // RVA: 0x13F0768
        public void SetCheekPower(ref float cheekPower)
        {
            cheekPower = Mathf.Lerp(srcCheekPower, destCheekPower, weight);
        }

        // RVA: 0x13F0804
        public void SetForeheadShade(ref float foreheadShade)
        {
            foreheadShade = Mathf.Lerp(srcForeheadShade, destForeheadShade, weight);
        }

        // RVA: 0x13F08A0
        public void SetEyeHighlight(ref float eyeHighlight)
        {
            eyeHighlight = Mathf.Lerp(srcEyeHighlight, destEyeHighlight, weight);
        }

        // RVA: 0x13F093C
        public void SetEyeScale(ref float eyeScale)
        {
            eyeScale = Mathf.Lerp(srcEyeScale, destEyeScale, weight);
        }

        // RVA: 0x13F09D8
        public bool get_isDone()
        {
            return time >= duration;
        }
    }
}
