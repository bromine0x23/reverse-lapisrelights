// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.VisibledPreferredWidthMeasurer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编
//  说明：仅还原 HasCache / Type / 构造。GetWidth（0x16892B8）需要遍历
//        ISplitDenyZone/MainRenderingElement 并按可见长度裁剪宽度，
//        其内部枚举器与异常处理尚未还原，因此 CalculateWidth（0x16891E8）
//        依赖 GetWidth，也暂未还原。
// =============================================================================

namespace Jigbox.TextView
{
    public class VisibledPreferredWidthMeasurer : PreferredWidthMeasurer
    {
        protected static readonly MainRenderingElementPosition ElementPosition =
            MainRenderingElementPosition.LineHeadTail;

        protected int lastVisibleLength;

        public override bool HasCache
        {
            // RVA: 0x1689190
            get { return !IsCacheInvalid && property.VisibleLength == lastVisibleLength; }
        }

        public override PreferredWidthType Type
        {
            // RVA: 0x16891E0
            get { return PreferredWidthType.Visibled; }
        }

        // RVA: 0x1683940
        public VisibledPreferredWidthMeasurer(PreferredSizeMeasurer.PreferredSizeMeasurerProperty property)
            : base(property)
        {
            lastVisibleLength = property.VisibleLength;
        }
    }
}
