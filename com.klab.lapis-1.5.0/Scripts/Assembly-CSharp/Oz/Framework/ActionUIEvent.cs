// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.ActionUIEvent
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine.Events;
using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>以 C# 委托形式挂接的 UI 事件。</summary>
    public class ActionUIEvent : UIEvent
    {
        public UnityAction<BaseEventData> callback;

        // RVA: 0x13F7010
        public ActionUIEvent()
        {
        }

        // RVA: 0x13F7018
        public ActionUIEvent(UnityAction<BaseEventData> callback)
        {
            this.callback = callback;
        }

        // RVA: 0x13F7044
        public override void Callback(BaseEventData data)
        {
            if (callback != null)
            {
                callback(data);
            }
        }
    }
}
