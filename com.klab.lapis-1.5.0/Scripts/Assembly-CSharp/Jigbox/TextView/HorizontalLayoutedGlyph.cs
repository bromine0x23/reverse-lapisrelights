// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.HorizontalLayoutedGlyph
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  已还原：字段、自动属性、OffsetX/OffsetY、构造。
//  未还原（当前抛 NotImplementedException）：xMin(0x1816358)/xMax(0x1816428)/
//  yMin(0x18164F8)/yMax(0x18165C0)/yMinOffsetSpecialAdjusted(0x1816688)/
//  yMaxOffsetSpecialAdjusted(0x181668C)/GetVertices(0x18166BC)/GetMirrorVertices(0x18167AC)。
// =============================================================================

using System;
using UnityEngine;
using UnityEngine.UI;

namespace Jigbox.TextView
{
    public class HorizontalLayoutedGlyph : IHorizontalLayoutedElement
    {
        public GlyphPlacement GlyphPlacement { get; protected set; } // 0x10
        public float TextLineOffsetX { get; set; }                   // 0x18
        public float TextLineOffsetY { get; set; }                   // 0x1C
        public float JustifyShiftOffsetX { get; set; }               // 0x20

        public float OffsetX
        {
            // RVA: 0x1816310
            get { return TextLineOffsetX + JustifyShiftOffsetX; }
        }

        public float OffsetY
        {
            // RVA: 0x1816320
            get { return TextLineOffsetY; }
        }

        public float xMin
        {
            // RVA: 0x1816358
            get { return GlyphPlacement.Glyph.xMin + TextLineOffsetX + JustifyShiftOffsetX; }
        }

        public float xMax
        {
            // RVA: 0x1816428
            get { return GlyphPlacement.Glyph.xMax + TextLineOffsetX + JustifyShiftOffsetX; }
        }

        public float yMin
        {
            // RVA: 0x18164F8
            get { return GlyphPlacement.Glyph.yMin + TextLineOffsetY; }
        }

        public float yMax
        {
            // RVA: 0x18165C0
            get { return GlyphPlacement.Glyph.yMax + TextLineOffsetY; }
        }

        public float yMinOffsetSpecialAdjusted
        {
            // RVA: 0x1816688
            get { return yMin; }
        }

        public float yMaxOffsetSpecialAdjusted
        {
            // RVA: 0x181668C
            get { return yMax; }
        }

        // RVA: 0x1816690
        public HorizontalLayoutedGlyph(GlyphPlacement glyphPlacement)
        {
            GlyphPlacement = glyphPlacement;
        }

        // RVA: 0x18166BC
        public void GetVertices(ref UIVertex[] vertices, float offsetY, Color color)
        {
            throw new NotImplementedException("HorizontalLayoutedGlyph.GetVertices 尚未还原");
        }

        // RVA: 0x18167AC
        public void GetMirrorVertices(ref UIVertex[] vertices, float offsetY, Color color, float mirrorOffsetX)
        {
            throw new NotImplementedException("HorizontalLayoutedGlyph.GetMirrorVertices 尚未还原");
        }
    }
}
