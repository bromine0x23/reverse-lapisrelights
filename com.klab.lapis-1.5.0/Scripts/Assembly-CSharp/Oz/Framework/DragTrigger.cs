// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.DragTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>拖拽中事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class DragTrigger : EventTrigger, IDragHandler, IEventSystemHandler
    {
        // RVA: 0x13F8D78
        public void OnDrag(PointerEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x13F8D7C
        public DragTrigger()
        {
        }
    }
}
