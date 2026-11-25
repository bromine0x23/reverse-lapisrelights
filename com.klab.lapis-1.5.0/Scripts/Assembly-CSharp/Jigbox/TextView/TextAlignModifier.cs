// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextAlignModifier
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView
{
    public class TextAlignModifier : TextRun
    {
        public override int Length
        {
            // RVA: 0x168504C
            get { return 0; }
        }

        public TextAlign Align { get; private set; } // 0x10

        // RVA: 0x1685064
        public TextAlignModifier(string align)
        {
            if (align == "l" || align == "left")
            {
                Align = TextAlign.Left;
            }
            else if (align == "r" || align == "right")
            {
                Align = TextAlign.Right;
            }
            else if (align == "c")
            {
                Align = TextAlign.Center;
            }
            else
            {
                Align = align == "center" ? TextAlign.Center : TextAlign.Left;
            }
        }
    }
}
