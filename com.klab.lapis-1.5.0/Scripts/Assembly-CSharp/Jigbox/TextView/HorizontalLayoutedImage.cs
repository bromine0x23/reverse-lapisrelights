// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.HorizontalLayoutedImage
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  已还原：字段、自动属性、OffsetX/OffsetY、构造。
//  未还原（当前抛 NotImplementedException）：xMin(0x18168FC)/xMax(0x18169CC)/
//  yMin(0x1816A9C)/yMax(0x1816B70)/yMinOffsetSpecialAdjusted(0x1816C44)/
//  OffsetYSpecialAdjusted(0x1816D20)/yMaxOffsetSpecialAdjusted(0x1816D3C)。
// =============================================================================

using System;
using UnityEngine;

namespace Jigbox.TextView
{
    public class HorizontalLayoutedImage : IHorizontalLayoutedElement
    {
        public GlyphPlacement GlyphPlacement { get; protected set; } // 0x10
        public readonly int ImageOffsetY;                            // 0x18
        public float TextLineOffsetX { get; set; }                   // 0x1C
        public float TextLineOffsetY { get; set; }                   // 0x20
        public float JustifyShiftOffsetX { get; set; }               // 0x24

        public float OffsetX
        {
            // RVA: 0x18168B4
            get { return TextLineOffsetX + JustifyShiftOffsetX; }
        }

        public float OffsetY
        {
            // RVA: 0x18168C4
            get { return TextLineOffsetY; }
        }

        public float xMin
        {
            // RVA: 0x18168FC
            get { return GlyphPlacement.Glyph.xMin + TextLineOffsetX + JustifyShiftOffsetX; }
        }

        public float xMax
        {
            // RVA: 0x18169CC
            get { return GlyphPlacement.Glyph.xMax + TextLineOffsetX + JustifyShiftOffsetX; }
        }

        public float yMin
        {
            // RVA: 0x1816A9C
            get { return GlyphPlacement.Glyph.yMin + TextLineOffsetY - ImageOffsetY; }
        }

        public float yMax
        {
            // RVA: 0x1816B70
            get { return GlyphPlacement.Glyph.yMax + TextLineOffsetY - ImageOffsetY; }
        }

        public float yMinOffsetSpecialAdjusted
        {
            // RVA: 0x1816C44
            get { return GlyphPlacement.Glyph.yMin + OffsetYSpecialAdjusted; }
        }

        protected float OffsetYSpecialAdjusted
        {
            // RVA: 0x1816D20
            get { return ImageOffsetY < 1 ? TextLineOffsetY : TextLineOffsetY - ImageOffsetY; }
        }

        public float yMaxOffsetSpecialAdjusted
        {
            // RVA: 0x1816D3C
            get { return GlyphPlacement.Glyph.yMax + OffsetYSpecialAdjusted; }
        }

        // RVA: 0x1816E18
        public HorizontalLayoutedImage(GlyphPlacement glyphPlacement)
        {
            GlyphPlacement = glyphPlacement;
            ImageOffsetY = ((InlineImageGlyph)glyphPlacement.Glyph).OffsetY;
        }
    }
}
