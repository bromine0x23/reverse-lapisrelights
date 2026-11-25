// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextCharactersRubyGroup
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView
{
    public class TextCharactersRubyGroup : TextCharacters
    {
        public string RawRubyCharacters { get; private set; } // 0x18

        // RVA: 0x1685338
        public TextCharactersRubyGroup(string baseText, string rubyText)
            : base(baseText)
        {
            RawRubyCharacters = rubyText;
        }
    }
}
