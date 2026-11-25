// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.InlineImageSizeExtension
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;

namespace Jigbox.TextView
{
    public static class InlineImageSizeExtension
    {
        // RVA: 0x18199B4
        public static int CalculatePixel(this InlineImageSize self, int basicImageSize)
        {
            if (self.PixelValue.HasValue)
            {
                return self.PixelValue.Value;
            }

            float magnification = self.MagnificationValue ?? 1f;
            return Mathf.RoundToInt(magnification * basicImageSize);
        }
    }
}
