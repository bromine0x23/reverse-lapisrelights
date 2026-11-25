// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextBiDirectionOverride
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView
{
    public class TextBiDirectionOverride : TextRun
    {
        public override int Length
        {
            // RVA: 0x1685188
            get { return 0; }
        }

        public bool ForceLTR { get; private set; } // 0x10

        // RVA: 0x16851A4
        public TextBiDirectionOverride(string direction)
        {
            ForceLTR = direction == "ltr";
        }
    }
}
