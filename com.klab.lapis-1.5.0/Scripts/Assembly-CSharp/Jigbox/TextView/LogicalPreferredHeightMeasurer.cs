// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.LogicalPreferredHeightMeasurer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：CalculateHeight 由反汇编中的逐逻辑行累加（upper/under + lineGap）
//        等价化简为 Σupper + Σunder + (n - 1) * lineGap。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Jigbox.TextView
{
    public class LogicalPreferredHeightMeasurer : PreferredHeightMeasurer
    {
        public override PreferredHeightType Type
        {
            // RVA: 0x181DDB8
            get { return PreferredHeightType.AllLogicalLine; }
        }

        // RVA: 0x181DDC0
        public LogicalPreferredHeightMeasurer(PreferredSizeMeasurer.PreferredSizeMeasurerProperty property)
            : base(property)
        {
        }

        // RVA: 0x181DDC8
        public override void CalculateHeight(List<TextLine> textLines)
        {
            IsCacheInvalid = false;
            lastIsLineHeightFixed = property.IsLineHeightFixed;

            float height = 0f;
            if (textLines != null && textLines.Count != 0)
            {
                float lineGap = property.LineGap;

                int index = 0;
                bool hasPreviousLine = false;
                while (index < textLines.Count)
                {
                    int lineCount = CalculateLogicalLineHeight(
                        textLines,
                        index,
                        out float upperHeight,
                        out float underHeight);

                    index += lineCount;

                    if (hasPreviousLine)
                    {
                        height += lineGap;
                    }

                    height += upperHeight + underHeight;
                    hasPreviousLine = true;
                }
            }

            Value = height;
        }

        // RVA: 0x181DF5C
        protected int CalculateLogicalLineHeight(
            List<TextLine> textLines,
            int index,
            out float upperHeight,
            out float underHeight)
        {
            int count = textLines.Count;
            int lineCount = 1;

            while (index + lineCount < count)
            {
                if (!textLines[index + lineCount].IsAutoLineBreak)
                {
                    break;
                }

                lineCount++;
            }

            int fontSize = property.FontSize;
            Font font = property.Font;

            upperHeight = 0f;
            if (lineCount <= 0)
            {
                underHeight = 0f;
                return lineCount;
            }

            for (int i = 0; i < lineCount; i++)
            {
                float value = textLines[index + i].CalculateHeightUpperBaseLine(
                    fontSize,
                    lastIsLineHeightFixed);

                upperHeight = Mathf.Max(upperHeight, value);
            }

            underHeight = 0f;
            for (int i = 0; i < lineCount; i++)
            {
                float value = textLines[index + i].CalculateHeightUnderBaseLine(
                    font,
                    upperHeight,
                    lastIsLineHeightFixed);

                underHeight = Mathf.Max(underHeight, value);
            }

            return lineCount;
        }
    }
}
