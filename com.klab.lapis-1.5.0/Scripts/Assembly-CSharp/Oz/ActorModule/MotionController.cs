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
        [SerializeField]
        private RuntimeAnimatorController m_RuntimeAnimatorController;
        [SerializeField]
        private StringFloatDictionary m_NameToClipLength;
        [SerializeField]
        private StringAnimationClipDictionary m_OverrideClips;
        public AnimatorOverrideController OverrideAnimatorController { get; set; }
        public RuntimeAnimatorController RuntimeAnimatorController { get; }
        public StringFloatDictionary NameToClipLength { get; }
        public StringAnimationClipDictionary OverrideClips { get; set; }

        // RVA: 0x13F3678
        public AnimatorOverrideController get_OverrideAnimatorController()
        {
            return OverrideAnimatorController;
        }

        // RVA: 0x13F3680
        private void set_OverrideAnimatorController(AnimatorOverrideController value)
        {
            OverrideAnimatorController = value;
        }

        // RVA: 0x13F3688
        public RuntimeAnimatorController get_RuntimeAnimatorController()
        {
            return m_RuntimeAnimatorController;
        }

        // RVA: 0x13F3690
        public StringFloatDictionary get_NameToClipLength()
        {
            return m_NameToClipLength;
        }

        // RVA: 0x13F3698
        public StringAnimationClipDictionary get_OverrideClips()
        {
            return m_OverrideClips;
        }

        // RVA: 0x13F36A0
        private void set_OverrideClips(StringAnimationClipDictionary value)
        {
            m_OverrideClips = value;
        }

        // RVA: 0x13F36A8
        public MotionController(
            RuntimeAnimatorController controllerAsset,
            Dictionary<string, AssetRef> overrideClips)
        {
            m_RuntimeAnimatorController = controllerAsset;
            OverrideAnimatorController = new AnimatorOverrideController(controllerAsset);
            m_NameToClipLength = new StringFloatDictionary();
            m_OverrideClips = new StringAnimationClipDictionary();

            if (overrideClips != null)
            {
                foreach (string key in overrideClips.Keys)
                {
                    AnimationClip clip = overrideClips[key].m_Object as AnimationClip;
                    m_OverrideClips.Add(key, clip);
                    OverrideAnimatorController[key] = clip;

                    if (clip != null)
                    {
                        m_NameToClipLength[key] = clip.length;
                    }
                    else
                    {
                        m_NameToClipLength[key] = 0f;
                    }
                }
            }
        }

        // RVA: 0x13F3A48
        public float GetClipLength(string name)
        {
            float value = 0f;
            if (!m_NameToClipLength.TryGetValue(name, out value))
            {
                return 0f;
            }
            return value;
        }

        // RVA: 0x13F3ACC
        public string[] GetAllStateName()
        {
            List<string> names = new List<string>();
            foreach (KeyValuePair<string, float> pair in m_NameToClipLength)
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
