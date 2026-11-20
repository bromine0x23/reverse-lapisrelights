// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.BlendParts
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ctor 为每个 handle 建 BlendWeight(handle, 0)；
//        SetShapeWeight 按 ShapeName 匹配后写入 Weight
// =============================================================================

namespace Oz.ActorModule
{
    public class BlendParts
    {
        public eFacialParts Part;
        public BlendWeight[] BlendWeightList;

        // RVA: 0x16B076C
        public BlendParts(eFacialParts part, BlendShapeHandle[] handles)
        {
            Part = part;
            BlendWeightList = new BlendWeight[handles.Length];
            for (int i = 0; i < BlendWeightList.Length; i++)
            {
                BlendWeightList[i] = new BlendWeight(handles[i], 0f);
            }
        }

        // RVA: 0x16B08D4
        public void SetShapeWeight(string shape, float weight)
        {
            if (string.IsNullOrEmpty(shape))
            {
                return;
            }

            for (int i = 0; i < BlendWeightList.Length; i++)
            {
                if (BlendWeightList[i].Handle.ShapeName == shape)
                {
                    BlendWeightList[i].Weight = weight;
                }
            }
        }
    }
}
