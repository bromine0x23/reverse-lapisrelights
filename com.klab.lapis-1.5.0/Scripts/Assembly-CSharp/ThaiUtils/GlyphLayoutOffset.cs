// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ThaiUtils.GlyphLayoutOffset
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace ThaiUtils
{
    public class GlyphLayoutOffset
    {
        public readonly int x; // 0x10
        public readonly int y; // 0x14

        public static GlyphLayoutOffset Zero
        {
            // RVA: 0x14482A0
            get { return new GlyphLayoutOffset(0, 0); }
        }

        // RVA: 0x1448300
        public GlyphLayoutOffset(int x, int y)
        {
            this.x = x;
            this.y = y;
        }
    }
}
