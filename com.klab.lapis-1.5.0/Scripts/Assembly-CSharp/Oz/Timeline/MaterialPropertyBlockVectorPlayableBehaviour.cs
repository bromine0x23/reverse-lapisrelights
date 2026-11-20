// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialPropertyBlockVectorPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: modifier.SetMaterialProperty(propertyName, value)  // Vector4 重载（Slot 1）
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class MaterialPropertyBlockVectorPlayableBehaviour : MaterialPropertyBlockPlayableBehaviour
    {
        public string propertyName;
        public Vector4 value;

        // RVA: 0x13DB8E8
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (modifier != null)
            {
                modifier.SetMaterialProperty(propertyName, value);
            }
        }

        // RVA: 0x13DB9E8
        public MaterialPropertyBlockVectorPlayableBehaviour()
        {
        }
    }
}
