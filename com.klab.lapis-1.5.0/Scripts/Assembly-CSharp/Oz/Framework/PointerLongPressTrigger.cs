// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.PointerLongPressTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>
    /// 长按触发器。按下后延时 <see cref="StartAfter"/> 秒回调，回调时
    /// <see cref="PointerEventData.clickCount"/> 为 1；若在延时内抬起，则立即回调且 clickCount 为 0，
    /// 由回调方据此区分“长按”与“点击”。
    /// </summary>
    public class PointerLongPressTrigger : EventTrigger, IPointerDownHandler, IEventSystemHandler, IPointerUpHandler
    {
        public float StartAfter;

        private Coroutine m_Coroutine;
        private PointerEventData m_PointerEventData;

        // RVA: 0x2EE5500
        public void OnPointerDown(PointerEventData eventData)
        {
            if (eventData.pointerId == 0)
            {
                if (m_Coroutine != null)
                {
                    StopCoroutine(m_Coroutine);
                }
                m_PointerEventData = eventData;
                m_Coroutine = StartCoroutine(OnPointerLongPress());
            }
        }

        // RVA: 0x2EE556C
        public void OnPointerUp(PointerEventData eventData)
        {
            if (m_Coroutine != null)
            {
                StopCoroutine(m_Coroutine);
                m_Coroutine = null;
            }
            if (m_PointerEventData != null)
            {
                m_PointerEventData.clickCount = 0;
                Trigger(m_PointerEventData);
                m_PointerEventData = null;
            }
        }

        // RVA: 0x2EE55C0（状态机 MoveNext: 0x2EE56C8）
        public virtual IEnumerator OnPointerLongPress()
        {
            yield return new WaitForSeconds(StartAfter);
            if (m_PointerEventData != null)
            {
                int clickCount = m_PointerEventData.clickCount;
                m_PointerEventData.clickCount = 1;
                Trigger(m_PointerEventData);
                m_PointerEventData.clickCount = clickCount;
            }
        }

        // RVA: 0x2EE565C
        private void OnApplicationFocus(bool focus)
        {
            if (!focus)
            {
                if (m_Coroutine != null)
                {
                    StopCoroutine(m_Coroutine);
                    m_Coroutine = null;
                }
                if (m_PointerEventData != null)
                {
                    m_PointerEventData.clickCount = 0;
                    Trigger(m_PointerEventData);
                    m_PointerEventData = null;
                }
            }
        }

        // RVA: 0x2EE56B4
        public PointerLongPressTrigger()
        {
            StartAfter = 0.5f;
        }
    }
}
