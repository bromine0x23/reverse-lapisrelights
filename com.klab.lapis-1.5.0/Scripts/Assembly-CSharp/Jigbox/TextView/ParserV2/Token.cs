// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.Token
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using Jigbox.TextView.Markup;

namespace Jigbox.TextView.ParserV2
{
    public abstract class Token
    {
        public abstract TokenType Type { get; }

        public string String { get; protected set; }

        // RVA: 0x167DA28
        public Token(string str)
        {
            String = str;
        }

        // RVA: 0x16828C8
        public virtual MarkupNode CreateMarkupNode()
        {
            return null;
        }
    }
}
