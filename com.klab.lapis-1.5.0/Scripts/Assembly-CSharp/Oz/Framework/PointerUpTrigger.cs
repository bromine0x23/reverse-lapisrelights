// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.PointerUpTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>指针抬起事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class PointerUpTrigger : EventTrigger, IPointerUpHandler, IEventSystemHandler
    {
        // RVA: 0x2EE5B98
        public void OnPointerUp(PointerEventData eventData)
        {
            if (eventData.pointerId == 0)
            {
                Trigger(eventData);
            }
        }

        // RVA: 0x2EE5BBC
        public PointerUpTrigger()
        {
        }
    }
}
