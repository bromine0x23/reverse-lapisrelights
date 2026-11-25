// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextLine
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Text;
using UnityEngine;

namespace Jigbox.TextView
{
    public class TextLine
    {
        public GlyphPlacement[] PlacedGlyphs { get; set; }
        public float LineY { get; set; }
        public float LineX { get; set; }
        public bool IsLastLine { get; set; }
        public bool IsAutoLineBreak { get; set; }

        // RVA: 0x16853D8
        public override string ToString()
        {
            StringBuilder builder = new StringBuilder();
            builder.Append("TextLine: \"");

            for (int i = 0; i < PlacedGlyphs.Length; i++)
            {
                GlyphPlacement placement = PlacedGlyphs[i];
                if (placement.Y >= 0f)
                {
                    builder.Append(placement.Glyph.GetVisibleCharacter());
                }
            }

            builder.Append('"');
            return builder.ToString();
        }

        // RVA: 0x1685558
        public int MinIndex()
        {
            if (PlacedGlyphs.Length < 1)
            {
                return -1;
            }

            int min = int.MaxValue;
            for (int i = 0; i < PlacedGlyphs.Length; i++)
            {
                int index = PlacedGlyphs[i].Index;
                if (min > index)
                {
                    min = index;
                }
            }

            return min;
        }

        // RVA: 0x16855B4
        public int MaxIndex()
        {
            if (PlacedGlyphs.Length < 1)
            {
                return -1;
            }

            int max = int.MinValue;
            for (int i = 0; i < PlacedGlyphs.Length; i++)
            {
                int index = PlacedGlyphs[i].Index;
                if (max < index)
                {
                    max = index;
                }
            }

            return max;
        }

        // RVA: 0x1685610
        public float LineWidth()
        {
            int count = PlacedGlyphs.Length;
            if (count < 1)
            {
                return 0f;
            }

            float width = 0f;
            for (int i = 0; i < count; i++)
            {
                GlyphPlacement placement = PlacedGlyphs[i];
                width = Mathf.Max(width, placement.X + placement.Glyph.Width);
            }

            return width;
        }

        // RVA: 0x1685748
        public float LineHeight()
        {
            int count = PlacedGlyphs.Length;
            if (count < 1)
            {
                return 0f;
            }

            float height = 0f;
            for (int i = 0; i < count; i++)
            {
                GlyphPlacement placement = PlacedGlyphs[i];
                height = Mathf.Max(height, placement.Y + placement.Glyph.Height);
            }

            return height;
        }

        // RVA: 0x1683144
        public float CalculateHeightUpperBaseLine(
            int fontSize,
            bool isLineHeightFixed,
            int visibleLength = -1)
        {
            float height = fontSize;

            if (isLineHeightFixed)
            {
                return height;
            }

            if (PlacedGlyphs.Length == 0)
            {
                return height;
            }

            int maxIndex = visibleLength != -1 ? visibleLength - 1 : MaxIndex();
            for (int i = 0; i < PlacedGlyphs.Length; i++)
            {
                GlyphPlacement placement = PlacedGlyphs[i];
                if (placement.Index > maxIndex)
                {
                    break;
                }

                height = Mathf.Max(height, placement.Glyph.Height - placement.Y);
            }

            return height;
        }

        // RVA: 0x16832F0
        public float CalculateHeightUnderBaseLine(
            Font font,
            float heightUpperBaseLine,
            bool isLineHeightFixed,
            int visibleLength = -1)
        {
            float height = CalculateHeightUnderBaseLineRate(font) * heightUpperBaseLine;

            if (isLineHeightFixed)
            {
                return height;
            }

            if (PlacedGlyphs.Length == 0)
            {
                return height;
            }

            int maxIndex = visibleLength != -1 ? visibleLength - 1 : MaxIndex();
            for (int i = 0; i < PlacedGlyphs.Length; i++)
            {
                GlyphPlacement placement = PlacedGlyphs[i];
                if (placement.Index > maxIndex)
                {
                    break;
                }

                height = Mathf.Max(height, placement.Y);
            }

            return height;
        }

        // RVA: 0x1685884
        protected float CalculateHeightUnderBaseLineRate(Font font)
        {
            if (font == null)
            {
                return 0f;
            }

            return (font.lineHeight - font.fontSize) * 0.5f / font.fontSize;
        }

        // RVA: 0x1685950
        public int GetPlacedGlyphCountAtVisibleIndex(int visibleLength)
        {
            if (visibleLength < 0)
            {
                return 0;
            }

            int count = PlacedGlyphs.Length;
            if (count < 1)
            {
                return 0;
            }

            for (int i = 0; i < count; i++)
            {
                if (PlacedGlyphs[i].Index >= visibleLength)
                {
                    return i;
                }
            }

            return count;
        }

        // RVA: 0x16859C0
        public void AddGlyphPlacement(GlyphPlacement glyphPlacement)
        {
            GlyphPlacement[] current = PlacedGlyphs;
            GlyphPlacement[] extended = new GlyphPlacement[current.Length + 1];
            Array.Copy(current, extended, current.Length);
            extended[current.Length] = glyphPlacement;
            PlacedGlyphs = extended;
        }

        // RVA: 0x1685AA8
        public TextLine()
        {
        }
    }
}
