// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.AttributeValueToken
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public sealed class AttributeValueToken : Token
    {
        public override TokenType Type
        {
            // RVA: 0x167DEE4
            get { return TokenType.AttributeValue; }
        }

        // RVA: 0x167DEEC
        public AttributeValueToken(string value)
            : base(value)
        {
        }
    }
}
