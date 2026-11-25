// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.EndTagToken
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public sealed class EndTagToken : Token
    {
        public bool AllowEmpty { get; private set; }

        public override TokenType Type
        {
            // RVA: 0x167F8F8
            get { return TokenType.EndTag; }
        }

        // RVA: 0x167EB50
        public EndTagToken(string tag, bool allowEmpty = false)
            : base(tag)
        {
            AllowEmpty = allowEmpty;
        }
    }
}
