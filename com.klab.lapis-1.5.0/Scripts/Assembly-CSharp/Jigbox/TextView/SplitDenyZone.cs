// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.SplitDenyZone
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：断行时的不可拆分单元（一组主渲染元素）。
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class SplitDenyZone : ISplitDenyZone
    {
        private readonly List<MainRenderingElement> elements; // 0x10
        private readonly int elementsCount;                   // 0x18

        public IEnumerable<MainRenderingElement> Elements
        {
            // RVA: 0x1684D10
            get { return elements; }
        }

        public int ElementsCount
        {
            // RVA: 0x1684D18
            get { return elementsCount; }
        }

        // RVA: 0x1684D20
        public SplitDenyZone(IEnumerable<MainRenderingElement> elements)
        {
            if (elements == null)
            {
                throw new ArgumentNullException("elements");
            }

            this.elements = new List<MainRenderingElement>(elements);
            elementsCount = this.elements.Count;

            if (elementsCount == 0)
            {
                throw new ArgumentException("elements");
            }
        }

        // RVA: 0x1684E24
        public virtual float Width(MainRenderingElementPosition position)
        {
            float width = 0f;

            for (int i = 0; i < elementsCount; i++)
            {
                MainRenderingElementPosition elementPosition =
                    MainRenderingElementPositionExtension.PositionAtIndex(position, i, elementsCount);

                width += elements[i].Width(elementPosition);
            }

            return width;
        }

        // RVA: 0x1684F04
        public MainRenderingElement ElementAt(int index)
        {
            if (index < 0 || index >= elementsCount)
            {
                throw new ArgumentOutOfRangeException();
            }

            return elements[index];
        }
    }
}
