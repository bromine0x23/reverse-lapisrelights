// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.BeginDragTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>开始拖拽事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class BeginDragTrigger : EventTrigger, IBeginDragHandler, IEventSystemHandler
    {
        // RVA: 0x13F8C40
        public void OnBeginDrag(PointerEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x13F8CEC
        public BeginDragTrigger()
        {
        }
    }
}
