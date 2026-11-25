// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.SubRenderingFontElement
//  来源：Il2CppDumper 元数据（签名精确）
//  说明：注解（ruby）子元素的数据载体，全部为自动属性。
// =============================================================================

namespace Jigbox.TextView
{
    public class SubRenderingFontElement
    {
        public Glyph Glyph { get; protected set; } // 0x10
        public float Width { get; protected set; } // 0x18
        public float OffsetX { get; protected set; } // 0x1C
        public float OffsetY { get; protected set; } // 0x20

        // RVA: 0x1684FF4
        public SubRenderingFontElement(Glyph glyph, float width, float offsetX, float offsetY)
        {
            Glyph = glyph;
            Width = width;
            OffsetX = offsetX;
            OffsetY = offsetY;
        }
    }
}
