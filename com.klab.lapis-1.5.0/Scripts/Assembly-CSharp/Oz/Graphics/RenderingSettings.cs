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
        [SerializeField]
        private AmbientMode m_AmbientMode;
        [SerializeField]
        private Color m_AmbientGroundColor;
        [SerializeField]
        private Color m_AmbientEquatorColor;
        [SerializeField]
        private Color m_AmbientSkyColor;
        [SerializeField]
        private float m_AmbientIntensity;
        [SerializeField]
        private bool m_Fog;
        [SerializeField]
        private FogMode m_FogMode;
        [SerializeField]
        private Color m_FogColor;
        [SerializeField]
        private float m_FogDensity;
        [SerializeField]
        private float m_LinearFogStart;
        [SerializeField]
        private float m_LinearFogEnd;
        public AmbientMode AmbientMode { get; }
        public Color AmbientGroundColor { get; }
        public Color AmbientEquatorColor { get; }
        public Color AmbientSkyColor { get; }
        public float AmbientIntensity { get; }
        public bool Fog { get; }
        public FogMode FogMode { get; }
        public Color FogColor { get; }
        public float FogDensity { get; }
        public float LinearFogStart { get; }
        public float LinearFogEnd { get; }

        // RVA: 0x1892E7C
        public AmbientMode get_AmbientMode()
        {
            return AmbientMode;
        }

        // RVA: 0x1892E84
        public Color get_AmbientGroundColor()
        {
            return m_AmbientGroundColor;
        }

        // RVA: 0x1892E90
        public Color get_AmbientEquatorColor()
        {
            return m_AmbientEquatorColor;
        }

        // RVA: 0x1892E9C
        public Color get_AmbientSkyColor()
        {
            return m_AmbientSkyColor;
        }

        // RVA: 0x1892EA8
        public float get_AmbientIntensity()
        {
            return m_AmbientIntensity;
        }

        // RVA: 0x1892EB0
        public bool get_Fog()
        {
            return m_Fog;
        }

        // RVA: 0x1892EB8
        public FogMode get_FogMode()
        {
            return m_FogMode;
        }

        // RVA: 0x1892EC0
        public Color get_FogColor()
        {
            return m_FogColor;
        }

        // RVA: 0x1892ECC
        public float get_FogDensity()
        {
            return m_FogDensity;
        }

        // RVA: 0x1892ED4
        public float get_LinearFogStart()
        {
            return m_LinearFogStart;
        }

        // RVA: 0x1892EDC
        public float get_LinearFogEnd()
        {
            return m_LinearFogEnd;
        }

        // RVA: 0x1892EE4
        public void ApplyToScene()
        {
            RenderSettings.ambientMode = m_AmbientMode;
            RenderSettings.ambientGroundColor = m_AmbientGroundColor;
            RenderSettings.ambientEquatorColor = m_AmbientEquatorColor;
            RenderSettings.ambientSkyColor = m_AmbientSkyColor;
            RenderSettings.ambientIntensity = m_AmbientIntensity;
            RenderSettings.fog = m_Fog;
            RenderSettings.fogMode = m_FogMode;
            RenderSettings.fogColor = m_FogColor;
            RenderSettings.fogDensity = m_FogDensity;
            RenderSettings.fogStartDistance = m_LinearFogStart;
            RenderSettings.fogEndDistance = m_LinearFogEnd;
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
