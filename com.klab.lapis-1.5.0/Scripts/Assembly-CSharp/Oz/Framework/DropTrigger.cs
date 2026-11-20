// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.DropTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>释放拖拽对象事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class DropTrigger : EventTrigger, IDropHandler, IEventSystemHandler
    {
        // RVA: 0x13F8D80
        public void OnDrop(PointerEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x13F8D84
        public DropTrigger()
        {
        }
    }
}
