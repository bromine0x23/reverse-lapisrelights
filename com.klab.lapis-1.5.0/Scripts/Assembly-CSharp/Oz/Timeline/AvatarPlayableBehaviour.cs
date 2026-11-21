// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.AvatarPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Equip: Equiped = true，avatarPart 非空时记录 PutOn 产生的冲突部件
//        Unequip: IsEquiped 才 TakeOff，并重新 PutOn 冲突部件
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class AvatarPlayableBehaviour : PlayableBehaviour
    {
        public AvatarPart avatarPart;
        private AvatarPart[] conflictAvatarParts;
        public bool Equiped { get; set; }

        // RVA: 0x13D6690
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            Equiped = false;
        }

        // RVA: 0x13D64D8
        public void Equip(AvatarSystem avatarSystem)
        {
            Equiped = true;
            if (avatarPart != null)
            {
                conflictAvatarParts = avatarSystem.PutOn(avatarPart);
            }
        }

        // RVA: 0x13D61D0
        public void Unequip(AvatarSystem avatarSystem)
        {
            if (avatarPart == null)
            {
                return;
            }

            if (!avatarSystem.IsEquiped(avatarPart))
            {
                return;
            }

            avatarSystem.TakeOff(avatarPart.Slot);

            if (conflictAvatarParts != null)
            {
                for (int i = 0; i < conflictAvatarParts.Length; i++)
                {
                    avatarSystem.PutOn(conflictAvatarParts[i]);
                }
            }
        }

        // RVA: 0x13D6698
        public AvatarPlayableBehaviour()
        {
        }
    }
}
