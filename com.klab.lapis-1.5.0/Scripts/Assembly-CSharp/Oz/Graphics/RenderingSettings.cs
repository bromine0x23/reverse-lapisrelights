// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Graphics.RenderingSettings
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ApplyToScene 逐项写入 RenderSettings；Reset 复原环境光与雾。
// =============================================================================

using UnityEngine;

namespace Oz.Graphics
{
    public class RenderingSettings
    {
        [field: SerializeField]
        public AmbientMode AmbientMode { get; private set; }
        [field: SerializeField]
        public Color AmbientGroundColor { get; private set; }
        [field: SerializeField]
        public Color AmbientEquatorColor { get; private set; }
        [field: SerializeField]
        public Color AmbientSkyColor { get; private set; }
        [field: SerializeField]
        public float AmbientIntensity { get; private set; }
        [field: SerializeField]
        public bool Fog { get; private set; }
        [field: SerializeField]
        public FogMode FogMode { get; private set; }
        [field: SerializeField]
        public Color FogColor { get; private set; }
        [field: SerializeField]
        public float FogDensity { get; private set; }
        [field: SerializeField]
        public float LinearFogStart { get; private set; }
        [field: SerializeField]
        public float LinearFogEnd { get; private set; }

        // RVA: 0x1892EE4
        public void ApplyToScene()
        {
            RenderSettings.ambientMode = AmbientMode;
            RenderSettings.ambientGroundColor = AmbientGroundColor;
            RenderSettings.ambientEquatorColor = AmbientEquatorColor;
            RenderSettings.ambientSkyColor = AmbientSkyColor;
            RenderSettings.ambientIntensity = AmbientIntensity;
            RenderSettings.fog = Fog;
            RenderSettings.fogMode = FogMode;
            RenderSettings.fogColor = FogColor;
            RenderSettings.fogDensity = FogDensity;
            RenderSettings.fogStartDistance = LinearFogStart;
            RenderSettings.fogEndDistance = LinearFogEnd;
        }

        // RVA: 0x1892F90
        public void Reset()
        {
            RenderSettings.ambientMode = AmbientMode.Trilight;
            RenderSettings.ambientGroundColor = Color.black;
            RenderSettings.fog = false;
        }

        // RVA: 0x1892FC4
        public RenderingSettings()
        {
        }
    }
}
