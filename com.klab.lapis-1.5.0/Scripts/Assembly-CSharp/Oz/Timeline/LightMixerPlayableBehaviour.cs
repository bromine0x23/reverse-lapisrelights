// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.LightMixerPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: 以输入权重对 intensity / color / rotation 加权求和后写入 Light
//        （playerData 为 Light；behaviour 字段 0x10 intensity、0x14 color、0x24 rotation）
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class LightMixerPlayableBehaviour : PlayableBehaviour
    {
        // RVA: 0x13D9E80
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            base.ProcessFrame(playable, info, playerData);

            Light light = playerData as Light;
            if (light == null)
            {
                return;
            }

            float intensity = 0f;
            Color color = Color.black;
            Vector3 rotation = Vector3.zero;

            int inputCount = playable.GetInputCount();
            for (int i = 0; i < inputCount; i++)
            {
                float weight = playable.GetInputWeight(i);
                if (weight > 0f && playable.GetPlayState() == PlayState.Playing)
                {
                    ScriptPlayable<LightPlayableBehaviour> input =
                        (ScriptPlayable<LightPlayableBehaviour>)playable.GetInput(i);
                    LightPlayableBehaviour behaviour = input.GetBehaviour();
                    if (behaviour != null)
                    {
                        intensity += behaviour.intensity * weight;
                        color += behaviour.color * weight;
                        rotation += behaviour.rotation * weight;
                    }
                }
            }

            light.transform.rotation = Quaternion.Euler(rotation);
            light.intensity = intensity;
            light.color = color;
        }

        // RVA: 0x13DA258
        public LightMixerPlayableBehaviour()
        {
        }
    }
}
