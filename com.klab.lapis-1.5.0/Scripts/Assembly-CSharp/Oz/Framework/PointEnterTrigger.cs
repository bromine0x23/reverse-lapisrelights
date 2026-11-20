// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.PointEnterTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>指针进入事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class PointEnterTrigger : EventTrigger, IPointerEnterHandler, IEventSystemHandler
    {
        // RVA: 0x2EE5488
        public void OnPointerEnter(PointerEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x2EE5490
        public PointEnterTrigger()
        {
        }
    }
}
