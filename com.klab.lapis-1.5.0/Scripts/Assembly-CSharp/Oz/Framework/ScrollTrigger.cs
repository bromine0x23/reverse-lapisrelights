// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.ScrollTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>滚轮/滑动事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class ScrollTrigger : EventTrigger, IScrollHandler, IEventSystemHandler
    {
        // RVA: 0x2EE5D20
        public void OnScroll(PointerEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x2EE5D28
        public ScrollTrigger()
        {
        }
    }
}
