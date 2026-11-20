// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.AttachableAvatarPart
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Equip: Create → GetBone(m_DummyNodeName) → 收集子节点路径 →
//        挂到 dummy（local 位置/旋转/缩放归零）→ 收集 Renderer
// =============================================================================

using System.Collections.Generic;
using Oz.GameFramework.Runtime;
using UnityEngine;

namespace Oz.ActorModule
{
    public class AttachableAvatarPart : AvatarPart
    {
        private string m_DummyNodeName;

        // RVA: 0x16AF4EC
        public AttachableAvatarPart(int slot, GameObject prefab, string dummyNodeName)
            : base(slot, prefab, null, null)
        {
            m_DummyNodeName = dummyNodeName;
        }

        // RVA: 0x16AF5FC
        public override bool Equip(SkeletonSystem skeletonSystem)
        {
            bool created = Create();
            if (skeletonSystem == null || !created)
            {
                return false;
            }

            Transform dummy = skeletonSystem.GetBone(m_DummyNodeName);
            if (dummy == null)
            {
                return false;
            }

            TransformExtentions.RecursiveFindChildrenPath(m_Model.transform, m_Bones);

            m_Model.transform.SetParent(dummy, false);
            m_Model.transform.localPosition = Vector3.zero;
            m_Model.transform.localRotation = Quaternion.identity;
            m_Model.transform.localScale = Vector3.one;

            foreach (Renderer renderer in m_Model.GetComponentsInChildren<Renderer>())
            {
                if (renderer != null)
                {
                    m_Renderers.Add(renderer);
                }
            }

            return true;
        }

        // RVA: 0x16AF968
        public override void Unequip(SkeletonSystem skeletonSystem)
        {
            Destroy();
            m_Renderers.Clear();
            m_Bones.Clear();
        }

        // RVA: 0x16AFAB0
        public override void SetVisible(bool visible)
        {
            foreach (Renderer renderer in m_Model.GetComponentsInChildren<Renderer>())
            {
                if (renderer != null)
                {
                    renderer.enabled = visible;
                }
            }
        }
    }
}
