// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ThaiFontGlyphSpec
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（构造）
//  说明：Thai 字形偏移按 BaseLayoutSize 归一化后放大到当前字号。
// =============================================================================

using UnityEngine;

namespace Jigbox.TextView
{
    public class ThaiFontGlyphSpec : FontGlyphSpec
    {
        public int OffsetX { get; private set; } // 0x44
        public int OffsetY { get; private set; } // 0x48

        // RVA: 0x16888E4
        public ThaiFontGlyphSpec(char character, Font font, int size, FontStyle style, Color? color, float glyphScaleX, int offsetX, int offsetY)
            : base(character, font, size, style, color, glyphScaleX)
        {
            float ratio = (float)size / ThaiUtils.Layout.ThaiLayoutGenerator.BaseLayoutSize;
            OffsetX = Mathf.RoundToInt(ratio * offsetX * glyphScaleX);
            OffsetY = Mathf.RoundToInt(ratio * offsetY);
        }
    }
}
