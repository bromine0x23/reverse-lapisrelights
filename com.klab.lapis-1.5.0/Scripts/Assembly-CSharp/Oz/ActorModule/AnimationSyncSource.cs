// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.AnimationSyncSource
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Awake: RecursiveFindChildrenPath 收集子节点路径 → m_Bones
//        Apply: 对每个 (name, transform) 调 ModelSystem.ApplyBoneTransform
// =============================================================================

using System.Collections.Generic;
using Oz.GameFramework.Runtime;
using UnityEngine;

namespace Oz.ActorModule
{
    public class AnimationSyncSource : MonoBehaviour
    {
        private List<KeyValuePair<string, Transform>> m_Bones;

        // RVA: 0x16AF2B8
        private void Awake()
        {
            m_Bones = new List<KeyValuePair<string, Transform>>();

            Dictionary<string, Transform> children = new Dictionary<string, Transform>();
            TransformExtentions.RecursiveFindChildrenPath(transform, children);

            foreach (KeyValuePair<string, Transform> bone in children)
            {
                m_Bones.Add(bone);
            }
        }

        // RVA: 0x16AF430
        public void Apply(ModelSystem modelSystem)
        {
            for (int i = 0; i < m_Bones.Count; i++)
            {
                modelSystem.ApplyBoneTransform(m_Bones[i].Key, m_Bones[i].Value);
            }
        }

        // RVA: 0x16AF4E4
        public AnimationSyncSource()
        {
        }
    }
}
