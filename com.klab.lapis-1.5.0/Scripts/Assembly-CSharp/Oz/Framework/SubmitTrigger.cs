// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.SubmitTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>提交事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class SubmitTrigger : EventTrigger, ISubmitHandler, IEventSystemHandler
    {
        // RVA: 0x2EE76E8
        public void OnSubmit(BaseEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x2EE76F0
        public SubmitTrigger()
        {
        }
    }
}
