// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.InlineImageGlyph
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：行内图片的 IGlyph 实现。xMin/yMin 恒为 0，xMax/yMax 取 Width/Height；
//        IsWhiteSpaceOrControl 恒为 false；GetVisibleCharacter 恒为 '□'(0x25A1)。
//        未还原：GetVertices (0x1817A30)。
// =============================================================================

using System;
using UnityEngine;
using UnityEngine.UI;

namespace Jigbox.TextView
{
    public class InlineImageGlyph : IGlyph
    {
        public float Width { get; set; }   // 0x10
        public float Height { get; set; }  // 0x14
        public string Source { get; set; } // 0x18
        public string Name { get; set; }   // 0x20
        public int OffsetY { get; set; }   // 0x28

        public float xMin
        {
            // RVA: 0x181797C
            get { return 0f; }
        }

        public float yMin
        {
            // RVA: 0x1817984
            get { return 0f; }
        }

        public float xMax
        {
            // RVA: 0x181798C
            get { return Width; }
        }

        public float yMax
        {
            // RVA: 0x1817994
            get { return Height; }
        }

        public bool IsWhiteSpaceOrControl
        {
            // RVA: 0x181799C
            get { return false; }
        }

        // RVA: 0x18179D4
        public InlineImageGlyph(float width, float height, string source, string name, int offsetY)
        {
            Width = width;
            Height = height;
            Source = source;
            Name = name;
            OffsetY = offsetY;
        }

        // RVA: 0x1817A28
        public char GetVisibleCharacter()
        {
            return '\u25A1';
        }

        // RVA: 0x1817A30
        public void GetVertices(ref UIVertex[] vertices, float offsetX, float offsetY, Color color)
        {
            throw new NotImplementedException("InlineImageGlyph.GetVertices 尚未还原");
        }
    }
}
