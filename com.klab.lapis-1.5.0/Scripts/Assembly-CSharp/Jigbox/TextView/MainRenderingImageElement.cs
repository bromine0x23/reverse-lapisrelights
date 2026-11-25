// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.MainRenderingImageElement
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：行内图片的主渲染元素。
//        已还原：字段、自动属性、IGlyph、Width(position)、Subs、.cctor。
//        推断（构造 0x181D7CC 的 0xEE8 条未逐指令解读，字段映射依据 dump 字段表与
//        属性赋值模式）：ctor 逐字段赋值并构造 InlineImageGlyph。
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public class MainRenderingImageElement : MainRenderingElement
    {
        protected static readonly IEnumerable<SubRenderingFontElement> SubsEmptyList; // 0x0

        public InlineImageGlyph Glyph { get; protected set; }  // 0x18
        private readonly float width;                          // 0x20
        public float Height { get; protected set; }            // 0x24
        public string Source { get; protected set; }           // 0x28
        public string Name { get; protected set; }             // 0x30
        public float CharacterSpacingRight { get; protected set; } // 0x38
        public float RubySpacingLeft { get; protected set; }   // 0x3C
        public float RubySpacingRight { get; protected set; }  // 0x40
        public int MarginLeft { get; protected set; }          // 0x44
        public int MarginRight { get; protected set; }         // 0x48
        public int OffsetY { get; protected set; }             // 0x4C
        protected List<SubRenderingFontElement> subs;          // 0x50
        public readonly MainRenderingElementOption Option;     // 0x58

        public override IGlyph IGlyph
        {
            // RVA: 0x181E6B4
            get { return Glyph; }
        }

        // RVA: 0x181E6CC
        public override float Width(MainRenderingElementPosition position)
        {
            float widthValue = Glyph.Width
                + RubySpacingLeft
                + (float)MarginLeft
                + RubySpacingRight;

            if ((int)(position | MainRenderingElementPosition.LineMiddle) != (int)MainRenderingElementPosition.LineHeadTail
                || !Option.TrimLineTailSpacing)
            {
                widthValue += CharacterSpacingRight;
            }

            if ((int)(position | MainRenderingElementPosition.LineMiddle) != (int)MainRenderingElementPosition.LineHeadTail)
            {
                widthValue += (float)MarginRight;
            }

            return widthValue;
        }

        public IEnumerable<SubRenderingFontElement> Subs
        {
            // RVA: 0x181E878
            get { return subs != null ? (IEnumerable<SubRenderingFontElement>)subs : SubsEmptyList; }
        }

        // RVA: 0x181D7CC
        public MainRenderingImageElement(
            float width,
            float height,
            string source,
            string name,
            float characterSpacingRight,
            float rubySpacingLeft,
            float rubySpacingRight,
            int marginLeft,
            int marginRight,
            int offsetY,
            IEnumerable<SubRenderingFontElement> subs,
            int glyphIndex,
            MainRenderingElementOption option)
        {
            GlyphIndex = glyphIndex;
            Glyph = new InlineImageGlyph(width, height, source, name, offsetY);
            this.width = width;
            Height = height;
            Source = source;
            Name = name;
            CharacterSpacingRight = characterSpacingRight;
            RubySpacingLeft = rubySpacingLeft;
            RubySpacingRight = rubySpacingRight;
            MarginLeft = marginLeft;
            MarginRight = marginRight;
            OffsetY = offsetY;
            this.subs = subs != null ? new List<SubRenderingFontElement>(subs) : null;
            Option = option;
        }

        // RVA: 0x181E8EC
        static MainRenderingImageElement()
        {
            SubsEmptyList = new SubRenderingFontElement[0];
        }
    }
}
