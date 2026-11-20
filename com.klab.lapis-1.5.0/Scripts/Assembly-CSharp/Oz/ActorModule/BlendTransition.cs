// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.BlendTransition
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ctor 逐字段赋值；GetWeight = Mathf.Lerp(StartWeight, EndWeight, lerpWeight)
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public struct BlendTransition
    {
        public BlendShapeHandle Handle;
        public float StartWeight;
        public float EndWeight;

        // RVA: 0x16B09D8
        public BlendTransition(BlendShapeHandle handle, float startWeight, float endWeight)
        {
            Handle = handle;
            StartWeight = startWeight;
            EndWeight = endWeight;
        }

        // RVA: 0x16B09E4
        public float GetWeight(float lerpWeight)
        {
            return Mathf.Lerp(StartWeight, EndWeight, lerpWeight);
        }
    }
}
