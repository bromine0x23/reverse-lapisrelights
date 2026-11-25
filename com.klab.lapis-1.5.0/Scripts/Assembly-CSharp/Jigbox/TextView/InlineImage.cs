// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.InlineImage
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView
{
    public class InlineImage : TextRun
    {
        public override int Length
        {
            // RVA: 0x18171C8
            get { return 1; }
        }

        public string Source { get; set; }                    // 0x10
        public string Name { get; set; }                      // 0x18
        public InlineImageSize Width { get; set; }            // 0x20
        public InlineImageSize Height { get; set; }           // 0x28
        public int? MarginLeftWithPixel { get; set; }         // 0x30
        public int? MarginRightWithPixel { get; set; }        // 0x38
        public int? OffsetYWithPixel { get; set; }            // 0x40

        // RVA: 0x18171C8 (see Length)
        public InlineImage()
        {
        }
    }
}
