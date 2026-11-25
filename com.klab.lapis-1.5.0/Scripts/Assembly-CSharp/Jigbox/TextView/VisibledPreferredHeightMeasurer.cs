// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.VisibledPreferredHeightMeasurer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class VisibledPreferredHeightMeasurer : PreferredHeightMeasurer
    {
        protected int lastVisibleLength;
        protected int lastVisibleLineStartIndex;

        public override bool HasCache
        {
            // RVA: 0x1688EB4
            get
            {
                return base.HasCache &&
                       property.VisibleLength == lastVisibleLength &&
                       property.VisibleLineStart == lastVisibleLineStartIndex;
            }
        }

        public override PreferredHeightType Type
        {
            // RVA: 0x1688F24
            get { return PreferredHeightType.Visibled; }
        }

        // RVA: 0x1683990
        public VisibledPreferredHeightMeasurer(PreferredSizeMeasurer.PreferredSizeMeasurerProperty property)
            : base(property)
        {
            lastVisibleLength = property.VisibleLength;
            lastVisibleLineStartIndex = property.VisibleLineStart;
        }

        // RVA: 0x1688F2C
        public override void CalculateHeight(List<TextLine> textLines)
        {
            IsCacheInvalid = false;
            lastIsLineHeightFixed = property.IsLineHeightFixed;
            lastVisibleLength = property.VisibleLength;
            lastVisibleLineStartIndex = property.VisibleLineStart;

            float height = 0f;
            if (textLines != null && textLines.Count != 0)
            {
                int visibleLength = property.VisibleLength;
                int startIndex = lastVisibleLineStartIndex;
                int lastIndex;

                if (visibleLength != -1 && startIndex < textLines.Count)
                {
                    lastIndex = startIndex;
                    while (true)
                    {
                        if (textLines[lastIndex].MaxIndex() + 1 >= property.VisibleLength)
                        {
                            break;
                        }

                        lastIndex++;
                        if (lastIndex >= textLines.Count)
                        {
                            lastIndex = textLines.Count - 1;
                            break;
                        }
                    }
                }
                else
                {
                    lastIndex = textLines.Count - 1;
                }

                TextLine firstLine = textLines[startIndex];
                TextLine lastLine = textLines[lastIndex];

                int fontSize = property.FontSize;
                float upperHeight = firstLine.CalculateHeightUpperBaseLine(
                    fontSize,
                    lastIsLineHeightFixed,
                    visibleLength);

                float lastUpperHeight = upperHeight;
                if (startIndex != lastIndex)
                {
                    lastUpperHeight = lastLine.CalculateHeightUpperBaseLine(
                        fontSize,
                        lastIsLineHeightFixed,
                        visibleLength);
                }

                float underHeight = lastLine.CalculateHeightUnderBaseLine(
                    property.Font,
                    lastUpperHeight,
                    lastIsLineHeightFixed,
                    visibleLength);

                height = underHeight + (upperHeight + (firstLine.LineY - lastLine.LineY));
            }

            Value = height;
        }
    }
}
