// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.PointerRepeatTrigger
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Oz.Framework
{
    /// <summary>
    /// 连按触发器：按住后先等待 <see cref="StartAfter"/>，随后以
    /// <see cref="StartInternal"/> / 加速档位 的间隔重复回调，档位随次数增长直到
    /// <see cref="FrequencyMax"/>。
    /// </summary>
    public class PointerRepeatTrigger : EventTrigger, IPointerDownHandler, IEventSystemHandler, IPointerUpHandler
    {
        public float StartAfter;
        public float StartInternal;
        public int FrequencyStep;
        public int FrequencyMax;

        private Coroutine _coroutine;

        // RVA: 0x2EE5820
        public void OnPointerDown(PointerEventData eventData)
        {
            if (eventData.pointerId == 0)
            {
                if (_coroutine != null)
                {
                    StopCoroutine(_coroutine);
                }
                _coroutine = StartCoroutine(OnPointerRepeat(eventData));
            }
        }

        // RVA: 0x2EE588C
        public void OnPointerUp(PointerEventData eventData)
        {
            if (_coroutine != null)
            {
                StopCoroutine(_coroutine);
                _coroutine = null;
            }
        }

        // RVA: 0x2EE58BC（状态机 MoveNext: 0x2EE59B8）
        public virtual IEnumerator OnPointerRepeat(PointerEventData eventData)
        {
            yield return new WaitForSeconds(StartAfter);
            int count = 0;
            while (true)
            {
                count++;
                Trigger(eventData);
                int level = Mathf.Min((FrequencyStep + count) / FrequencyStep, FrequencyMax);
                yield return new WaitForSeconds(StartInternal / level);
            }
        }

        // RVA: 0x2EE5964
        private void OnApplicationFocus(bool focus)
        {
            if (!focus && _coroutine != null)
            {
                StopCoroutine(_coroutine);
                _coroutine = null;
            }
        }

        // RVA: 0x2EE599C
        public PointerRepeatTrigger()
        {
            StartAfter = 0.5f;
            StartInternal = 0.25f;
            FrequencyStep = 5;
            FrequencyMax = 5;
        }
    }
}
