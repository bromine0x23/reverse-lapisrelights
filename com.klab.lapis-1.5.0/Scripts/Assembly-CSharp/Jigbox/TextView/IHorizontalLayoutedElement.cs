// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.IHorizontalLayoutedElement
//  来源：Il2CppDumper 元数据
// =============================================================================

namespace Jigbox.TextView
{
    public interface IHorizontalLayoutedElement
    {
        GlyphPlacement GlyphPlacement { get; }
        float OffsetX { get; }
        float OffsetY { get; }
        float TextLineOffsetX { get; set; }
        float TextLineOffsetY { get; set; }
        float JustifyShiftOffsetX { get; set; }
        float xMin { get; }
        float xMax { get; }
        float yMin { get; }
        float yMax { get; }
        float yMinOffsetSpecialAdjusted { get; }
        float yMaxOffsetSpecialAdjusted { get; }
    }
}
