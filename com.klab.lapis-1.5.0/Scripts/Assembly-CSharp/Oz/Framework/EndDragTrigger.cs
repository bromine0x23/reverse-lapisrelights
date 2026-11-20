// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.EndDragTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>结束拖拽事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class EndDragTrigger : EventTrigger, IEndDragHandler, IEventSystemHandler
    {
        // RVA: 0x13FCC9C
        public void OnEndDrag(PointerEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x13FCCA0
        public EndDragTrigger()
        {
        }
    }
}
