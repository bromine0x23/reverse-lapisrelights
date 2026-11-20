// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.InitializePotentialDragTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>拖拽初始化事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class InitializePotentialDragTrigger : EventTrigger, IInitializePotentialDragHandler, IEventSystemHandler
    {
        // RVA: 0x13FF698
        public void OnInitializePotentialDrag(PointerEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x13FF69C
        public InitializePotentialDragTrigger()
        {
        }
    }
}
