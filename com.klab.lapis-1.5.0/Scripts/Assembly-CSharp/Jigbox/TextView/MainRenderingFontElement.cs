// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.MainRenderingFontElement
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：主渲染元素（一个字 + 可选注解）。
//        已还原：全部成员（字段、构造、IGlyph/Glyph/Subs/SubsCount/Width、
//        CharacterSpacingRight/RubySpacingLeft/RubySpacingRight/OffsetX/OffsetY、.cctor）。
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class MainRenderingFontElement : MainRenderingElement
    {
        protected static readonly IEnumerable<SubRenderingFontElement> SubsEmptyList; // 0x0

        public Glyph Glyph { get; protected set; }       // 0x18
        private readonly List<SubRenderingFontElement> subs; // 0x20
        public float CharacterSpacingRight { get; protected set; } // 0x28
        public float RubySpacingLeft { get; protected set; }        // 0x2C
        public float RubySpacingRight { get; protected set; }       // 0x30
        public int OffsetX { get; set; }       // 0x34
        public int OffsetY { get; set; }       // 0x38
        public readonly MainRenderingElementOption Option; // 0x40

        public override IGlyph IGlyph
        {
            // RVA: 0x181E3AC
            get { return Glyph; }
        }

        // RVA: 0x181E3C4
        public IEnumerable<SubRenderingFontElement> Subs(MainRenderingElementPosition position)
        {
            if (subs != null)
            {
                return subs;
            }

            return SubsEmptyList;
        }

        public int SubsCount
        {
            // RVA: 0x181E438
            get { return subs == null ? 0 : subs.Count; }
        }

        public override float Width(MainRenderingElementPosition position)
        {
            // RVA: 0x181E48C
            float width = RubySpacingLeft + Glyph.Width + RubySpacingRight;

            // (position | LineMiddle) == LineHeadTail 即 position 为 LineTail/LineHeadTail
            if ((int)(position | MainRenderingElementPosition.LineMiddle) != (int)MainRenderingElementPosition.LineHeadTail
                || !Option.TrimLineTailSpacing)
            {
                width += CharacterSpacingRight;
            }

            return width;
        }

        // RVA: 0x181D5C4
        public MainRenderingFontElement(
            Glyph glyph,
            float characterSpacingRight,
            float rubySpacingLeft,
            float rubySpacingRight,
            IEnumerable<SubRenderingFontElement> subs,
            int glyphIndex,
            MainRenderingElementOption option)
        {
            GlyphIndex = glyphIndex;
            Glyph = glyph;
            this.subs = subs != null ? new List<SubRenderingFontElement>(subs) : null;
            CharacterSpacingRight = characterSpacingRight;
            RubySpacingLeft = rubySpacingLeft;
            RubySpacingRight = rubySpacingRight;
            Option = option;
        }

        // RVA: 0x181E5D8
        static MainRenderingFontElement()
        {
            SubsEmptyList = new SubRenderingFontElement[0];
        }
    }
}
