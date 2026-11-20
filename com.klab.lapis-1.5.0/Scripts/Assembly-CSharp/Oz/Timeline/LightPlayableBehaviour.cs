// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.LightPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        默认值：intensity = 1、color = white、rotation = Quaternion.identity.eulerAngles
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class LightPlayableBehaviour : PlayableBehaviour
    {
        public float intensity;
        public Color color;
        public Vector3 rotation;

        // RVA: 0x13DA310
        public LightPlayableBehaviour()
        {
            intensity = 1f;
            color = Color.white;
            rotation = Quaternion.identity.eulerAngles;
        }
    }
}
