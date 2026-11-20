// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.AvatarPart
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Create 由 m_Prefab 实例化 m_Model；Destroy 解除父子关系后销毁；
//        SetMaterialProperty 对每个 Renderer 走 GetPropertyBlock→Set→SetPropertyBlock。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.ActorModule
{
    public class AvatarPart
    {
        [SerializeField]
        private GameObject m_Prefab;
        [SerializeField]
        protected SpringSetting m_SpringSetting;
        [SerializeField]
        protected HeelSetting m_HeelSetting;
        [SerializeField]
        protected StringTransformDictionary m_Bones;
        [SerializeField]
        protected StringSpringBoneDictionary m_DictSpringBones;
        [SerializeField]
        protected StringSpringColliderDictionary m_DictSpringColliders;
        [SerializeField]
        protected List<Renderer> m_Renderers;
        [SerializeField]
        private int m_Slot;
        [SerializeField]
        protected GameObject m_Model;
        [SerializeField]
        private MaterialPropertyBlock m_MaterialPropertyBlock;
        public GameObject Prefab { get; }
        public SpringSetting SpringSetting { get; }
        public HeelSetting HeelSetting { get; }
        public int Slot { get; }
        public GameObject Model { get; }
        public MaterialPropertyBlock MaterialPropertyBlock { get; }

        // RVA: 0x16AFBB4
        public static AvatarPart Build(AvatarSetting avatarSetting, bool needBonesAdjust = false)
        {
            if (avatarSetting.m_Type == eAvatarType.Skinning)
            {
                return new SkinningAvatarPart(
                    avatarSetting.m_Slot,
                    avatarSetting.m_Prefab,
                    avatarSetting.m_SpringSetting,
                    avatarSetting.m_HeelSetting,
                    avatarSetting.m_RebindAnimator,
                    needBonesAdjust);
            }

            if (avatarSetting.m_Type != eAvatarType.Attach)
            {
                return null;
            }

            return new AttachableAvatarPart(
                avatarSetting.m_Slot, avatarSetting.m_Prefab, avatarSetting.m_Dummy);
        }

        // RVA: 0x16AFCB4
        public GameObject get_Prefab()
        {
            return m_Prefab;
        }

        // RVA: 0x16AFCBC
        public SpringSetting get_SpringSetting()
        {
            return m_SpringSetting;
        }

        // RVA: 0x16AFCC4
        public HeelSetting get_HeelSetting()
        {
            return m_HeelSetting;
        }

        // RVA: 0x16AFCCC
        public int get_Slot()
        {
            return m_Slot;
        }

        // RVA: 0x16AFCD4
        public GameObject get_Model()
        {
            return m_Model;
        }

        // RVA: 0x16AFCDC
        public Renderer FindRenderer(System.Predicate<Renderer> match)
        {
            for (int i = 0; i < m_Renderers.Count; i++)
            {
                if (match(m_Renderers[i]))
                {
                    return m_Renderers[i];
                }
            }
            return null;
        }

        // RVA: 0x16AFDA0
        public MaterialPropertyBlock get_MaterialPropertyBlock()
        {
            if (m_MaterialPropertyBlock == null)
            {
                m_MaterialPropertyBlock = new MaterialPropertyBlock();
            }
            return m_MaterialPropertyBlock;
        }

        // RVA: 0x16AF51C
        public AvatarPart(int slot, GameObject prefab, SpringSetting springSetting, HeelSetting heelSetting)
        {
            m_Prefab = prefab;
            m_Slot = slot;
            m_MaterialPropertyBlock = new MaterialPropertyBlock();
            m_Bones = new StringTransformDictionary();
            m_Renderers = new List<Renderer>();
            m_SpringSetting = springSetting;
            m_HeelSetting = heelSetting;
        }

        // RVA: 0x16AF884
        protected bool Create()
        {
            if (m_Prefab != null)
            {
                m_Model = Object.Instantiate(m_Prefab);
            }
            return m_Model != null;
        }

        // RVA: 0x16AF9E0
        protected void Destroy()
        {
            if (m_Model != null)
            {
                m_Model.transform.SetParent(null);
                Object.Destroy(m_Model);
                m_Model = null;
            }
        }

        // RVA: 0x16AFE0C
        public virtual bool Equip(SkeletonSystem skeletionSystem)
        {
            return false;
        }

        // RVA: 0x16AFE14
        public virtual void Unequip(SkeletonSystem skeletionSystem)
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x16AFE18
        public virtual void SetVisible(bool visible)
        {
            // 空实现（伪代码仅有 return）
        }

        // RVA: 0x16AFE1C
        public virtual Transform GetBone(string path)
        {
            Transform bone = null;
            if (m_Bones.TryGetValue(path, out bone))
            {
                return bone;
            }
            return null;
        }

        // RVA: 0x16AFE9C
        public void SetMaterialProperty(string name, float value)
        {
            for (int i = 0; i < m_Renderers.Count; i++)
            {
                Renderer renderer = m_Renderers[i];
                if (renderer != null)
                {
                    renderer.GetPropertyBlock(MaterialPropertyBlock);
                    MaterialPropertyBlock.SetFloat(name, value);
                    renderer.SetPropertyBlock(MaterialPropertyBlock);
                }
            }
        }

        // RVA: 0x16AFFC8
        public void SetMaterialProperty(string name, Vector4 value)
        {
            for (int i = 0; i < m_Renderers.Count; i++)
            {
                Renderer renderer = m_Renderers[i];
                if (renderer != null)
                {
                    renderer.GetPropertyBlock(MaterialPropertyBlock);
                    MaterialPropertyBlock.SetVector(name, value);
                    renderer.SetPropertyBlock(MaterialPropertyBlock);
                }
            }
        }

        // RVA: 0x16B0114
        public void SetMaterialProperty(string name, Color value)
        {
            for (int i = 0; i < m_Renderers.Count; i++)
            {
                Renderer renderer = m_Renderers[i];
                if (renderer != null)
                {
                    renderer.GetPropertyBlock(MaterialPropertyBlock);
                    MaterialPropertyBlock.SetColor(name, value);
                    renderer.SetPropertyBlock(MaterialPropertyBlock);
                }
            }
        }

        // RVA: 0x16B0260
        public void ClearMaterialPropertyBlock()
        {
            for (int i = 0; i < m_Renderers.Count; i++)
            {
                Renderer renderer = m_Renderers[i];
                if (renderer != null)
                {
                    renderer.SetPropertyBlock(null);
                }
            }
        }
    }
}
