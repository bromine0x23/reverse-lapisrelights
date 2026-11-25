// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.MainRenderingElementPositionExtension
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView
{
    public static class MainRenderingElementPositionExtension
    {
        // RVA: 0x181E384
        public static bool IsLineHead(MainRenderingElementPosition position)
        {
            return position == MainRenderingElementPosition.LineHead ||
                   position == MainRenderingElementPosition.LineHeadTail;
        }

        // RVA: 0x181E39C
        public static bool IsLineTail(MainRenderingElementPosition position)
        {
            return position == MainRenderingElementPosition.LineTail ||
                   position == MainRenderingElementPosition.LineHeadTail;
        }

        // RVA: 0x181A5E4
        public static MainRenderingElementPosition PositionAtIndex(
            MainRenderingElementPosition position,
            int index,
            int length)
        {
            if (index == 0)
            {
                if (length == 1)
                {
                    return position;
                }

                return IsLineHead(position)
                    ? MainRenderingElementPosition.LineHead
                    : MainRenderingElementPosition.LineMiddle;
            }

            return index == length - 1 && IsLineTail(position)
                ? MainRenderingElementPosition.LineTail
                : MainRenderingElementPosition.LineMiddle;
        }
    }
}
