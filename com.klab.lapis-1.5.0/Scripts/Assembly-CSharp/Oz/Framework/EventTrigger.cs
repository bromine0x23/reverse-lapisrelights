// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.EventTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>
    /// UI 事件分发基类：持有一组 <see cref="UIEvent"/>，收到 uGUI 事件后依次回调。
    /// </summary>
    public class EventTrigger : MonoBehaviour
    {
        protected List<UIEvent> triggers;

        /// <summary>把事件转发给所有已注册的回调。</summary>
        // RVA: 0x13F8C44
        protected void Trigger(BaseEventData eventData)
        {
            for (int i = 0; i < triggers.Count; i++)
            {
                triggers[i].Callback(eventData);
            }
        }

        // RVA: 0x13FCE3C
        public void Add(UIEvent triggerEvent)
        {
            triggers.Add(triggerEvent);
        }

        // RVA: 0x13FF624
        public bool Remove(UIEvent triggerEvent)
        {
            return triggers.Remove(triggerEvent);
        }

        // RVA: 0x13FD080
        public int RemoveAll(Predicate<UIEvent> match)
        {
            return triggers.RemoveAll(match);
        }

        // RVA: 0x13F8CF0
        public EventTrigger()
        {
            triggers = new List<UIEvent>();
            // 基类 MonoBehaviour 的构造函数在此之后调用（IL2CPP 生成顺序）
        }
    }
}
