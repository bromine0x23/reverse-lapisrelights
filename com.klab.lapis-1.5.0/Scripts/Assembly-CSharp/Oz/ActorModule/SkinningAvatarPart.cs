// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.SkinningAvatarPart
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Equip: Create → SkeletonSystem.Merge → 逐 SkinnedMeshRenderer 处理
//        （名称含 BREAST_GEO 时 ApplyBreastScale）→ Destroy → 弹簧/脚跟设置
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.ActorModule
{
    public class SkinningAvatarPart : AvatarPart
    {
        private bool m_NeedBonesAdjust;
        private bool m_RebindAnimator;

        // RVA: 0x13F6A0C
        public SkinningAvatarPart(
            int slot,
            GameObject prefab,
            SpringSetting springSetting,
            HeelSetting heelSetting,
            bool rebindAnimator,
            bool needBonesAdjust = false)
            : base(slot, prefab, springSetting, heelSetting)
        {
            m_NeedBonesAdjust = needBonesAdjust;
            m_RebindAnimator = rebindAnimator;
        }

        // RVA: 0x13F6A50
        public override bool Equip(SkeletonSystem skeletonSystem)
        {
            bool created = Create();
            if (skeletonSystem == null || !created)
            {
                return false;
            }

            skeletonSystem.Merge(m_Model, m_Bones, m_Renderers, m_RebindAnimator);

            for (int i = 0; i < m_Renderers.Count; i++)
            {
                SkinnedMeshRenderer smr = m_Renderers[i] as SkinnedMeshRenderer;
                if (smr != null)
                {
                    if (smr.name.ToUpper().Contains("BREAST_GEO"))
                    {
                        skeletonSystem.ApplyBreastScale(smr);
                    }
                    skeletonSystem.SetupSkinningMeshRenderer(smr);
                }
            }

            Destroy();

            if (m_SpringSetting != null)
            {
                skeletonSystem.SetupSpringParameter(
                    m_SpringSetting, ref m_DictSpringBones, ref m_DictSpringColliders, false);
            }

            if (m_HeelSetting != null)
            {
                skeletonSystem.ApplyHeelSetting(m_HeelSetting.tweakFootAngle, m_HeelSetting.tweakFootHeight);
            }

            return true;
        }

        // RVA: 0x13F6C8C
        public override void Unequip(SkeletonSystem skeletonSystem)
        {
            skeletonSystem.ClearSpringParameter(m_DictSpringBones, m_DictSpringColliders);

            foreach (Renderer renderer in m_Renderers)
            {
                renderer.transform.SetParent(null);
                Object.Destroy(renderer.gameObject);
            }
            m_Renderers.Clear();

            skeletonSystem.SetSrpingBoneEnabled(false);

            foreach (string bonePath in m_Bones.Keys)
            {
                skeletonSystem.DestroyExtraBone(bonePath);
            }
            m_Bones.Clear();

            skeletonSystem.SetSrpingBoneEnabled(true);
        }

        // RVA: 0x13F6F04
        public override void SetVisible(bool visible)
        {
            foreach (Renderer renderer in m_Renderers)
            {
                renderer.enabled = visible;
            }
        }
    }
}
