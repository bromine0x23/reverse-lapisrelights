// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Graphics.BatchSettings
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ApplyToScene 在开启自动合批时对 StaticRoot 执行 StaticBatchingUtility.Combine。
// =============================================================================

using UnityEngine;

namespace Oz.Graphics
{
    public class BatchSettings
    {
        [field: SerializeField]
        public bool AutoBatching { get; private set; }
        [field: SerializeField]
        public GameObject StaticRoot { get; private set; }
        [field: SerializeField]
        public GameObject DynamicRoot { get; private set; }

        // RVA: 0x1892DE0
        public void ApplyToScene()
        {
            if (AutoBatching && StaticRoot != null)
            {
                StaticBatchingUtility.Combine(StaticRoot);
            }
        }

        // RVA: 0x1892E74
        public BatchSettings()
        {
        }
    }
}
