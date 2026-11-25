// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.IGlyphSpecGroup
//  来源：Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public interface IGlyphSpecGroup
    {
        int MainsCount { get; }
        int RubiesCount { get; }
        float? RubyOffset { get; }
        float? RubyScale { get; }
        IEnumerable<MainGlyphPlacementSpec> Mains { get; }
        IEnumerable<FontGlyphSpec> Rubies { get; }
    }
}
