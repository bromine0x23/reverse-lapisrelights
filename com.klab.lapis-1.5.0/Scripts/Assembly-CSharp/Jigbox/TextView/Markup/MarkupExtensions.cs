// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.Markup.MarkupExtensions
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.Markup
{
    public static class MarkupExtensions
    {
        // RVA: 0x181ECD4
        public static string GetAttribute(this MarkupNode node, string attr, string defaultValue = "")
        {
            if (node.AttributesCount != 0 && node.Attributes.ContainsKey(attr))
            {
                return node.Attributes[attr];
            }

            return defaultValue;
        }
    }
}
