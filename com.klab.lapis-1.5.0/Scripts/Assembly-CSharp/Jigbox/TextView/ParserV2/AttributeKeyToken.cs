// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.AttributeKeyToken
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public sealed class AttributeKeyToken : Token
    {
        public override TokenType Type
        {
            // RVA: 0x167D9F4
            get { return TokenType.Attribute; }
        }

        // RVA: 0x167D9FC
        public AttributeKeyToken(string attribute)
            : base(attribute)
        {
        }
    }
}
