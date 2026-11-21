// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.MotionController
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ctor 由 AssetRef 覆盖表构建 AnimatorOverrideController，
//        同时记录每个 clip 的时长（缺失/非 AnimationClip 记 0）。
// =============================================================================

using System.Collections.Generic;
using System.Linq;
using Oz.GameFramework.Runtime.Resource;
using UnityEngine;

namespace Oz.ActorModule
{
    public class MotionController
    {
        public AnimatorOverrideController OverrideAnimatorController { get; private set; }
        [field: SerializeField]
        public RuntimeAnimatorController RuntimeAnimatorController { get; private set; }
        [field: SerializeField]
        public StringFloatDictionary NameToClipLength { get; private set; }
        [field: SerializeField]
        public StringAnimationClipDictionary OverrideClips { get; private set; }

        // RVA: 0x13F36A8
        public MotionController(
            RuntimeAnimatorController controllerAsset,
            Dictionary<string, AssetRef> overrideClips)
        {
            RuntimeAnimatorController = controllerAsset;
            OverrideAnimatorController = new AnimatorOverrideController(controllerAsset);
            NameToClipLength = new StringFloatDictionary();
            OverrideClips = new StringAnimationClipDictionary();

            if (overrideClips != null)
            {
                foreach (string key in overrideClips.Keys)
                {
                    AnimationClip clip = overrideClips[key].m_Object as AnimationClip;
                    OverrideClips.Add(key, clip);
                    OverrideAnimatorController[key] = clip;

                    if (clip != null)
                    {
                        NameToClipLength[key] = clip.length;
                    }
                    else
                    {
                        NameToClipLength[key] = 0f;
                    }
                }
            }
        }

        // RVA: 0x13F3A48
        public float GetClipLength(string name)
        {
            float value = 0f;
            if (!NameToClipLength.TryGetValue(name, out value))
            {
                return 0f;
            }
            return value;
        }

        // RVA: 0x13F3ACC
        public string[] GetAllStateName()
        {
            List<string> names = new List<string>();
            foreach (KeyValuePair<string, float> pair in NameToClipLength)
            {
                if (pair.Value != 0f)
                {
                    names.Add(pair.Key);
                }
            }
            return names.ToArray();
        }
    }
}
