// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.MainRenderingElement
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView
{
    public abstract class MainRenderingElement
    {
        public int GlyphIndex { get; protected set; }

        public abstract IGlyph IGlyph { get; }

        public abstract float Width(MainRenderingElementPosition position);

        // RVA: 0x181E37C
        protected MainRenderingElement()
        {
        }
    }
}
