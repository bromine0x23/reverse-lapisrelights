// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.InlineImageSize
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView
{
    public class InlineImageSize
    {
        private int? pixelValue;            // 0x10
        private float? magnificationValue;  // 0x18

        public int? PixelValue
        {
            // RVA: 0x181984C
            get { return pixelValue; }
        }

        public float? MagnificationValue
        {
            // RVA: 0x1819854
            get { return magnificationValue; }
        }

        // RVA: 0x181985C
        public InlineImageSize(int value)
        {
            pixelValue = value;
            magnificationValue = null;
        }

        // RVA: 0x18198D8
        public InlineImageSize(float value)
        {
            pixelValue = null;
            magnificationValue = value;
        }

        // RVA: 0x1819958
        public static InlineImageSize CreateByDefaultMagnificationValue()
        {
            return new InlineImageSize(1f);
        }
    }
}
