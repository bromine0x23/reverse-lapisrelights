// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Graphics.ShadowSettings
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ApplyToScene 仅写 QualitySettings.shadowDistance；Reset 复原为 12。
// =============================================================================

using UnityEngine;

namespace Oz.Graphics
{
    public class ShadowSettings
    {
        [SerializeField]
        private float m_ShadowDistance;
        [SerializeField]
        private bool m_UseGeometryShadow;
        [SerializeField]
        private bool m_ForceGeometryShadow;
        [SerializeField]
        private Mesh m_ShadowMesh;
        [SerializeField]
        private Material m_ShadowMaterial;
        [SerializeField]
        private bool m_UseRaycast;
        [SerializeField]
        private Transform m_RaycastOrigin;
        [SerializeField]
        private LayerMask m_CullingMask;
        [SerializeField]
        private float m_WorldHeight;
        [SerializeField]
        private float m_MaxHeight;
        [SerializeField]
        private Vector3 m_Rotation;
        [SerializeField]
        private AnimationCurve m_ScaleCurve;
        [SerializeField]
        private AnimationCurve m_OffsetCurve;
        [SerializeField]
        private AnimationCurve m_AlphaCurve;
        public float ShadowDistance { get; set; }
        public bool UseGeometryShadow { get; }
        public bool ForceGeometryShadow { get; }
        public Mesh ShadowMesh { get; }
        public Material ShadowMaterial { get; }
        public bool UseRaycast { get; }
        public Transform RaycastOrigin { get; }
        public LayerMask CullingMask { get; }
        public float WorldHeight { get; }
        public float MaxHeight { get; }
        public Vector3 Rotation { get; }
        public AnimationCurve ScaleCurve { get; }
        public AnimationCurve OffsetCurve { get; }
        public AnimationCurve AlphaCurve { get; }

        // RVA: 0x13D5F14
        public void ApplyToScene()
        {
            QualitySettings.shadowDistance = m_ShadowDistance;
        }

        // RVA: 0x13D5F20
        public void Reset()
        {
            QualitySettings.shadowDistance = 12f;
        }

        // RVA: 0x13D5F2C
        public float get_ShadowDistance()
        {
            return m_ShadowDistance;
        }

        // RVA: 0x13D5F34
        public void set_ShadowDistance(float value)
        {
            m_ShadowDistance = value;
        }

        // RVA: 0x13D5F3C
        public bool get_UseGeometryShadow()
        {
            return m_UseGeometryShadow;
        }

        // RVA: 0x13D5F44
        public bool get_ForceGeometryShadow()
        {
            return m_ForceGeometryShadow;
        }

        // RVA: 0x13D5F4C
        public Mesh get_ShadowMesh()
        {
            return m_ShadowMesh;
        }

        // RVA: 0x13D5F54
        public Material get_ShadowMaterial()
        {
            return m_ShadowMaterial;
        }

        // RVA: 0x13D5F5C
        public bool get_UseRaycast()
        {
            return m_UseRaycast;
        }

        // RVA: 0x13D5F64
        public Transform get_RaycastOrigin()
        {
            return m_RaycastOrigin;
        }

        // RVA: 0x13D5F6C
        public LayerMask get_CullingMask()
        {
            return m_CullingMask;
        }

        // RVA: 0x13D5F74
        public float get_WorldHeight()
        {
            return m_WorldHeight;
        }

        // RVA: 0x13D5F7C
        public float get_MaxHeight()
        {
            return m_MaxHeight;
        }

        // RVA: 0x13D5F84
        public Vector3 get_Rotation()
        {
            return m_Rotation;
        }

        // RVA: 0x13D5F90
        public AnimationCurve get_ScaleCurve()
        {
            return m_ScaleCurve;
        }

        // RVA: 0x13D5F98
        public AnimationCurve get_OffsetCurve()
        {
            return m_OffsetCurve;
        }

        // RVA: 0x13D5FA0
        public AnimationCurve get_AlphaCurve()
        {
            return m_AlphaCurve;
        }

        // RVA: 0x13D5FA8
        public ShadowSettings()
        {
            m_ShadowDistance = 15f;
            m_UseGeometryShadow = true;
            m_CullingMask = 0;
            m_Rotation = Vector3.zero;
            m_ScaleCurve = new AnimationCurve();
            m_OffsetCurve = new AnimationCurve();
            m_AlphaCurve = new AnimationCurve();
        }
    }
}
