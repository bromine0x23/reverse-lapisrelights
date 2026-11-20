// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Graphics.SceneEnvironment
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Awake/OnEnable/OnDisable 控制 ApplyOnEnable / ResetOnDisable 语义；
//        Apply 依次应用 Rendering/Shader/Shadow 与后处理；
//        LateUpdate 维护场景中的几何投影（Raycast 取地面高度 + 曲线驱动缩放）。
// =============================================================================

using System.Collections.Generic;
using SeanLib.PostProcessV2;
using UnityEngine;
using Oz.Utility;

namespace Oz.Graphics
{
    public class SceneEnvironment : MonoBehaviour
    {
        public static bool ForbidApplyOnFirstEnable;
        [SerializeField]
        private bool m_ApplyOnFirstEnable;
        [SerializeField]
        private BatchSettings m_BatchSettings;
        [SerializeField]
        private RenderingSettings m_RenderingSettings;
        [SerializeField]
        private ShadowSettings m_ShadowSettings;
        [SerializeField]
        private ShaderSettings m_ShaderSettings;
        [SerializeField]
        private SettingsProfile m_SettingsProfile;
        [SerializeField]
        private SeanPostProcessLayer m_PostProcessLayer;
        [SerializeField]
        private LightSettings m_LightSettings;
        public bool ApplyOnEnable { get; private set; }
        public bool ResetOnDisable { get; private set; }
        public BatchSettings BatchSettings { get; }
        public RenderingSettings RenderingSettings { get; }
        public ShadowSettings ShadowSettings { get; }
        public ShaderSettings ShaderSettings { get; }
        public SettingsProfile SettingsProfile { get; }
        public SeanPostProcessLayer PostProcessLayer { get; }
        public LightSettings LightSettings { get; }

        // RVA: 0x1893050
        public bool get_ApplyOnEnable()
        {
            return ApplyOnEnable;
        }

        // RVA: 0x1893058
        private void set_ApplyOnEnable(bool value)
        {
            ApplyOnEnable = value;
        }

        // RVA: 0x1893064
        public bool get_ResetOnDisable()
        {
            return ResetOnDisable;
        }

        // RVA: 0x189306C
        private void set_ResetOnDisable(bool value)
        {
            ResetOnDisable = value;
        }

        // RVA: 0x1893078
        public BatchSettings get_BatchSettings()
        {
            return m_BatchSettings;
        }

        // RVA: 0x1893080
        public RenderingSettings get_RenderingSettings()
        {
            return m_RenderingSettings;
        }

        // RVA: 0x1893088
        public ShadowSettings get_ShadowSettings()
        {
            return m_ShadowSettings;
        }

        // RVA: 0x1893090
        public ShaderSettings get_ShaderSettings()
        {
            return m_ShaderSettings;
        }

        // RVA: 0x1893098
        public SettingsProfile get_SettingsProfile()
        {
            return m_SettingsProfile;
        }

        // RVA: 0x18930A0
        public SeanPostProcessLayer get_PostProcessLayer()
        {
            return m_PostProcessLayer;
        }

        // RVA: 0x1893184
        public LightSettings get_LightSettings()
        {
            return m_LightSettings;
        }

        // RVA: 0x189318C
        private void Awake()
        {
            if (m_ApplyOnFirstEnable)
            {
                ApplyOnEnable = !ForbidApplyOnFirstEnable;
                m_ApplyOnFirstEnable = !ForbidApplyOnFirstEnable;
            }
            else
            {
                ApplyOnEnable = false;
            }

            ResetOnDisable = m_ApplyOnFirstEnable;

            if (Application.isPlaying)
            {
                m_BatchSettings.ApplyToScene();
            }
        }

        // RVA: 0x1893270
        private void OnEnable()
        {
            if (ApplyOnEnable)
            {
                Apply();
            }
            ApplyOnEnable = true;
        }

        // RVA: 0x18932F8
        private void OnDisable()
        {
            if (ResetOnDisable)
            {
                m_RenderingSettings.Reset();
                m_ShaderSettings.Reset();
                m_ShadowSettings.Reset();
                m_LightSettings.Clear();
            }
            ResetOnDisable = true;
        }

        // RVA: 0x18932A4
        public void Apply()
        {
            m_RenderingSettings.ApplyToScene();
            m_ShaderSettings.ApplyToScene();
            m_ShadowSettings.ApplyToScene();
            ApplyPostProcess(m_SettingsProfile);
        }

        // RVA: 0x1893364
        public void ApplyPostProcess(SettingsProfile settingsProfile)
        {
            if (PostProcessLayer == null || PostProcessLayer.volumeMachine == null)
            {
                return;
            }

            PostProcessLayer.volumeMachine.Default = settingsProfile;
            if (settingsProfile != null)
            {
                PostProcessLayer.SetRuntimeSetting(settingsProfile.setting);
            }
        }

        // RVA: 0x1893464
        private List<GeometricShadowCast> GetGeometricShadowCastInScene()
        {
            if (Application.isPlaying)
            {
                return GeometricShadowCast.geometricShadowCasts;
            }
            return new List<GeometricShadowCast>(Object.FindObjectsOfType<GeometricShadowCast>());
        }

        // RVA: 0x1893540
        private void Update()
        {
            if (m_LightSettings.UsePixelLights)
            {
                if (m_LightSettings.PixelLights.Count >= 1)
                {
                    m_LightSettings.SetLight1();
                    if (m_LightSettings.PixelLights.Count != 1)
                    {
                        m_LightSettings.SetLight2();
                    }
                }
            }
            else if (Shader.IsKeywordEnabled("PIXELLIGHT1") || Shader.IsKeywordEnabled("PIXELLIGHT2"))
            {
                m_LightSettings.Clear();
            }
        }

        // RVA: 0x1893618
        private void LateUpdate()
        {
            if (m_ShadowSettings == null)
            {
                return;
            }

            // 阴影关闭时清空所有几何投影
            if (!m_ShadowSettings.m_ForceGeometryShadow
                && (!m_ShadowSettings.m_UseGeometryShadow || QualitySettingUtil.GetShadows()))
            {
                List<GeometricShadowCast> casts = GetGeometricShadowCastInScene();
                for (int i = 0; i < casts.Count; i++)
                {
                    casts[i].meshFilter.sharedMesh = null;
                    casts[i].meshRenderer.sharedMaterial = null;
                }
                return;
            }

            List<GeometricShadowCast> shadowCasts = GetGeometricShadowCastInScene();
            if (shadowCasts == null)
            {
                return;
            }

            float worldHeight;
            if (m_ShadowSettings.m_UseRaycast && shadowCasts.Count >= 1 && m_ShadowSettings.m_RaycastOrigin != null)
            {
                Ray ray = new Ray(m_ShadowSettings.m_RaycastOrigin.position, -Vector3.up);
                worldHeight = 0f;

                RaycastHit hit;
                if (Physics.Raycast(ray, out hit, 10f, m_ShadowSettings.m_CullingMask))
                {
                    worldHeight = hit.point.y;
                }
            }
            else
            {
                worldHeight = m_ShadowSettings.m_WorldHeight;
            }

            for (int i = 0; i < shadowCasts.Count; i++)
            {
                GeometricShadowCast cast = shadowCasts[i];

                cast.meshFilter.sharedMesh = m_ShadowSettings.m_ShadowMesh;
                cast.meshRenderer.sharedMaterial = m_ShadowSettings.m_ShadowMaterial;

                Transform t = cast.transform;
                Vector3 parentPosition = t.parent.position;
                float parentY = t.parent.position.y;

                float h = Mathf.Clamp01((parentY - worldHeight) / m_ShadowSettings.m_MaxHeight);
                float scale = m_ShadowSettings.m_ScaleCurve.Evaluate(h);
                float offset = m_ShadowSettings.m_OffsetCurve.Evaluate(h);
                float alpha = m_ShadowSettings.m_AlphaCurve.Evaluate(h);

                MaterialPropertyBlock block = MaterialPropertyBlockHelper.GetPropertyBlock(cast.meshRenderer);
                block.SetVector("_Value", new Vector4(scale, offset, alpha, 0f));
                cast.meshRenderer.SetPropertyBlock(block);

                t.rotation = Quaternion.Euler(m_ShadowSettings.m_Rotation);
                t.position = new Vector3(parentPosition.x, worldHeight + 0.01f, parentPosition.z);
            }
        }

        // RVA: 0x1893B14
        public SceneEnvironment()
        {
            m_BatchSettings = new BatchSettings();
            m_RenderingSettings = new RenderingSettings();
            m_ShadowSettings = new ShadowSettings();
            m_ShaderSettings = new ShaderSettings();
            m_LightSettings = new LightSettings();
        }

        // RVA: 0x1893BF8
        static SceneEnvironment()
        {
        }
    }
}
