// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.HorizontalLayout
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：按 [startIndex, endIndex) 窗口聚合横向布局元素的包围盒。
//        已还原：字段、构造、Overflow*/DisplayableElement* 属性、
//        Height/Width/xMin/xMax/yMin/yMax、Add/GetElementAtIndex/Clear/
//        SetOverflowText/ClearOverflowText/GetEnumerator 与嵌套 Enumerator。
//        未还原：UpdateGlyph(0x1815FE8)（字体重建后经 GlyphCatalog 重新解析 Glyph）。
//  取值语义：xMax = max(xMax)，xMin = min(xMin)，yMax = min(yMax)，yMin = max(yMin)，
//        Height/Width = |max - min|（y 轴方向与屏幕相反，故 y 用 min/max 互换）。
// =============================================================================

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jigbox.TextView
{
    public class HorizontalLayout : IEnumerable
    {
        private List<IHorizontalLayoutedElement> allElements; // 0x10
        private Enumerator enumerator;                         // 0x18
        private int startIndex;                                // 0x20
        private int endIndex;                                  // 0x24

        public int? OverflowLine { get; private set; }         // 0x28
        public TextLine[] OverflowRemainText { get; private set; } // 0x30

        public int DisplayableElementStartIndex
        {
            // RVA: 0x181503C
            get { return startIndex; }
            // RVA: 0x1815044
            set { startIndex = Mathf.Max(0, value); }
        }

        public int DisplayableElementEndIndex
        {
            // RVA: 0x18150C4
            get { return endIndex; }
            // RVA: 0x18150CC
            set { endIndex = Mathf.Max(0, value); }
        }

        public float Height
        {
            // RVA: 0x1815244
            get
            {
                if (allElements.Count == 0)
                {
                    return 0f;
                }

                return Mathf.Abs(yMax - yMin);
            }
        }

        public float Width
        {
            // RVA: 0x18155A0
            get
            {
                if (allElements.Count == 0)
                {
                    return 0f;
                }

                return Mathf.Abs(xMax - xMin);
            }
        }

        public float xMax
        {
            // RVA: 0x1815640
            get
            {
                if (allElements.Count == 0)
                {
                    return 0f;
                }

                float max = allElements[startIndex].xMax;
                for (int i = startIndex + 1; i < endIndex; i++)
                {
                    max = Mathf.Max(max, allElements[i].xMax);
                }

                return max;
            }
        }

        public float xMin
        {
            // RVA: 0x1815834
            get
            {
                if (allElements.Count == 0)
                {
                    return 0f;
                }

                float min = allElements[startIndex].xMin;
                for (int i = startIndex + 1; i < endIndex; i++)
                {
                    min = Mathf.Min(min, allElements[i].xMin);
                }

                return min;
            }
        }

        public float yMax
        {
            // RVA: 0x1815A28
            get
            {
                if (allElements.Count == 0)
                {
                    return 0f;
                }

                float max = allElements[startIndex].yMax;
                for (int i = startIndex + 1; i < endIndex; i++)
                {
                    max = Mathf.Min(max, allElements[i].yMax);
                }

                return max;
            }
        }

        public float yMin
        {
            // RVA: 0x1815C1C
            get
            {
                if (allElements.Count == 0)
                {
                    return 0f;
                }

                float min = allElements[startIndex].yMin;
                for (int i = startIndex + 1; i < endIndex; i++)
                {
                    min = Mathf.Max(min, allElements[i].yMin);
                }

                return min;
            }
        }

        // RVA: 0x181514C
        public HorizontalLayout()
        {
            allElements = new List<IHorizontalLayoutedElement>();
            enumerator = new Enumerator(allElements);
            startIndex = 0;
            endIndex = 0;
            OverflowLine = null;
            OverflowRemainText = null;
        }

        // RVA: 0x1815E10
        public void Add(IHorizontalLayoutedElement element)
        {
            allElements.Add(element);
        }

        // RVA: 0x1815E78
        public IHorizontalLayoutedElement GetElementAtIndex(int index)
        {
            if (index < 0 || index >= allElements.Count)
            {
                return null;
            }

            return allElements[index];
        }

        // RVA: 0x1815F00
        public void Clear()
        {
            allElements.Clear();
            startIndex = 0;
            endIndex = 0;
            OverflowLine = null;
            OverflowRemainText = null;
        }

        // RVA: 0x1815F64
        public void SetOverflowText(int line, TextLine[] remain)
        {
            OverflowLine = line;
            OverflowRemainText = remain;
        }

        // RVA: 0x1815FE0
        public void ClearOverflowText()
        {
            OverflowLine = null;
            OverflowRemainText = null;
        }

        // RVA: 0x1815FE8
        public void UpdateGlyph(Font font)
        {
            GlyphCatalog catalog = GlyphCatalog.GetCatalog(font);        // 0x1816058

            foreach (IHorizontalLayoutedElement element in allElements)   // 0x181607C
            {
                if (!(element is HorizontalLayoutedGlyph))                // 0x18160DC（类型槽 0x3F043F8）
                {
                    continue;
                }

                GlyphPlacement placement = element.GlyphPlacement;        // 0x18160E0
                Glyph glyph = (Glyph)placement.Glyph;                     // 0x18160E8
                placement.Glyph = catalog.Get(glyph.GetSpec(font));       // 0x1816120 → 0x1816130
            }
        }

        // RVA: 0x18161D4
        public Enumerator GetEnumerator()
        {
            enumerator.SetRange(startIndex, endIndex);
            return enumerator;
        }

        // RVA: 0x1816210
        IEnumerator IEnumerable.GetEnumerator()
        {
            enumerator.SetRange(startIndex, endIndex);
            return enumerator;
        }

        public class Enumerator : IEnumerator<IHorizontalLayoutedElement>, IEnumerator
        {
            private List<IHorizontalLayoutedElement> elements; // 0x10
            private int startIndex;                            // 0x18
            private int endIndex;                              // 0x1C
            private int currentIndex;                          // 0x20
            private IHorizontalLayoutedElement current;        // 0x28

            public IHorizontalLayoutedElement Current
            {
                // RVA: 0x181623C
                get { return current; }
            }

            object IEnumerator.Current
            {
                // RVA: 0x1816244
                get { return current; }
            }

            IHorizontalLayoutedElement IEnumerator<IHorizontalLayoutedElement>.Current
            {
                // RVA: 0x181624C
                get { return current; }
            }

            // RVA: 0x1815204
            public Enumerator(List<IHorizontalLayoutedElement> elements)
            {
                this.elements = elements;
                startIndex = -1;
                endIndex = 0;
                currentIndex = -1;
                current = null;
            }

            // RVA: 0x1816254
            public bool MoveNext()
            {
                currentIndex++;
                if (currentIndex >= endIndex)
                {
                    return false;
                }

                current = elements[currentIndex];
                return true;
            }

            // RVA: 0x1816200
            public void SetRange(int startIndex, int endIndex)
            {
                this.startIndex = startIndex;
                this.endIndex = endIndex;
                currentIndex = startIndex - 1;
            }

            // RVA: 0x18162EC
            public void Reset()
            {
                currentIndex = startIndex - 1;
            }

            // RVA: 0x18162FC
            public void Dispose()
            {
            }
        }
    }
}
