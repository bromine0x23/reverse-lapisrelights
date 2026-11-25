// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextCharacters
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;

namespace Jigbox.TextView
{
    public class TextCharacters : TextRun
    {
        public string RawCharacters { get; private set; } // 0x10

        public override int Length
        {
            // RVA: 0x1685250
            get { return RawCharacters.Length; }
        }

        // RVA: 0x168526C
        public TextCharacters(string source)
        {
            if (source.Contains("\n"))
            {
                throw new ArgumentException(
                    "Should not include new line in the text. Use LineBreak");
            }

            RawCharacters = source;
        }
    }
}
