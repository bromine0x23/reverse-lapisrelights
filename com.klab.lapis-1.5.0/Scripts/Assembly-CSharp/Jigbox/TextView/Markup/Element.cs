// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.Markup.Element
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Linq;

namespace Jigbox.TextView.Markup
{
    public class Element : MarkupNode, ITextContentNode
    {
        public string TagName { get; set; } // 0x28

        public string TextContent
        {
            // RVA: 0x181E9C8
            get
            {
                return string.Join(
                    string.Empty,
                    Children.OfType<ITextContentNode>()
                            .Select(node => node.TextContent)
                            .ToArray());
            }
        }

        // RVA: 0x181EB88
        public Element(string tagName)
        {
            TagName = tagName;
        }
    }
}
