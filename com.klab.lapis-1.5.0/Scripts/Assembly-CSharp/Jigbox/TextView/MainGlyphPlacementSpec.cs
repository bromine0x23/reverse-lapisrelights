// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.MainGlyphPlacementSpec
//  来源：Il2CppDumper 元数据（签名精确）
//  说明：全部为 [CompilerGenerated] 自动属性，setter 为 private。
// =============================================================================

namespace Jigbox.TextView
{
    public class MainGlyphPlacementSpec
    {
        public IGlyphSpec GlyphSpec { get; private set; }   // 0x10
        public int MarginLeft { get; private set; }         // 0x18
        public int MarginRight { get; private set; }        // 0x1C
        public int OffsetY { get; private set; }            // 0x20
        public float BaseSpacing { get; private set; }      // 0x24
        public int Index { get; private set; }              // 0x28

        // RVA: 0x181E304
        public MainGlyphPlacementSpec(IGlyphSpec glyphSpec, int marginLeft, int marginRight, int offsetY, int index, float baseSpacing)
        {
            GlyphSpec = glyphSpec;
            MarginLeft = marginLeft;
            MarginRight = marginRight;
            OffsetY = offsetY;
            Index = index;
            BaseSpacing = baseSpacing;
        }
    }
}
