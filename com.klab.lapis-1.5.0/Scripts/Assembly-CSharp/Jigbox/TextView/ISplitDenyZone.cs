// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ISplitDenyZone
//  来源：Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public interface ISplitDenyZone
    {
        IEnumerable<MainRenderingElement> Elements { get; }
        int ElementsCount { get; }

        float Width(MainRenderingElementPosition position);
        MainRenderingElement ElementAt(int index);
    }
}
