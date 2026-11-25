// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.IGlyph
//  来源：Il2CppDumper 元数据
// =============================================================================

using UnityEngine;
using UnityEngine.UI;

namespace Jigbox.TextView
{
    public interface IGlyph
    {
        float Width { get; }
        float Height { get; }
        float xMin { get; }
        float yMin { get; }
        float xMax { get; }
        float yMax { get; }
        bool IsWhiteSpaceOrControl { get; }

        char GetVisibleCharacter();
        void GetVertices(ref UIVertex[] vertices, float offsetX, float offsetY, Color color);
    }
}
