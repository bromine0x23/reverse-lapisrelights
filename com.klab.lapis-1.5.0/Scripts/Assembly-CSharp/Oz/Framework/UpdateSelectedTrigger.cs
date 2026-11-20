// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.UpdateSelectedTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>选中项刷新事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class UpdateSelectedTrigger : EventTrigger, IUpdateSelectedHandler, IEventSystemHandler
    {
        // RVA: 0x2EEBED4
        public void OnUpdateSelected(BaseEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x2EEBEDC
        public UpdateSelectedTrigger()
        {
        }
    }
}
