// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Graphics.BatchSettings
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ApplyToScene 在开启自动合批时对 m_StaticRoot 执行 StaticBatchingUtility.Combine。
// =============================================================================

using UnityEngine;

namespace Oz.Graphics
{
    public class BatchSettings
    {
        [SerializeField]
        public bool m_AutoBatching;
        [SerializeField]
        public GameObject m_StaticRoot;
        [SerializeField]
        public GameObject m_DynamicRoot;
        public bool AutoBatching { get; }
        public GameObject StaticRoot { get; }
        public GameObject DynamicRoot { get; }

        // RVA: 0x1892DC8
        public bool get_AutoBatching()
        {
            return m_AutoBatching;
        }

        // RVA: 0x1892DD0
        public GameObject get_StaticRoot()
        {
            return m_StaticRoot;
        }

        // RVA: 0x1892DD8
        public GameObject get_DynamicRoot()
        {
            return m_DynamicRoot;
        }

        // RVA: 0x1892DE0
        public void ApplyToScene()
        {
            if (m_AutoBatching && m_StaticRoot != null)
            {
                StaticBatchingUtility.Combine(m_StaticRoot);
            }
        }

        // RVA: 0x1892E74
        public BatchSettings()
        {
        }
    }
}
