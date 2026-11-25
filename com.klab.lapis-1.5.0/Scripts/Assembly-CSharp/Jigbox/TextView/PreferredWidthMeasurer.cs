// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.PreferredWidthMeasurer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class PreferredWidthMeasurer : PreferredBaseMeasurer
    {
        public virtual PreferredWidthType Type
        {
            // RVA: 0x1683A8C
            get { return PreferredWidthType.FirstLine; }
        }

        // RVA: 0x16835E0
        public PreferredWidthMeasurer(PreferredSizeMeasurer.PreferredSizeMeasurerProperty property)
        {
            this.property = property;
            IsCacheInvalid = true;
        }

        // RVA: 0x1683A94
        public virtual void CalculateWidth(List<LineRenderingElements> renderingElements)
        {
            IsCacheInvalid = false;
            Value = renderingElements != null && renderingElements.Count != 0
                ? renderingElements[0].Width
                : 0f;
        }
    }
}
