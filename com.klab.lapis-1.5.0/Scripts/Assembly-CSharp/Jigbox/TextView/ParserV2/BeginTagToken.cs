// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.BeginTagToken
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using Jigbox.TextView.Markup;

namespace Jigbox.TextView.ParserV2
{
    public sealed class BeginTagToken : Token
    {
        public int ChildrenCount { get; set; }
        public int AttributeCount { get; set; }

        public override TokenType Type
        {
            // RVA: 0x167EBFC
            get { return TokenType.Tag; }
        }

        // RVA: 0x167EC24
        public BeginTagToken(string tag)
            : base(tag)
        {
        }

        // RVA: 0x167EC50
        public override MarkupNode CreateMarkupNode()
        {
            Element element = new Element(String);

            if (ChildrenCount >= 1)
            {
                element.SetChildrenCapacity(ChildrenCount);
            }

            if (AttributeCount > 0)
            {
                element.SetAttributesCapacity(AttributeCount);
            }

            return element;
        }
    }
}
