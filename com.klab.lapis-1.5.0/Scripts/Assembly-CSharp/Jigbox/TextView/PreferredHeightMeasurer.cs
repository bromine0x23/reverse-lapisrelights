// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.PreferredHeightMeasurer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class PreferredHeightMeasurer : PreferredBaseMeasurer
    {
        protected bool lastIsLineHeightFixed;

        public override bool HasCache
        {
            // RVA: 0x1682F48
            get { return !IsCacheInvalid && property.IsLineHeightFixed == lastIsLineHeightFixed; }
        }

        public virtual PreferredHeightType Type
        {
            // RVA: 0x1682FA0
            get { return PreferredHeightType.AllLine; }
        }

        // RVA: 0x1682FA8
        public PreferredHeightMeasurer(PreferredSizeMeasurer.PreferredSizeMeasurerProperty property)
        {
            this.property = property;
            IsCacheInvalid = true;
            lastIsLineHeightFixed = property.IsLineHeightFixed;
        }

        // RVA: 0x1682FFC
        public virtual void CalculateHeight(List<TextLine> textLines)
        {
            IsCacheInvalid = false;
            lastIsLineHeightFixed = property.IsLineHeightFixed;

            float height = 0f;
            if (textLines != null && textLines.Count != 0)
            {
                TextLine firstLine = textLines[0];
                TextLine lastLine = textLines[textLines.Count - 1];

                int fontSize = property.FontSize;
                float upperHeight = firstLine.CalculateHeightUpperBaseLine(
                    fontSize,
                    lastIsLineHeightFixed);

                float lastUpperHeight = upperHeight;
                if (textLines.Count != 1)
                {
                    lastUpperHeight = lastLine.CalculateHeightUpperBaseLine(
                        fontSize,
                        lastIsLineHeightFixed);
                }

                float underHeight = lastLine.CalculateHeightUnderBaseLine(
                    property.Font,
                    lastUpperHeight,
                    lastIsLineHeightFixed);

                height = underHeight + (upperHeight + (firstLine.LineY - lastLine.LineY));
            }

            Value = height;
        }
    }
}
