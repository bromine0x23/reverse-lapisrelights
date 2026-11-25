// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.ParseResult
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using Jigbox.TextView.Markup;

namespace Jigbox.TextView.ParserV2
{
    public sealed class ParseResult
    {
        public MarkupNode Node { get; private set; }
        public bool WasSuccessful { get; private set; }
        public string Message { get; private set; }

        // RVA: 0x167FC00
        public ParseResult(MarkupNode node)
        {
            Node = node;
            WasSuccessful = true;
            Message = null;
        }

        // RVA: 0x167FC38
        public ParseResult(string message)
        {
            Node = null;
            WasSuccessful = false;
            Message = message;
        }
    }
}
