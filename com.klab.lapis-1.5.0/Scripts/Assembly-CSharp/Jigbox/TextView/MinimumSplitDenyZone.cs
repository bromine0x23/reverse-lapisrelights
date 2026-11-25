// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.MinimumSplitDenyZone
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：单元素断行单元的免分配实现。Elements 复用静态单元素数组。
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jigbox.TextView
{
    public sealed class MinimumSplitDenyZone : ISplitDenyZone
    {
        private static MainRenderingElement[] elementContainer; // 0x0
        private readonly MainRenderingElement element;          // 0x10

        public IEnumerable<MainRenderingElement> Elements
        {
            // RVA: 0x167D74C
            get
            {
                if (elementContainer == null)
                {
                    elementContainer = new MainRenderingElement[1];
                }

                elementContainer[0] = element;
                return elementContainer;
            }
        }

        public int ElementsCount
        {
            // RVA: 0x167D814
            get { return 1; }
        }

        // RVA: 0x167D81C
        public MinimumSplitDenyZone(MainRenderingElement element)
        {
            if (element == null)
            {
                throw new ArgumentNullException("element");
            }

            this.element = element;
        }

        // RVA: 0x167D8B8
        public float Width(MainRenderingElementPosition position)
        {
            return element.Width(position);
        }

        // RVA: 0x167D900
        public MainRenderingElement ElementAt(int index)
        {
            if (index != 0)
            {
                throw new ArgumentOutOfRangeException();
            }

            return element;
        }

        // RVA: 0x167D990
        static MinimumSplitDenyZone()
        {
            elementContainer = new MainRenderingElement[1];
        }
    }
}
