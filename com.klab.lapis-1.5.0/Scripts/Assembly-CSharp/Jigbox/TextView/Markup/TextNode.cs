// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.Markup.TextNode
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.Markup
{
    public class TextNode : MarkupNode, ITextContentNode
    {
        public string TextContent { get; set; } // 0x28

        // RVA: 0x18220CC
        public TextNode(string text)
        {
            TextContent = text;
        }
    }
}
