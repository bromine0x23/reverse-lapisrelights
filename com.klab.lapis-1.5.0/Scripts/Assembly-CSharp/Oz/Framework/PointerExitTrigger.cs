// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.PointerExitTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>指针离开事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class PointerExitTrigger : EventTrigger, IPointerExitHandler, IEventSystemHandler
    {
        // RVA: 0x2EE54F0
        public void OnPointerExit(PointerEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x2EE54F8
        public PointerExitTrigger()
        {
        }
    }
}
