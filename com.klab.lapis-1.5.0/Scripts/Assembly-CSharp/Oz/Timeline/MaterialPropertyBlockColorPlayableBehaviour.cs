// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialPropertyBlockColorPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: modifier.SetMaterialProperty(propertyName, value)  // Color 重载（Slot 2）
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class MaterialPropertyBlockColorPlayableBehaviour : MaterialPropertyBlockPlayableBehaviour
    {
        public string propertyName;
        public Color value;

        // RVA: 0x13DAE94
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (modifier != null)
            {
                modifier.SetMaterialProperty(propertyName, value);
            }
        }

        // RVA: 0x13DAF94
        public MaterialPropertyBlockColorPlayableBehaviour()
        {
        }
    }
}
