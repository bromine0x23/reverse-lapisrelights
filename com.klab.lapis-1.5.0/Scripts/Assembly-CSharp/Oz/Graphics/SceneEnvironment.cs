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
        public bool ApplyOnEnable { get; private set; }
        public bool ResetOnDisable { get; private set; }
        [field: SerializeField]
        public BatchSettings BatchSettings { get; private set; }
        [field: SerializeField]
        public RenderingSettings RenderingSettings { get; private set; }
        [field: SerializeField]
        public ShadowSettings ShadowSettings { get; private set; }
        [field: SerializeField]
        public ShaderSettings ShaderSettings { get; private set; }
        [field: SerializeField]
        public SettingsProfile SettingsProfile { get; private set; }
        [field: SerializeField]
        public SeanPostProcessLayer PostProcessLayer { get; private set; }
        [field: SerializeField]
        public LightSettings LightSettings { get; private set; }

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
                BatchSettings.ApplyToScene();
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
                RenderingSettings.Reset();
                ShaderSettings.Reset();
                ShadowSettings.Reset();
                LightSettings.Clear();
            }
            ResetOnDisable = true;
        }

        // RVA: 0x18932A4
        public void Apply()
        {
            RenderingSettings.ApplyToScene();
            ShaderSettings.ApplyToScene();
            ShadowSettings.ApplyToScene();
            ApplyPostProcess(SettingsProfile);
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
            if (LightSettings.UsePixelLights)
            {
                if (LightSettings.PixelLights.Count >= 1)
                {
                    LightSettings.SetLight1();
                    if (LightSettings.PixelLights.Count != 1)
                    {
                        LightSettings.SetLight2();
                    }
                }
            }
            else if (Shader.IsKeywordEnabled("PIXELLIGHT1") || Shader.IsKeywordEnabled("PIXELLIGHT2"))
            {
                LightSettings.Clear();
            }
        }

        // RVA: 0x1893618
        private void LateUpdate()
        {
            if (ShadowSettings == null)
            {
                return;
            }

            // 阴影关闭时清空所有几何投影
            if (!ShadowSettings.m_ForceGeometryShadow
                && (!ShadowSettings.m_UseGeometryShadow || QualitySettingUtil.GetShadows()))
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
            if (ShadowSettings.m_UseRaycast && shadowCasts.Count >= 1 && ShadowSettings.m_RaycastOrigin != null)
            {
                Ray ray = new Ray(ShadowSettings.m_RaycastOrigin.position, -Vector3.up);
                worldHeight = 0f;

                RaycastHit hit;
                if (Physics.Raycast(ray, out hit, 10f, ShadowSettings.m_CullingMask))
                {
                    worldHeight = hit.point.y;
                }
            }
            else
            {
                worldHeight = ShadowSettings.m_WorldHeight;
            }

            for (int i = 0; i < shadowCasts.Count; i++)
            {
                GeometricShadowCast cast = shadowCasts[i];

                cast.meshFilter.sharedMesh = ShadowSettings.m_ShadowMesh;
                cast.meshRenderer.sharedMaterial = ShadowSettings.m_ShadowMaterial;

                Transform t = cast.transform;
                Vector3 parentPosition = t.parent.position;
                float parentY = t.parent.position.y;

                float h = Mathf.Clamp01((parentY - worldHeight) / ShadowSettings.m_MaxHeight);
                float scale = ShadowSettings.m_ScaleCurve.Evaluate(h);
                float offset = ShadowSettings.m_OffsetCurve.Evaluate(h);
                float alpha = ShadowSettings.m_AlphaCurve.Evaluate(h);

                MaterialPropertyBlock block = MaterialPropertyBlockHelper.GetPropertyBlock(cast.meshRenderer);
                block.SetVector("_Value", new Vector4(scale, offset, alpha, 0f));
                cast.meshRenderer.SetPropertyBlock(block);

                t.rotation = Quaternion.Euler(ShadowSettings.m_Rotation);
                t.position = new Vector3(parentPosition.x, worldHeight + 0.01f, parentPosition.z);
            }
        }

        // RVA: 0x1893B14
        public SceneEnvironment()
        {
            BatchSettings = new BatchSettings();
            RenderingSettings = new RenderingSettings();
            ShadowSettings = new ShadowSettings();
            ShaderSettings = new ShaderSettings();
            LightSettings = new LightSettings();
        }

        // RVA: 0x1893BF8
        static SceneEnvironment()
        {
        }
    }
}
