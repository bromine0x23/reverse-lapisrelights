// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.AvatarPart
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Create 由 Prefab 实例化 Model；Destroy 解除父子关系后销毁；
//        SetMaterialProperty 对每个 Renderer 走 GetPropertyBlock→Set→SetPropertyBlock。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.ActorModule
{
    public class AvatarPart
    {
        [SerializeField]
        protected StringTransformDictionary m_Bones;
        [SerializeField]
        protected StringSpringBoneDictionary m_DictSpringBones;
        [SerializeField]
        protected StringSpringColliderDictionary m_DictSpringColliders;
        [SerializeField]
        protected List<Renderer> m_Renderers;
        [field: SerializeField]
        public GameObject Prefab { get; private set; }
        [field: SerializeField]
        public SpringSetting SpringSetting { get; private set; }
        [field: SerializeField]
        public HeelSetting HeelSetting { get; private set; }
        [field: SerializeField]
        public int Slot { get; private set; }
        [field: SerializeField]
        public GameObject Model { get; private set; }
        [field: SerializeField]
        public MaterialPropertyBlock MaterialPropertyBlock { get; private set; }

        // RVA: 0x16AFBB4
        public static AvatarPart Build(AvatarSetting avatarSetting, bool needBonesAdjust = false)
        {
            if (avatarSetting.m_Type == eAvatarType.Skinning)
            {
                return new SkinningAvatarPart(
                    avatarSetting.Slot,
                    avatarSetting.Prefab,
                    avatarSetting.SpringSetting,
                    avatarSetting.HeelSetting,
                    avatarSetting.m_RebindAnimator,
                    needBonesAdjust);
            }

            if (avatarSetting.m_Type != eAvatarType.Attach)
            {
                return null;
            }

            return new AttachableAvatarPart(
                avatarSetting.Slot, avatarSetting.Prefab, avatarSetting.m_Dummy);
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
            if (MaterialPropertyBlock == null)
            {
                MaterialPropertyBlock = new MaterialPropertyBlock();
            }
            return MaterialPropertyBlock;
        }

        // RVA: 0x16AF51C
        public AvatarPart(int slot, GameObject prefab, SpringSetting springSetting, HeelSetting heelSetting)
        {
            Prefab = prefab;
            Slot = slot;
            MaterialPropertyBlock = new MaterialPropertyBlock();
            m_Bones = new StringTransformDictionary();
            m_Renderers = new List<Renderer>();
            SpringSetting = springSetting;
            HeelSetting = heelSetting;
        }

        // RVA: 0x16AF884
        protected bool Create()
        {
            if (Prefab != null)
            {
                Model = Object.Instantiate(Prefab);
            }
            return Model != null;
        }

        // RVA: 0x16AF9E0
        protected void Destroy()
        {
            if (Model != null)
            {
                Model.transform.SetParent(null);
                Object.Destroy(Model);
                Model = null;
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
