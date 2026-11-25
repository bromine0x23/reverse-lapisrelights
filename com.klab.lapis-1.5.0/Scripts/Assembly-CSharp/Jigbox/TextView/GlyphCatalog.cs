// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.GlyphCatalog
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：按 Font 缓存字形。CreateGlyphs 把 FontGlyphSpec 列表按
//        (Size, Style) 分段交给 TextGenerator 生成，再用 Font.GetCharacterInfo
//        取度量并构造 Glyph。
//  证据：RequestStringLengthLimit = 16000（.cctor：mov w9,#0x3e80），
//        GetTextGeneratorSetting 的 generationExtents = (float.MaxValue, float.MaxValue)
//        （常量 0x7F7FFFFF，见 0x300DDE0）。
// =============================================================================

using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace Jigbox.TextView
{
    public class GlyphCatalog
    {
        protected static readonly int RequestStringLengthLimit;             // 0x0
        private static readonly Dictionary<Font, GlyphCatalog> catalogs;    // 0x8
        private static StringBuilder stringBuilder;                         // 0x10

        public Font Font { get; protected set; }        // 0x10
        private readonly TextGenerator generator;       // 0x18
        private Dictionary<FontGlyphSpec, Glyph> glyphs; // 0x20
        private bool hasFontRebuilt;                    // 0x28

        // RVA: 0x1812478
        public static GlyphCatalog GetCatalog(Font font)
        {
            GlyphCatalog catalog;
            if (catalogs.TryGetValue(font, out catalog))
            {
                return catalog;
            }

            catalog = new GlyphCatalog(font);
            catalogs.Add(font, catalog);
            return catalog;
        }

        // RVA: 0x1812650
        public bool CreateGlyphs(IList<FontGlyphSpec> specs)
        {
            int count = specs.Count;
            if (count == 0)
            {
                return false;
            }

            hasFontRebuilt = false;
            stringBuilder.Length = 0;

            FontGlyphSpec prevSpec = null;
            int prevIndex = -1;

            for (int i = 0; i < count; i++)
            {
                FontGlyphSpec spec = specs[i];
                stringBuilder.Append(spec.Character);

                if (prevIndex < 0)
                {
                    prevSpec = spec;
                    prevIndex = i;
                }

                if (i - prevIndex < RequestStringLengthLimit && i + 1 < count)
                {
                    FontGlyphSpec nextSpec = specs[i + 1];
                    if (prevSpec.Size == nextSpec.Size && prevSpec.Style == nextSpec.Style)
                    {
                        continue;
                    }
                }

                string text = stringBuilder.ToString();
                TextGenerationSettings settings = GetTextGeneratorSetting(Font, prevSpec.Size, prevSpec.Style);
                generator.Invalidate();
                generator.Populate(text, settings);

                if (hasFontRebuilt)
                {
                    return false;
                }

                for (int j = 0; j < text.Length; j++)
                {
                    FontGlyphSpec glyphSpec = specs[prevIndex + j];
                    if (!glyphs.ContainsKey(glyphSpec))
                    {
                        CharacterInfo info;
                        Font.GetCharacterInfo(glyphSpec.Character, out info, glyphSpec.Size, glyphSpec.Style);
                        glyphs.Add(glyphSpec, new Glyph(glyphSpec, info));
                    }
                }

                stringBuilder.Length = 0;
                prevSpec = null;
                prevIndex = -1;
            }

            return true;
        }

        // RVA: 0x1812CB0
        public void Clear()
        {
            glyphs.Clear();
        }

        // RVA: 0x1812D08
        public Glyph Get(FontGlyphSpec spec)
        {
            Glyph glyph;
            glyphs.TryGetValue(spec, out glyph);
            return glyph;
        }

        // RVA: 0x1812570
        private GlyphCatalog(Font font)
        {
            glyphs = new Dictionary<FontGlyphSpec, Glyph>();
            Font = font;
            generator = new TextGenerator();
            Font.textureRebuilt += OnFontRebuilt;
        }

        // RVA: 0x1812D80
        private void OnFontRebuilt(Font font)
        {
            if (Font == font)
            {
                hasFontRebuilt = true;
            }
        }

        // RVA: 0x1812BFC
        private static TextGenerationSettings GetTextGeneratorSetting(Font font, int fontSize, FontStyle fontStyle)
        {
            return new TextGenerationSettings
            {
                font = font,
                color = Color.white,
                fontSize = fontSize,
                lineSpacing = 0f,
                richText = false,
                scaleFactor = 1f,
                fontStyle = fontStyle,
                textAnchor = TextAnchor.UpperLeft,
                alignByGeometry = false,
                resizeTextForBestFit = false,
                resizeTextMinSize = 0,
                resizeTextMaxSize = 0,
                updateBounds = false,
                verticalOverflow = VerticalWrapMode.Truncate,
                horizontalOverflow = HorizontalWrapMode.Wrap,
                generationExtents = new Vector2(float.MaxValue, float.MaxValue),
                pivot = Vector2.zero,
                generateOutOfBounds = true
            };
        }

        // RVA: 0x1812E0C
        static GlyphCatalog()
        {
            RequestStringLengthLimit = 16000;
            catalogs = new Dictionary<Font, GlyphCatalog>();
            stringBuilder = new StringBuilder();
        }
    }
}
