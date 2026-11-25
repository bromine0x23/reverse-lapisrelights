// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.TextToken
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using Jigbox.TextView.Markup;

namespace Jigbox.TextView.ParserV2
{
    public sealed class TextToken : Token
    {
        public override TokenType Type
        {
            // RVA: 0x1681708
            get { return TokenType.Text; }
        }

        // RVA: 0x167F694
        public TextToken(string text)
            : base(text)
        {
        }

        // RVA: 0x1681710
        public override MarkupNode CreateMarkupNode()
        {
            return new TextNode(String);
        }
    }
}
