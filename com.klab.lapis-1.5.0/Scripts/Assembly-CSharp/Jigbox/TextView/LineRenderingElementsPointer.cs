// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.LineRenderingElementsPointer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：断行算法在 LineRenderingElements 的分区/元素网格上移动的游标。
//        已还原：全部 20 个成员（字段/构造/导航/判定/比较/哈希）。
// =============================================================================

using System;

namespace Jigbox.TextView
{
    public class LineRenderingElementsPointer : IComparable<LineRenderingElementsPointer>
    {
        public readonly LineRenderingElements Target; // 0x10
        protected int zoneIndex;                      // 0x18
        protected int elementIndex;                   // 0x1C

        public int ZoneIndex
        {
            // RVA: 0x181D910
            get { return zoneIndex; }
        }

        public int ElementIndex
        {
            // RVA: 0x181D918
            get { return elementIndex; }
        }

        // RVA: 0x1810820
        public LineRenderingElementsPointer(LineRenderingElements target, int zoneIndex = 0, int elementIndex = 0)
        {
            Target = target;
            this.zoneIndex = zoneIndex;
            this.elementIndex = elementIndex;
        }

        // RVA: 0x1810C4C
        public bool IsEndOfElements()
        {
            return Target.ZonesCount == zoneIndex;
        }

        // RVA: 0x1810C74
        public LineRenderingElementsPointer PreviousSplitDenyZone()
        {
            int previousZone = zoneIndex - 1;
            if (previousZone < 0)
            {
                return null;
            }

            return new LineRenderingElementsPointer(Target, previousZone, 0);
        }

        // RVA: 0x1810CFC
        public ISplitDenyZone Zone()
        {
            if (Target.ZonesCount == zoneIndex)
            {
                return null;
            }

            return Target.ElementAt(zoneIndex);
        }

        // RVA: 0x1810D30
        public MainRenderingElement Element()
        {
            if (Target.ZonesCount == zoneIndex)
            {
                return null;
            }

            ISplitDenyZone zone = Target.ElementAt(zoneIndex);
            return zone.ElementAt(elementIndex);
        }

        // RVA: 0x1810ECC
        public LineRenderingElementsPointer NextMainRenderingElement()
        {
            if (Target.ZonesCount == zoneIndex)
            {
                return null;
            }

            int elementsCount = Target.ElementAt(zoneIndex).ElementsCount;
            int nextZoneIndex = zoneIndex;
            int nextElementIndex = elementIndex + 1;

            if (elementsCount == nextElementIndex)
            {
                nextZoneIndex = zoneIndex + 1;
                nextElementIndex = 0;
            }

            return new LineRenderingElementsPointer(Target, nextZoneIndex, nextElementIndex);
        }

        // RVA: 0x181DB68
        public LineRenderingElementsPointer PreviousMainRenderingElement()
        {
            if (zoneIndex != 0 && elementIndex == 0)
            {
                int previousZoneIndex = zoneIndex - 1;
                int elementsCount = Target.ElementAt(previousZoneIndex).ElementsCount;
                return new LineRenderingElementsPointer(Target, previousZoneIndex, elementsCount - 1);
            }

            if (zoneIndex == 0 && elementIndex == 0)
            {
                return null;
            }

            return new LineRenderingElementsPointer(Target, zoneIndex, elementIndex - 1);
        }

        // RVA: 0x181DCA0
        public LineRenderingElementsPointer NextSplitDenyZone()
        {
            if (zoneIndex < Target.ZonesCount)
            {
                return new LineRenderingElementsPointer(Target, zoneIndex + 1, 0);
            }

            return null;
        }

        // RVA: 0x181DD38
        public bool HasNextMainRenderingElement()
        {
            return Target.ZonesCount != zoneIndex;
        }

        // RVA: 0x181DD60
        public bool HasPreviousMainRenderingElement()
        {
            if (zoneIndex != 0)
            {
                return true;
            }

            return elementIndex != 0;
        }

        // RVA: 0x181DD80
        public bool HasNextSplitDenyZone()
        {
            return zoneIndex < Target.ZonesCount;
        }

        // RVA: 0x181DDA8
        public bool HasPreviousSplitDenyZone()
        {
            return zoneIndex > 0;
        }

        // RVA: 0x181DB14
        public override int GetHashCode()
        {
            int hash = Target.GetHashCode();
            hash = (hash ^ 0x1A6F) * 0x65;
            hash = (hash ^ zoneIndex) * 0x65;
            return hash ^ elementIndex;
        }

        // RVA: 0x181D920
        public static bool op_LessThan(LineRenderingElementsPointer p0, LineRenderingElementsPointer p1)
        {
            return p0.CompareTo(p1) < 0;
        }

        // RVA: 0x181DA1C
        public static bool op_GreaterThan(LineRenderingElementsPointer p0, LineRenderingElementsPointer p1)
        {
            return p0.CompareTo(p1) > 0;
        }

        // RVA: 0x181D940
        public int CompareTo(LineRenderingElementsPointer other)
        {
            if (other == null)
            {
                return 1;
            }

            if (Target != other.Target)
            {
                // 原始调用为 ArgumentException(message, "other")；message 字符串槽
                // （0x3FBBAFA8）不在可读段内，无法解析原文，这里只保留参数名。
                throw new ArgumentException("other");
            }

            int zoneDiff = zoneIndex - other.zoneIndex;
            if (zoneDiff != 0)
            {
                return zoneDiff;
            }

            return elementIndex - other.elementIndex;
        }

        // RVA: 0x181DA40
        public override bool Equals(object other)
        {
            LineRenderingElementsPointer pointer = other as LineRenderingElementsPointer;
            if (pointer == null)
            {
                return false;
            }

            if (Target != pointer.Target)
            {
                return false;
            }

            return zoneIndex == pointer.zoneIndex && elementIndex == pointer.elementIndex;
        }
    }
}
