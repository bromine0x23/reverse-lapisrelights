// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.Glyph
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（构造/取值）
//  说明：已还原字段、构造、度量取值、IsWhiteSpaceOrControl、GetSpec、
//        GetVisibleCharacter。GetVertices/GetMirrorVertices/ToString 属网格生成
//        阶段，尚未还原，调用会抛出异常。
// =============================================================================

using System;
using ArabicUtils;
using UnityEngine;
using UnityEngine.UI;

namespace Jigbox.TextView
{
    public class Glyph : IGlyph
    {
        public const int VertexCount = 4;

        public char Character { get; private set; } // 0x10
        protected Color? color;                     // 0x14
        protected float scaleX;                     // 0x28
        protected FontStyle style;                  // 0x2C
        protected Vector3 positionMin;              // 0x30
        protected Vector3 positionMax;              // 0x3C
        protected Vector2[] uv;                     // 0x48
        public float Width { get; private set; }    // 0x50
        public float RawWidth { get; private set; } // 0x54
        public float Height { get; private set; }   // 0x58
        public float RightBearingDiff { get; private set; } // 0x5C

        public float xMin
        {
            // RVA: 0x1811864
            get { return positionMin.x; }
        }

        public float yMin
        {
            // RVA: 0x181186C
            get { return positionMin.y; }
        }

        public float xMax
        {
            // RVA: 0x1811874
            get { return positionMax.x; }
        }

        public float yMax
        {
            // RVA: 0x181187C
            get { return positionMax.y; }
        }

        public bool IsWhiteSpaceOrControl
        {
            // RVA: 0x1810E18
            get { return char.IsControl(Character) || char.IsWhiteSpace(Character); }
        }

        // RVA: 0x1811894
        public Glyph(FontGlyphSpec spec, CharacterInfo info)
        {
            uv = new Vector2[VertexCount];
            Character = spec.Character;
            color = spec.Color;
            style = spec.Style;

            positionMin = new Vector3(info.minX, info.minY, 0f);
            positionMax = new Vector3(info.maxX, info.maxY, 0f);

            uv[0] = info.uvBottomLeft;
            uv[1] = info.uvTopLeft;
            uv[2] = info.uvTopRight;
            uv[3] = info.uvBottomRight;

            scaleX = spec.GlyphScaleX;
            RawWidth = info.advance;
            Width = scaleX * info.advance;

            positionMin.x *= scaleX;
            positionMax.x *= scaleX;

            Height = spec.Size;

            if (ArabicLetter.IsArabic(Character))
            {
                int bearing = info.bearing;
                int glyphWidth = info.glyphWidth;
                int advance = info.advance;
                int bearing2 = info.bearing;

                RightBearingDiff = scaleX * (glyphWidth + bearing - advance + bearing2);
            }
        }

        // RVA: 0x1811B50
        public FontGlyphSpec GetSpec(Font font)
        {
            return new FontGlyphSpec(
                Character,
                font,
                (int)Height,
                style,
                color,
                scaleX);
        }

        // RVA: 0x1811C00
        public char GetVisibleCharacter()
        {
            return Character;
        }

        // RVA: 0x1811C08
        public void GetVertices(ref UIVertex[] vertices, float offsetX, float offsetY, Color color)
        {
            throw new NotImplementedException("Glyph.GetVertices 尚未还原");
        }

        // RVA: 0x1811FF8
        public void GetMirrorVertices(ref UIVertex[] vertices, float offsetX, float offsetY, Color color, float mirrorOffsetX)
        {
            throw new NotImplementedException("Glyph.GetMirrorVertices 尚未还原");
        }

        // RVA: 0x18123F0
        public override string ToString()
        {
            throw new NotImplementedException("Glyph.ToString 尚未还原");
        }
    }
}
