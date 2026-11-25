// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextSourceCompilerProperty
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;

namespace Jigbox.TextView
{
    public class TextSourceCompilerProperty
    {
        protected Jigbox.Components.TextView textView; // 0x10
        public TextAlign? ModifyAlign;                 // 0x18

        public virtual Font Font
        {
            // RVA: 0x1688C30
            get { return textView.Font; }
        }

        public virtual int FontSize
        {
            // RVA: 0x1688C4C
            get { return textView.FontSize; }
        }

        public virtual float CharacterSpacing
        {
            // RVA: 0x1688C68
            get { return textView.CharacterSpacing; }
        }

        public virtual Color Color
        {
            // RVA: 0x1688C84
            get { return textView.color; }
        }

        public virtual float GlyphScaleX
        {
            // RVA: 0x1688CA8
            get { return textView.GlyphScaleX; }
        }

        public virtual TextLineBreakRule LineBreakRule
        {
            // RVA: 0x1688CC4
            get { return textView.LineBreakRule; }
        }

        public virtual FontStyle DefaultFontStyle
        {
            // RVA: 0x1688CE0
            get { return textView.DefaultFontStyle; }
        }

        // RVA: 0x1688CFC
        public TextSourceCompilerProperty(Jigbox.Components.TextView textView)
        {
            this.textView = textView;
        }
    }
}
