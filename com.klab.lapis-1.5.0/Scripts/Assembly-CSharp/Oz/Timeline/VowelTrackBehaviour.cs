// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.VowelTrackBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: 对每个激活的 VowelPlayableBehaviour（sobj）按
//        curFrame = (int)(time * sobj.FrameRate) 取当前/下一片段的权重并归一化
// =============================================================================

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class VowelTrackBehaviour : PlayableBehaviour
    {
        public VoiceVowel voiceVowel;
        private LinkedList<VowelScriptObject.VowelClipInfo> linkList;
        private LinkedListNode<VowelScriptObject.VowelClipInfo> headNode;

        // RVA: 0x13DEB90
        public override void PrepareFrame(Playable playable, FrameData info)
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x13DEB94
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (voiceVowel != null)
            {
                voiceVowel.ResetVowelInfo();
            }

            int inputCount = playable.GetInputCount();
            for (int i = 0; i < inputCount; i++)
            {
                float weight = playable.GetInputWeight(i);
                if (weight <= 0f || playable.GetPlayState() != PlayState.Playing)
                {
                    continue;
                }

                ScriptPlayable<VowelPlayableBehaviour> input =
                    (ScriptPlayable<VowelPlayableBehaviour>)playable.GetInput(i);
                VowelPlayableBehaviour behaviour = input.GetBehaviour();
                if (behaviour == null || behaviour.sobj == null)
                {
                    continue;
                }

                VowelScriptObject sobj = behaviour.sobj;
                double time = input.GetTime();
                int curFrame = (int)(time * sobj.FrameRate);

                VowelScriptObject.VowelClipInfo current = GetCurrentClipData(sobj, curFrame);
                float currentWeight = 0f;
                AnimationIndex currentIndex = default(AnimationIndex);
                if (current != null)
                {
                    currentWeight = GetNodeWeight(current, time);
                    currentIndex = current.Index;
                }

                VowelScriptObject.VowelClipInfo next = GetNextClipData(sobj, curFrame);
                float nextWeight = 0f;
                AnimationIndex nextIndex = default(AnimationIndex);
                if (next != null)
                {
                    nextWeight = GetNodeWeight(next, time);
                    nextIndex = next.Index;

                    if (currentWeight > 0f && nextWeight > 0f)
                    {
                        float sum = currentWeight + nextWeight;
                        currentWeight = Mathf.Lerp(0f, 1f, currentWeight / sum);
                        nextWeight = Mathf.Lerp(0f, 1f, nextWeight / sum);
                    }
                }

                if (currentWeight > 0f)
                {
                    voiceVowel.SetVowelWeight((Vowel)(currentIndex - 1), currentWeight);
                }
                if (nextWeight > 0f)
                {
                    voiceVowel.SetVowelWeight((Vowel)(nextIndex - 1), nextWeight);
                }
            }
        }

        // RVA: 0x13DEF14
        private float GetNodeWeight(VowelScriptObject.VowelClipInfo node, double time)
        {
            double start = node.Start;
            double easeInEnd = start + node.EaseInDuration;
            if (start <= time && time < easeInEnd)
            {
                return Mathf.Lerp(0f, 1f, (float)((time - start) / node.EaseInDuration));
            }

            double end = start + node.Duration;
            double easeOutStart = end - node.EaseOutDuration;
            if (easeInEnd <= time && time <= easeOutStart)
            {
                return 1f;
            }

            if (time < end && easeOutStart < time)
            {
                return Mathf.Lerp(1f, 0f, (float)((time - easeOutStart) / node.EaseOutDuration));
            }

            return 0f;
        }

        // RVA: 0x13DEE54
        private VowelScriptObject.VowelClipInfo GetCurrentClipData(VowelScriptObject sobj, int curFrame)
        {
            if (sobj.ClipInfoPos.Length <= curFrame)
            {
                return null;
            }

            int index = sobj.ClipInfoPos[curFrame];
            if (index == -1)
            {
                return null;
            }

            if (index >= sobj.ClipInfos.Count)
            {
                return null;
            }
            return sobj.ClipInfos[index];
        }

        // RVA: 0x13DF038
        private VowelScriptObject.VowelClipInfo GetNextClipData(VowelScriptObject sobj, int curFrame)
        {
            if (sobj.ClipInfoPos.Length <= curFrame)
            {
                return null;
            }

            int index = sobj.ClipInfoPos[curFrame];
            if (index == -1)
            {
                return null;
            }

            if (index + 1 >= sobj.ClipInfos.Count)
            {
                return null;
            }
            return sobj.ClipInfos[index + 1];
        }

        // RVA: 0x13DF0FC
        public VowelTrackBehaviour()
        {
        }
    }
}
