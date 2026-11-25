// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ImageGlyphSpec
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（构造）
// =============================================================================

namespace Jigbox.TextView
{
    public class ImageGlyphSpec : IGlyphSpec
    {
        public readonly string Source;                  // 0x10
        public readonly string Name;                    // 0x18
        public readonly InlineImageSize Width;          // 0x20
        public readonly InlineImageSize Height;         // 0x28
        public readonly FontGlyphSpec SizeBaseGlyphSpec; // 0x30

        // RVA: 0x1816EC8
        public ImageGlyphSpec(InlineImage inlineImage, FontGlyphSpec sizeBaseGlyphSpec)
        {
            Source = inlineImage.Source;
            Name = inlineImage.Name;
            Width = inlineImage.Width;
            Height = inlineImage.Height;
            SizeBaseGlyphSpec = sizeBaseGlyphSpec;
        }
    }
}
