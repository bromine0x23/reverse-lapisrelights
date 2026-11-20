// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.SelectTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>被选中事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class SelectTrigger : EventTrigger, ISelectHandler, IEventSystemHandler
    {
        // RVA: 0x2EE5D30
        public void OnSelect(BaseEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x2EE5D38
        public SelectTrigger()
        {
        }
    }
}
