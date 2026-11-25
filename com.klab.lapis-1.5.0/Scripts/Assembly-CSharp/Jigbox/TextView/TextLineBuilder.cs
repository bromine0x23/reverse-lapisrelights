// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextLineBuilder
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：从 From 游标开始、按分区/主元素推进并在超宽时回退，最终产出 TextLine。
//        已还原：字段、构造、To/From、TotalSkippedCount、MainRenderingElementsCount、
//        Width、LastElement、MoveNext/PreviousMainRenderingElement、
//        MoveNext/PreviousSplitDenyZone、UpdateMainRenderingElementsCount、
//        嵌套 MutableLineRenderingElementsPointer。
//        未还原：Result 的 MainRenderingImageElement（行内图片）分支。
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class TextLineBuilder
    {
        public LineRenderingElementsPointer From { get; private set; } // 0x10
        public LineRenderingElementsPointer To { get; private set; }   // 0x18
        public int TotalSkippedCount { get; private set; }             // 0x20
        private int? startGlyphIndex;                                  // 0x24
        private LineRenderingElementsPointer lastCalculatedPointer;    // 0x30
        private float lastCalculatedWidth;                             // 0x38
        private float lastElementWidth;                                // 0x3C
        public int MainRenderingElementsCount { get; private set; }    // 0x40

        // RVA: 0x1686484
        public TextLineBuilder(LineRenderingElementsPointer FromPointer, int totalSkippedCount)
        {
            From = FromPointer;
            To = FromPointer;
            TotalSkippedCount = totalSkippedCount;

            if (From.IsEndOfElements())
            {
                startGlyphIndex = null;
            }
            else
            {
                startGlyphIndex = From.Element().GlyphIndex - TotalSkippedCount;
            }

            MainRenderingElementsCount = 0;
        }

        // RVA: 0x1685AF0
        public float Width
        {
            get
            {
                int count = MainRenderingElementsCount;
                if (count == 0)
                {
                    return 0f;
                }

                float total = 0f;
                float elementWidth;
                MutableLineRenderingElementsPointer pointer;

                if (lastCalculatedPointer != null)
                {
                    int compare = lastCalculatedPointer.CompareTo(To);
                    if (compare == 0)
                    {
                        return lastCalculatedWidth;
                    }

                    if (compare < 0)
                    {
                        pointer = new MutableLineRenderingElementsPointer(
                            lastCalculatedPointer.PreviousMainRenderingElement());
                        total = lastCalculatedWidth - lastElementWidth;
                    }
                    else
                    {
                        pointer = new MutableLineRenderingElementsPointer(From);
                    }
                }
                else
                {
                    pointer = new MutableLineRenderingElementsPointer(From);
                }

                elementWidth = 0f;

                while (pointer.CompareTo(To) < 0)
                {
                    MainRenderingElement element = pointer.Element();
                    MainRenderingElementPosition position =
                        MainRenderingElementPositionExtension.PositionAtIndex(
                            MainRenderingElementPosition.LineHeadTail,
                            element.GlyphIndex - TotalSkippedCount - startGlyphIndex.Value,
                            count);

                    elementWidth = element.Width(position);
                    total += elementWidth;
                    pointer.MoveNext();
                }

                lastCalculatedWidth = total;
                lastElementWidth = elementWidth;
                lastCalculatedPointer = To;
                return total;
            }
        }

        // RVA: 0x1685DC8
        public MainRenderingElement LastElement
        {
            get
            {
                LineRenderingElementsPointer pointer = To.PreviousMainRenderingElement();
                if (pointer == null)
                {
                    return null;
                }

                return pointer.Element();
            }
        }

        // RVA: 0x1685DFC
        // 未完整还原：`MainRenderingImageElement` 分支（行内图片）缺失，
        // 该类型尚未还原（其字段 0x18 Glyph / 0x3C RubySpacingLeft / 0x44 MarginLeft / 0x4C OffsetY）。
        // 图片元素当前只会按 fallback 累加宽度、不产出 GlyphPlacement。
        public TextLine Result
        {
            get
            {
                int count = MainRenderingElementsCount;
                if (count == 0)
                {
                    TextLine emptyLine = new TextLine();
                    emptyLine.PlacedGlyphs = new GlyphPlacement[0];
                    return emptyLine;
                }

                List<GlyphPlacement> placements = new List<GlyphPlacement>(count);
                MutableLineRenderingElementsPointer pointer = new MutableLineRenderingElementsPointer(From);
                float offsetX = 0f;

                while (pointer.CompareTo(To) < 0)
                {
                    MainRenderingElement element = pointer.Element();
                    int index = element.GlyphIndex - TotalSkippedCount - startGlyphIndex.Value;
                    MainRenderingElementPosition position =
                        MainRenderingElementPositionExtension.PositionAtIndex(
                            MainRenderingElementPosition.LineHeadTail,
                            index,
                            count);

                    MainRenderingFontElement fontElement = element as MainRenderingFontElement;
                    if (fontElement != null)
                    {
                        if (fontElement.SubsCount >= 1)
                        {
                            List<GlyphPlacement> subPlacements = new List<GlyphPlacement>(fontElement.SubsCount);

                            foreach (SubRenderingFontElement sub in fontElement.Subs(position))
                            {
                                subPlacements.Add(new GlyphPlacement(
                                    sub.Glyph,
                                    offsetX + sub.OffsetX,
                                    sub.OffsetY,
                                    index,
                                    false,
                                    null));
                            }

                            placements.Add(new GlyphPlacement(
                                fontElement.Glyph,
                                offsetX + fontElement.RubySpacingLeft + fontElement.OffsetX,
                                fontElement.OffsetY,
                                index,
                                true,
                                subPlacements));

                            placements.AddRange(subPlacements);
                        }
                        else
                        {
                            placements.Add(new GlyphPlacement(
                                fontElement.Glyph,
                                offsetX + fontElement.RubySpacingLeft + fontElement.OffsetX,
                                fontElement.OffsetY,
                                index,
                                true,
                                null));
                        }
                    }

                    offsetX += element.Width(position);
                    pointer.MoveNext();
                }

                TextLine line = new TextLine();
                line.PlacedGlyphs = placements.ToArray();
                return line;
            }
        }

        // RVA: 0x1686554
        public bool MoveNextMainRenderingElement()
        {
            LineRenderingElementsPointer pointer = To.NextMainRenderingElement();
            if (pointer == null)
            {
                return false;
            }

            To = pointer;
            MainRenderingElementsCount++;
            return true;
        }

        // RVA: 0x168659C
        public bool MovePreviousMainRenderingElement()
        {
            if (From.CompareTo(To) == 0)
            {
                return false;
            }

            To = To.PreviousMainRenderingElement();
            MainRenderingElementsCount--;
            return true;
        }

        // RVA: 0x16865F8
        public bool MoveNextSplitDenyZone()
        {
            LineRenderingElementsPointer pointer = To.NextSplitDenyZone();
            if (pointer == null)
            {
                return false;
            }

            To = pointer;
            UpdateMainRenderingElementsCount();
            return true;
        }

        // RVA: 0x168663C
        protected void UpdateMainRenderingElementsCount()
        {
            if (From.CompareTo(To) == 0)
            {
                MainRenderingElementsCount = 0;
                return;
            }

            MainRenderingElementsCount =
                To.PreviousMainRenderingElement().Element().GlyphIndex + 1 - startGlyphIndex.Value;
        }

        // RVA: 0x16866E4
        public bool MovePreviousSplitDenyZone()
        {
            if (To.CompareTo(From) == 0)
            {
                return false;
            }

            LineRenderingElementsPointer pointer = To.PreviousSplitDenyZone();
            if (pointer.CompareTo(From) < 0)
            {
                pointer = From;
            }

            To = pointer;
            UpdateMainRenderingElementsCount();
            return true;
        }

        // RVA: 0x1685C9C / 0x1685CC0
        private class MutableLineRenderingElementsPointer : LineRenderingElementsPointer
        {
            public MutableLineRenderingElementsPointer(LineRenderingElementsPointer pointer)
                : base(pointer.Target, pointer.ZoneIndex, pointer.ElementIndex)
            {
            }

            public bool MoveNext()
            {
                if (Target.ZonesCount == zoneIndex)
                {
                    return false;
                }

                int elementsCount = Target.ElementAt(zoneIndex).ElementsCount;
                if (elementsCount == elementIndex + 1)
                {
                    zoneIndex++;
                    elementIndex = 0;
                }
                else
                {
                    elementIndex++;
                }

                return true;
            }
        }
    }
}
