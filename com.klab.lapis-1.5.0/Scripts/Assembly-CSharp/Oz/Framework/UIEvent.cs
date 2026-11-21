// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.UIEvent
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>UI 事件的数据载体（由 EventTrigger 等派发）。</summary>
    public class UIEvent
    {
        /// <summary>
        /// 事件回调入口。元数据中没有 IL 方法体（RVA 为空），
        /// 由派生类型重写实现。
        /// </summary>
        public virtual void Callback(BaseEventData baseEventData)
        {
        }

        // RVA: 0x2EEA1E4
        public UIEvent()
        {
        }
    }
}
