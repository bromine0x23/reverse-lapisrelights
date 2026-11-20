// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.DeselectTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>取消选中事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class DeselectTrigger : EventTrigger, IDeselectHandler, IEventSystemHandler
    {
        // RVA: 0x13F8D70
        public void OnDeselect(BaseEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x13F8D74
        public DeselectTrigger()
        {
        }
    }
}
