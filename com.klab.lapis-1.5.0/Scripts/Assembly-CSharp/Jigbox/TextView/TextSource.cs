// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextSource
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView
{
    public class TextSource
    {
        public TextRun[] TextRuns { get; private set; }
        public string ErrorMessage { get; private set; }

        public bool HasError
        {
            // RVA: 0x168751C
            get { return !string.IsNullOrEmpty(ErrorMessage); }
        }

        // RVA: 0x1687540
        public TextSource(TextRun[] chunks, string errorMessage)
        {
            TextRuns = chunks;
            ErrorMessage = errorMessage;
        }
    }
}
