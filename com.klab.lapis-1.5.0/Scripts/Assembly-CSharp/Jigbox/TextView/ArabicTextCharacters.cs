// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ArabicTextCharacters
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（构造）
// =============================================================================

using ArabicUtils;

namespace Jigbox.TextView
{
    public class ArabicTextCharacters : TextCharacters
    {
        // RVA: 0x18105F4
        public ArabicTextCharacters(string source)
            : base(ArabicTextConverter.Convert(source))
        {
        }
    }
}
