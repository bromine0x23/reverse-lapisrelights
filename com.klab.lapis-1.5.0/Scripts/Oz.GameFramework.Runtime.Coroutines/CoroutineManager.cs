// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Coroutines.dll
//  Oz.GameFramework.Runtime.Coroutines.CoroutineManager
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections;
using UnityEngine;

namespace Oz.GameFramework.Runtime.Coroutines
{
    /// <summary>
    /// 全局协程宿主：由 Launcher 挂载，其他模块通过静态方法启动协程，
    /// 避免依赖各自的 MonoBehaviour 生命周期。
    /// </summary>
    public class CoroutineManager : MonoBehaviour
    {
        private static MonoBehaviour m_Mono;

        // RVA: 0x2ED6C50
        public static Coroutine StartCoroutine(IEnumerator routine)
        {
            if (m_Mono == null)
            {
                return null;
            }
            return m_Mono.StartCoroutine(routine);
        }

        // RVA: 0x2ED6D10
        public static void StopCoroutine(IEnumerator routine)
        {
            if (m_Mono != null)
            {
                m_Mono.StopCoroutine(routine);
            }
        }

        // RVA: 0x2ED6DCC
        public static void StopCoroutine(Coroutine routine)
        {
            if (m_Mono != null)
            {
                m_Mono.StopCoroutine(routine);
            }
        }

        // RVA: 0x2ED6E88
        public static void StopAllCoroutines()
        {
            if (m_Mono != null)
            {
                m_Mono.StopAllCoroutines();
            }
        }

        // RVA: 0x2ED6F30
        protected void Awake()
        {
            m_Mono = this;
        }

        // RVA: 0x2ED6F84
        protected void OnDestroy()
        {
            StopAllCoroutines();
            m_Mono = null;
        }

        // RVA: 0x2ED6FD8
        public CoroutineManager()
        {
        }
    }
}
