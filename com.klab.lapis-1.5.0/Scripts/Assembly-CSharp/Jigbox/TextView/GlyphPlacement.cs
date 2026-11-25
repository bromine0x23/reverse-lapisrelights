// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.GlyphPlacement
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;
using System.Linq;

namespace Jigbox.TextView
{
    public class GlyphPlacement
    {
        protected static readonly IEnumerable<GlyphPlacement> EmptySubGlyphPlacements =
            Enumerable.Empty<GlyphPlacement>();

        public IGlyph Glyph { get; set; }
        public float X { get; set; }
        public float Y { get; set; }
        public int Index { get; set; }
        public readonly bool IsMainGlyph;
        protected IEnumerable<GlyphPlacement> subGlyphPlacements;
        public float JustifyShiftOffsetX { get; set; }

        public IEnumerable<GlyphPlacement> SubGlyphPlacements
        {
            // RVA: 0x1812EF8
            get { return subGlyphPlacements ?? EmptySubGlyphPlacements; }
        }

        // RVA: 0x1812F7C
        public GlyphPlacement(
            IGlyph glyph,
            float x,
            float y,
            int index,
            bool isMainGlyph,
            IEnumerable<GlyphPlacement> subGlyphPlacements)
        {
            this.Glyph = glyph;
            this.X = x;
            this.Y = y;
            this.Index = index;
            this.IsMainGlyph = isMainGlyph;
            this.subGlyphPlacements = subGlyphPlacements;
        }

        // RVA: 0x1812FE8
        public override string ToString()
        {
            return string.Format(
                "GlyphPlacement(Glyph: {0}, X: {1}, Y: {2}, Index: {3})",
                Glyph,
                X,
                Y,
                Index);
        }
    }
}
