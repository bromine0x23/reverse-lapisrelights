// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ThaiUtils.TextUnit
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（构造）
//  说明：Thai 排版的最小单元（一个字形簇）。
//        isStartSpan/isEndSpan 默认均为 true（构造中写入 0x101）。
// =============================================================================

namespace ThaiUtils
{
    public sealed class TextUnit
    {
        public readonly char[] data;                    // 0x10
        public readonly bool isLayouted;                // 0x18
        public readonly GlyphLayoutOffset[] offsets;    // 0x20
        public bool isStartSpan;                        // 0x28
        public bool isEndSpan;                          // 0x29

        // RVA: 0x1448F58
        public TextUnit(char[] data)
        {
            this.data = data;
            isLayouted = false;
            isStartSpan = true;
            isEndSpan = true;
        }

        // RVA: 0x14488EC
        public TextUnit(char[] data, GlyphLayoutOffset[] offsets)
        {
            this.data = data;
            this.offsets = offsets;
            isLayouted = true;
            isStartSpan = true;
            isEndSpan = true;
        }
    }
}
