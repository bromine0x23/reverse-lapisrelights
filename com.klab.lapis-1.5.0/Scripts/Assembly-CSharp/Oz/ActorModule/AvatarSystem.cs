// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.AvatarSystem
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        PutOn: 先 TakeOff(slot) 再 Equip，成功则登记到 slot 字典；
//        slot 为位掩码（TakeOff 用 (part.Slot & slot) >= 1 判定）。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.ActorModule
{
    public class AvatarSystem
    {
        private SkeletonSystem m_SkeletonSystem;
        private AvatarPartList m_InitAvatars;
        private IntAvatarPartDictionary m_EquipedAvatars;

        // RVA: 0x16ADFDC
        public AvatarSystem(SkeletonSystem skeletonSystem, AvatarPart[] avatars)
        {
            m_SkeletonSystem = skeletonSystem;
            m_InitAvatars = new AvatarPartList();
            m_InitAvatars.AddRange(avatars);
            m_EquipedAvatars = new IntAvatarPartDictionary();
        }

        // RVA: 0x16AE0F4
        public void Create()
        {
            for (int i = 0; i < m_InitAvatars.Count; i++)
            {
                PutOn(m_InitAvatars[i]);
            }
        }

        // RVA: 0x16AE270
        public void Destroy()
        {
            m_SkeletonSystem.SetSpringBoneDestory();

            foreach (int slot in m_EquipedAvatars.Keys)
            {
                AvatarPart part;
                if (m_EquipedAvatars.TryGetValue(slot, out part))
                {
                    part.Unequip(m_SkeletonSystem);
                }
            }
            m_EquipedAvatars.Clear();
        }

        // RVA: 0x16B0388
        public AvatarPart[] PutOn(AvatarPart cachedPart)
        {
            if (cachedPart == null)
            {
                return null;
            }

            int slot = cachedPart.Slot;
            AvatarPart[] taken = TakeOff(slot);

            if (cachedPart.Equip(m_SkeletonSystem))
            {
                m_EquipedAvatars.Add(slot, cachedPart);
            }
            return taken;
        }

        // RVA: 0x16B042C
        public AvatarPart[] TakeOff(int slot)
        {
            List<AvatarPart> removed = new List<AvatarPart>();
            foreach (AvatarPart part in m_EquipedAvatars.Values)
            {
                if ((part.Slot & slot) >= 1)
                {
                    removed.Add(part);
                }
            }

            for (int i = 0; i < removed.Count; i++)
            {
                removed[i].Unequip(m_SkeletonSystem);
                m_EquipedAvatars.Remove(removed[i].Slot);
            }

            return removed.ToArray();
        }

        // RVA: 0x16B0628
        public AvatarPart GetAvatarPart(int slot)
        {
            AvatarPart part = null;
            if (m_EquipedAvatars.TryGetValue(slot, out part))
            {
                return part;
            }
            return null;
        }

        // RVA: 0x16B06A8
        public bool IsEquiped(AvatarPart avatarPart)
        {
            foreach (AvatarPart part in m_EquipedAvatars.Values)
            {
                if (part.Equals(avatarPart))
                {
                    return true;
                }
            }
            return false;
        }

        // RVA: 0x16AE3F8
        public void SetMaterialProperty(string name, float value)
        {
            foreach (AvatarPart part in m_EquipedAvatars.Values)
            {
                part.SetMaterialProperty(name, value);
            }
        }

        // RVA: 0x16AE524
        public void SetMaterialProperty(string name, Vector4 value)
        {
            foreach (AvatarPart part in m_EquipedAvatars.Values)
            {
                part.SetMaterialProperty(name, value);
            }
        }

        // RVA: 0x16AE670
        public void SetMaterialProperty(string name, Color value)
        {
            foreach (AvatarPart part in m_EquipedAvatars.Values)
            {
                part.SetMaterialProperty(name, value);
            }
        }

        // RVA: 0x16AE7BC
        public void ClearMaterialPropertyBlock()
        {
            foreach (AvatarPart part in m_EquipedAvatars.Values)
            {
                part.ClearMaterialPropertyBlock();
            }
        }
    }
}
