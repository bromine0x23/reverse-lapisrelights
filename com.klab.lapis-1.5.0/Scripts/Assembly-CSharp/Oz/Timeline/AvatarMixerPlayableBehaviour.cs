// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.AvatarMixerPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: 首个权重>0 且 Playing 的输入独占换装，切换时 Unequip 旧片段；
//        无激活片段则 Unequip lastBehaviour
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class AvatarMixerPlayableBehaviour : PlayableBehaviour
    {
        public AvatarSystem avatarSystem;
        private AvatarPlayableBehaviour lastBehaviour;

        // RVA: 0x13D6194
        public override void OnGraphStop(Playable playable)
        {
            base.OnGraphStop(playable);
            if (lastBehaviour != null && avatarSystem != null)
            {
                lastBehaviour.Unequip(avatarSystem);
                lastBehaviour = null;
            }
        }

        // RVA: 0x13D6280
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (avatarSystem == null)
            {
                Actor actor = playerData as Actor;
                if (actor == null)
                {
                    return;
                }
                avatarSystem = actor.AvatarSystem;
                if (avatarSystem == null)
                {
                    return;
                }
            }

            int inputCount = playable.GetInputCount();
            for (int i = 0; i < inputCount; i++)
            {
                if (playable.GetInputWeight(i) > 0f && playable.GetPlayState() == PlayState.Playing)
                {
                    ScriptPlayable<AvatarPlayableBehaviour> input =
                        (ScriptPlayable<AvatarPlayableBehaviour>)playable.GetInput(i);
                    AvatarPlayableBehaviour behaviour = input.GetBehaviour();
                    if (!behaviour.Equiped)
                    {
                        if (lastBehaviour != null && lastBehaviour != behaviour)
                        {
                            lastBehaviour.Unequip(avatarSystem);
                        }
                        behaviour.Equip(avatarSystem);
                        lastBehaviour = behaviour;
                    }
                    return;
                }
            }

            if (lastBehaviour != null)
            {
                lastBehaviour.Unequip(avatarSystem);
                lastBehaviour = null;
            }
        }

        // RVA: 0x13D6520
        public AvatarMixerPlayableBehaviour()
        {
        }
    }
}
