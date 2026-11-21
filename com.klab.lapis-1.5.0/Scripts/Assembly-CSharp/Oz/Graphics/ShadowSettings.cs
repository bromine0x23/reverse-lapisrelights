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
        [field: SerializeField]
        public float ShadowDistance { get; set; }
        [field: SerializeField]
        public bool UseGeometryShadow { get; private set; }
        [field: SerializeField]
        public bool ForceGeometryShadow { get; private set; }
        [field: SerializeField]
        public Mesh ShadowMesh { get; private set; }
        [field: SerializeField]
        public Material ShadowMaterial { get; private set; }
        [field: SerializeField]
        public bool UseRaycast { get; private set; }
        [field: SerializeField]
        public Transform RaycastOrigin { get; private set; }
        [field: SerializeField]
        public LayerMask CullingMask { get; private set; }
        [field: SerializeField]
        public float WorldHeight { get; private set; }
        [field: SerializeField]
        public float MaxHeight { get; private set; }
        [field: SerializeField]
        public Vector3 Rotation { get; private set; }
        [field: SerializeField]
        public AnimationCurve ScaleCurve { get; private set; }
        [field: SerializeField]
        public AnimationCurve OffsetCurve { get; private set; }
        [field: SerializeField]
        public AnimationCurve AlphaCurve { get; private set; }

        // RVA: 0x13D5F14
        public void ApplyToScene()
        {
            QualitySettings.shadowDistance = ShadowDistance;
        }

        // RVA: 0x13D5F20
        public void Reset()
        {
            QualitySettings.shadowDistance = 12f;
        }

        // RVA: 0x13D5FA8
        public ShadowSettings()
        {
            ShadowDistance = 15f;
            UseGeometryShadow = true;
            CullingMask = 0;
            Rotation = Vector3.zero;
            ScaleCurve = new AnimationCurve();
            OffsetCurve = new AnimationCurve();
            AlphaCurve = new AnimationCurve();
        }
    }
}
