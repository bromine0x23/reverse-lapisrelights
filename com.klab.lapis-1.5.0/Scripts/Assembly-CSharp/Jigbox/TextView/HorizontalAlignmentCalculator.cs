// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.HorizontalAlignmentCalculator
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  已还原：Apply(0x1813408)、ZeroFillGlyphCalculator(0x1813A64)、构造。
//  未还原：SelectLineCalculator(0x18135DC)、SelectGlyphCalculator(0x1813894)、
//          JustifyGlyphCalculatorGenerator(0x1813944)、GetGlyphType(0x1813AD0)、
//          AutoSplitter(0x1813C14)、InterWordSplitter(0x18140A4)、
//          InterCharacterSplitter(0x18144A0)。
//  线索：SelectLineCalculator 是 TextAlign 的 5 路 switch，返回缓存的
//        Action<TextLine,float>；委托目标为编译器生成的
//        HorizontalAlignmentCalculator.<>c.<SelectLineCalculator>b__1_0 … b__1_3
//        （由 IDA 方法信息槽解析得到），下一轮可按这些名字定位 lambda 体。
// =============================================================================

using System;
using System.Collections.Generic;
using System.Globalization;

namespace Jigbox.TextView
{
    public class HorizontalAlignmentCalculator
    {
        public enum GlyphType
        {
            Space = 0,
            Word = 1,
            Other = 2
        }

        // RVA: 0x1813408
        public static void Apply(List<TextLine> textLines, TextAlign align, TextJustify justify, float width)
        {
            Action<TextLine, float> lineCalculator = SelectLineCalculator(align);          // 0x1813464
            Action<TextLine, float> glyphCalculator = SelectGlyphCalculator(align, justify); // 0x1813474

            foreach (TextLine line in textLines)
            {
                float free = Math.Max(width - line.LineWidth(), 0f);   // 0x18134E0–0x181350C
                lineCalculator(line, free);                            // 0x1813524
                glyphCalculator(line, free);                           // 0x181353C
            }
        }

        // RVA: 0x1813A64
        protected static void ZeroFillGlyphCalculator(TextLine input, float width)
        {
            GlyphPlacement[] glyphs = input.PlacedGlyphs;   // 0x1813A70

            for (int i = 0; i < glyphs.Length; i++)
            {
                glyphs[i].JustifyShiftOffsetX = 0f;         // 0x1813A9C (GlyphPlacement+0x30)
            }
        }

        // RVA: 0x18135DC
        // 委托目标：<>c.<SelectLineCalculator>b__1_0/b__1_1/b__1_2/b__1_3
        // （0x1814820 / 0x1814838 / 0x1814858 / 0x1814870，均为 "textLine.LineX = …"）
        protected static Action<TextLine, float> SelectLineCalculator(TextAlign align)
        {
            switch (align)
            {
                case TextAlign.Center:                        // case 1 → b__1_1
                    return (textLine, remainingWidth) => textLine.LineX = remainingWidth * 0.5f;

                case TextAlign.Right:                         // case 2 → b__1_2
                    return (textLine, remainingWidth) => textLine.LineX = remainingWidth;

                case TextAlign.Left:                          // case 0 → b__1_0
                case TextAlign.Justify:                       // case 3 → b__1_0
                case TextAlign.JustifyAll:                    // case 4 → b__1_0
                    return (textLine, remainingWidth) => textLine.LineX = 0f;

                default:                                      // default → b__1_3
                    return (textLine, remainingWidth) => textLine.LineX = 0f;
            }
        }

        // RVA: 0x1813894
        protected static Action<TextLine, float> SelectGlyphCalculator(TextAlign align, TextJustify justify)
        {
            if (align < TextAlign.Justify)          // 0x18138D0: subs w8, w20, #3 / b.lo
            {
                return ZeroFillGlyphCalculator;     // 0x18138E0 分支（静态方法委托）
            }

            // 0x18138D8–0x1813940：Justify / JustifyAll → 生成分布对齐计算器
            return JustifyGlyphCalculatorGenerator(align == TextAlign.JustifyAll, justify);
        }

        // RVA: 0x1813AD0
        protected static GlyphType GetGlyphType(IGlyph glyph)
        {
            if (glyph.IsWhiteSpaceOrControl)          // 0x1813B70（IGlyph 槽 6）
            {
                return GlyphType.Space;
            }

            if (glyph is Glyph textGlyph)             // 0x1813BC4
            {
                UnicodeCategory category = CharUnicodeInfo.GetUnicodeCategory(textGlyph.Character); // 0x1813BF0

                if (category < UnicodeCategory.TitlecaseLetter)   // 0x1813BFC cmp #2 / b.lo
                {
                    return GlyphType.Word;
                }

                // 0x1813C04/0x1813C08：DecimalDigitNumber → Word，否则 Other
                return category == UnicodeCategory.DecimalDigitNumber ? GlyphType.Word : GlyphType.Other;
            }

            return GlyphType.Other;                   // 0x1813BB4
        }

        // RVA: 0x1813944
        protected static Action<TextLine, float> JustifyGlyphCalculatorGenerator(bool isJusfifyAll, TextJustify justify)
        {
            throw new NotImplementedException("JustifyGlyphCalculatorGenerator 尚未还原");
        }

        // RVA: 0x1813C14
        protected static IList<IList<GlyphPlacement>> AutoSplitter(IEnumerable<GlyphPlacement> glyphPlacements)
        {
            throw new NotImplementedException("AutoSplitter 尚未还原");
        }

        // RVA: 0x18140A4
        protected static IList<IList<GlyphPlacement>> InterWordSplitter(IEnumerable<GlyphPlacement> glyphPlacements)
        {
            throw new NotImplementedException("InterWordSplitter 尚未还原");
        }

        // RVA: 0x18144A0
        protected static IList<IList<GlyphPlacement>> InterCharacterSplitter(IEnumerable<GlyphPlacement> glyphPlacements)
        {
            throw new NotImplementedException("InterCharacterSplitter 尚未还原");
        }

        // RVA: 0x18147AC
        public HorizontalAlignmentCalculator()
        {
        }
    }
}
