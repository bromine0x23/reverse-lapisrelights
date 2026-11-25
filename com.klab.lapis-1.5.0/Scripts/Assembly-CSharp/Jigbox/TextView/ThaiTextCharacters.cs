// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ThaiTextCharacters
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（构造）
//  说明：构造中 length 为各 TextUnit.data 长度之和。
// =============================================================================

using System.Collections.Generic;
using ThaiUtils;

namespace Jigbox.TextView
{
    public class ThaiTextCharacters : TextRun
    {
        private int length; // 0x18

        public override int Length
        {
            // RVA: 0x1688D48
            get { return length; }
        }

        public List<TextUnit> Texts { get; private set; } // 0x10

        // RVA: 0x1688D60
        public ThaiTextCharacters(string source)
        {
            ThaiTextConverter.Convert(source);
            Texts = new List<TextUnit>(ThaiTextConverter.Texts);

            for (int i = 0; i < Texts.Count; i++)
            {
                length += Texts[i].data.Length;
            }
        }
    }
}
