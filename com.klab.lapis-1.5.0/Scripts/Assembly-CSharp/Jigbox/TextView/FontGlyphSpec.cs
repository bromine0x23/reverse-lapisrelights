// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.FontGlyphSpec
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using UnityEngine;

namespace Jigbox.TextView
{
    public class FontGlyphSpec : IGlyphSpec, IEquatable<FontGlyphSpec>
    {
        public readonly char Character;            // 0x10
        public readonly Font Font;                 // 0x18
        public readonly int Size;                  // 0x20
        public readonly FontStyle Style;           // 0x24
        public readonly Color? Color;              // 0x28 (value 0x28, hasValue 0x38)
        public readonly float GlyphScaleX;         // 0x3C
        private int hashCode;                      // 0x40

        // RVA: 0x1811580
        public FontGlyphSpec(char character, Font font, int size, FontStyle style, Color? color, float glyphScaleX)
        {
            Character = character;
            Font = font;
            Size = size;
            Style = style;
            Color = color;
            GlyphScaleX = glyphScaleX;

            int hash = Character.GetHashCode();
            hash = hash * 397 ^ Size;
            hash = hash * 397 ^ (int)Style;
            hash = hash * 397 ^ (Color.HasValue ? Color.GetHashCode() : 0);
            hashCode = hash * 397 ^ GlyphScaleX.GetHashCode();
        }

        // RVA: 0x1811698
        public bool Equals(FontGlyphSpec other)
        {
            if (other == null)
            {
                return false;
            }

            return hashCode == other.hashCode && Font == other.Font;
        }

        // RVA: 0x1811740
        public override bool Equals(object obj)
        {
            FontGlyphSpec other = obj as FontGlyphSpec;
            if (other == null)
            {
                return false;
            }

            return hashCode == other.hashCode && Font == other.Font;
        }

        // RVA: 0x181181C
        public override int GetHashCode()
        {
            return hashCode;
        }
    }
}
