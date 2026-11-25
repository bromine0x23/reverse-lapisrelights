// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.LineBreakRule
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：断行规则基类。规则表在 .cctor 中创建为空字典（0x1819E48），
//        因此 GetLineBreakRule 目前只会返回 null（本版本未注册派生规则）。
// =============================================================================

using System.Collections.Generic;

namespace Jigbox.TextView
{
    public abstract class LineBreakRule
    {
        private static Dictionary<TextLineBreakRule, LineBreakRule> rules; // 0x0

        // RVA: 0x1819A94
        public static LineBreakRule GetLineBreakRule(TextLineBreakRule lineBreakRule)
        {
            LineBreakRule rule;
            rules.TryGetValue(lineBreakRule, out rule);
            return rule;
        }

        public abstract bool IsNotAllowAtBeginOfLine(IGlyph g);

        public abstract bool IsNotAllowAtEndOfLine(IGlyph g);

        public abstract bool CanWrap(IGlyph firstLineTailGlyph, IGlyph secondLineBeginGlyph);

        // RVA: 0x1819E38
        public virtual bool CanBurasage(IGlyph g)
        {
            return false;
        }

        // RVA: 0x1819E40
        protected LineBreakRule()
        {
        }

        // RVA: 0x1819E48
        static LineBreakRule()
        {
            rules = new Dictionary<TextLineBreakRule, LineBreakRule>();
        }
    }
}
