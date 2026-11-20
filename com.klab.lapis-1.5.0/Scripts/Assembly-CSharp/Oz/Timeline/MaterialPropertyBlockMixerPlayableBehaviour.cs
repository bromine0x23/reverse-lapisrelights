// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialPropertyBlockMixerPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        OnPlayableDestroy / ProcessFrame: 无激活片段时 ClearMaterialPropertyBlock()
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class MaterialPropertyBlockMixerPlayableBehaviour : PlayableBehaviour
    {
        public IMaterialPropertyBlockModifier modifier;

        // RVA: 0x13DB17C
        public override void OnPlayableDestroy(Playable playable)
        {
            if (modifier != null)
            {
                modifier.ClearMaterialPropertyBlock();
            }
        }

        // RVA: 0x13DB238
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (playable.GetInputCount() >= 1)
            {
                for (int i = 0; i < playable.GetInputCount(); i++)
                {
                    // 有片段正在播放时由其自身的 Behaviour 写入属性，Mixer 不清理
                    if (playable.GetInputWeight(i) > 0f && playable.GetPlayState() == PlayState.Playing)
                    {
                        return;
                    }
                }
            }

            if (modifier != null)
            {
                modifier.ClearMaterialPropertyBlock();
            }
        }

        // RVA: 0x13DB3B4
        public MaterialPropertyBlockMixerPlayableBehaviour()
        {
        }
    }
}
