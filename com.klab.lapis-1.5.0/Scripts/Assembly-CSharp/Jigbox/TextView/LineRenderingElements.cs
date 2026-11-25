// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.LineRenderingElements
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class LineRenderingElements
    {
        private const MainRenderingElementPosition position =
            MainRenderingElementPosition.LineHeadTail;

        private readonly List<ISplitDenyZone> zones;
        public readonly int ZonesCount;

        public IEnumerable<ISplitDenyZone> Zones
        {
            // RVA: 0x181A47C
            get { return zones; }
        }

        public float Width
        {
            // RVA: 0x181A484
            get
            {
                float width = 0f;

                for (int i = 0; i < ZonesCount; i++)
                {
                    MainRenderingElementPosition position;
                    if (i == 0)
                    {
                        position = ZonesCount == 1
                            ? MainRenderingElementPosition.LineHeadTail
                            : MainRenderingElementPosition.LineHead;
                    }
                    else
                    {
                        position = i == ZonesCount - 1
                            ? MainRenderingElementPosition.LineTail
                            : MainRenderingElementPosition.LineMiddle;
                    }

                    width += zones[i].Width(position);
                }

                return width;
            }
        }

        // RVA: 0x181A62C
        public LineRenderingElements(IEnumerable<ISplitDenyZone> zones)
        {
            this.zones = new List<ISplitDenyZone>(zones);
            ZonesCount = this.zones.Count;
        }

        // RVA: 0x181A6C0
        public ISplitDenyZone ElementAt(int index)
        {
            if (index < 0 || index >= ZonesCount)
            {
                throw new IndexOutOfRangeException();
            }

            return zones[index];
        }
    }
}
