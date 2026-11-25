// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.AutoLineBreakRule
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：把一行 LineRenderingElements 按可用宽度切成若干 TextLine。
//        Apply / SkipWhitespace / ApplyOneLine 均已按反汇编还原。
//        依赖 Jigbox.TextView.TextLineBuilder（尚未还原）。
// =============================================================================

using System.Collections.Generic;
using Jigbox.Components;

namespace Jigbox.TextView
{
    public class AutoLineBreakRule
    {
        // RVA: 0x1810678
        public static List<TextLine> Apply(
            LineRenderingElements input,
            float width,
            LineBreakRule lineBreakRule,
            bool useBurasage,
            TextViewOverflowExtension.AutoLineEllipsisParameter? ellipsisParameter)
        {
            List<TextLine> lines = new List<TextLine>();
            LineRenderingElementsPointer pointer = new LineRenderingElementsPointer(input);
            int lineIndex = 0;
            int totalSkippedCount = 0;
            bool needSkipWhitespace = false;

            while (true)
            {
                if (needSkipWhitespace)
                {
                    LineRenderingElementsPointer skipped;
                    int skippedCount;
                    SkipWhitespace(pointer, out skipped, out skippedCount);
                    pointer = skipped;
                    totalSkippedCount += skippedCount;
                }

                float availableWidth = width;
                if (ellipsisParameter.HasValue &&
                    ellipsisParameter.Value.EllipsisLine == lineIndex)
                {
                    availableWidth = width - ellipsisParameter.Value.OffsetWidth;
                }

                TextLineBuilder builder = ApplyOneLine(pointer, availableWidth, lineBreakRule, useBurasage, totalSkippedCount);
                lines.Add(builder.Result);

                pointer = builder.To;
                lineIndex++;

                if (pointer.Target.ZonesCount == pointer.ZoneIndex)
                {
                    return lines;
                }

                needSkipWhitespace = true;
            }
        }

        // RVA: 0x1810860
        protected static void SkipWhitespace(
            LineRenderingElementsPointer startPointer,
            out LineRenderingElementsPointer skippedPointer,
            out int skippedCount)
        {
            skippedPointer = startPointer;
            skippedCount = 0;

            while (skippedPointer != null)
            {
                if (!(skippedPointer.Element() is MainRenderingFontElement fontElement))
                {
                    return;
                }

                if (!fontElement.Glyph.IsWhiteSpaceOrControl)
                {
                    return;
                }

                skippedCount++;
                skippedPointer = skippedPointer.NextMainRenderingElement();
            }
        }

        // RVA: 0x1810938
        protected static TextLineBuilder ApplyOneLine(
            LineRenderingElementsPointer pointer,
            float width,
            LineBreakRule lineBreakRule,
            bool useBurasage,
            int totalSkippedCount)
        {
            TextLineBuilder builder = new TextLineBuilder(pointer, totalSkippedCount);

            // 1) 逐个分区扩张，直到超宽
            while (builder.Width <= width)
            {
                if (!builder.MoveNextSplitDenyZone())
                {
                    return builder;
                }
            }

            // 2) 分词（分かち書き）语言的禁则处理
            if (useBurasage)
            {
                ISplitDenyZone previousZone = builder.To.PreviousSplitDenyZone().Zone();
                if (previousZone.ElementsCount == 1)
                {
                    MainRenderingElement element = previousZone.ElementAt(0);
                    if (lineBreakRule.CanBurasage(element.IGlyph))
                    {
                        return builder;
                    }
                }
            }

            // 3) 回退分区，直到宽度可容纳且满足断行禁则
            while (true)
            {
                if (!builder.MovePreviousSplitDenyZone())
                {
                    break;
                }

                if (builder.MainRenderingElementsCount == 0)
                {
                    break;
                }

                if (builder.Width > width)
                {
                    continue;
                }

                MainRenderingElement lastElement = builder.LastElement;
                IGlyph lastGlyph = lastElement == null ? null : lastElement.IGlyph;
                if (lineBreakRule.IsNotAllowAtEndOfLine(lastGlyph))
                {
                    continue;
                }

                IGlyph nextGlyph = builder.To.Element().IGlyph;
                if (lineBreakRule.IsNotAllowAtBeginOfLine(nextGlyph))
                {
                    continue;
                }

                if (lineBreakRule.CanWrap(lastGlyph, nextGlyph))
                {
                    return builder;
                }
            }

            // 4) 退化：整行按主元素逐个填充
            builder = new TextLineBuilder(pointer, totalSkippedCount);
            while (true)
            {
                builder.MoveNextMainRenderingElement();
                if (builder.Width <= width)
                {
                    continue;
                }

                if (builder.MainRenderingElementsCount >= 2)
                {
                    builder.MovePreviousMainRenderingElement();
                }

                return builder;
            }
        }

        // RVA: 0x1811014
        public AutoLineBreakRule()
        {
        }
    }
}
