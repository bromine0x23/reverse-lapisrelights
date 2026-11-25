// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.LogicalPreferredWidthMeasurer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Jigbox.TextView
{
    public class LogicalPreferredWidthMeasurer : PreferredWidthMeasurer
    {
        public override PreferredWidthType Type
        {
            // RVA: 0x181E1AC
            get { return PreferredWidthType.AllLogicalLine; }
        }

        // RVA: 0x181E1B4
        public LogicalPreferredWidthMeasurer(PreferredSizeMeasurer.PreferredSizeMeasurerProperty property)
            : base(property)
        {
        }

        // RVA: 0x181E1BC
        public override void CalculateWidth(List<LineRenderingElements> renderingElements)
        {
            IsCacheInvalid = false;

            float width = 0f;
            if (renderingElements != null && renderingElements.Count > 0)
            {
                for (int i = 0; i < renderingElements.Count; i++)
                {
                    width = Mathf.Max(width, renderingElements[i].Width);
                }
            }

            Value = width;
        }
    }
}
