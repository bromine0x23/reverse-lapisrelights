// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialPropertyBlockFloatPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: modifier.SetMaterialProperty(propertyName, value)  // float 重载（Slot 0）
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class MaterialPropertyBlockFloatPlayableBehaviour : MaterialPropertyBlockPlayableBehaviour
    {
        public string propertyName;
        public float value;

        // RVA: 0x13DB094
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (modifier != null)
            {
                modifier.SetMaterialProperty(propertyName, value);
            }
        }

        // RVA: 0x13DB174
        public MaterialPropertyBlockFloatPlayableBehaviour()
        {
        }
    }
}
