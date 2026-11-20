// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.MoveTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>方向键移动事件触发器：转发给挂载的 <see cref="UIEvent"/> 回调。</summary>
    public class MoveTrigger : EventTrigger, IMoveHandler, IEventSystemHandler
    {
        // RVA: 0x1402E70
        public void OnMove(AxisEventData eventData)
        {
            Trigger(eventData);
        }

        // RVA: 0x1402E74
        public MoveTrigger()
        {
        }
    }
}
