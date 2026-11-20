// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.CancelTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>取消事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class CancelTrigger : EventTrigger, ICancelHandler, IEventSystemHandler
    {
        // RVA: 0x13F8D60
        public void OnCancel(BaseEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x13F8D64
        public CancelTrigger()
        {
        }
    }
}
