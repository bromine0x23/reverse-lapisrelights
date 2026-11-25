// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  EyeDirection
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：眉/眼骨骼名与高光属性名取自 stringliteral（EYE_GEO 等）；
//        CustomLateUpdate 的轴向混合按反汇编结构重建。
// =============================================================================

using Oz.ActorModule;
using UnityEngine;

public class EyeDirection : MonoBehaviour
{
    private static readonly float defaultRotateAngle = -0.8f;

    private Transform eyeRoot;
    private GameObject eyeLeft;
    private GameObject eyeRight;
    private GameObject highlightTargetObject;
    private EyeSettings setting;
    private Vector3 offsetLeft;
    private Vector3 rotateLeft;
    private Vector3 offsetRight;
    private Vector3 rotateRight;
    private Renderer highlightRenderer;
    private MaterialPropertyBlock m_MaterialPropertyBlock;

    public MaterialPropertyBlock MaterialPropertyBlock
    {
        // RVA: 0x17501A4
        get
        {
            if (m_MaterialPropertyBlock == null)
            {
                m_MaterialPropertyBlock = new MaterialPropertyBlock();
            }
            return m_MaterialPropertyBlock;
        }
    }

    public bool IsLooking { get; set; }

    public GameObject TargetObject { get; set; }

    // RVA: 0x1750234
    public void ResetTarget(bool flg)
    {
        IsLooking = flg;
        if (flg)
        {
            return;
        }

        eyeRight.transform.localPosition = offsetRight;
        eyeLeft.transform.localPosition = offsetLeft;

        Quaternion rotation = Quaternion.identity;
        rotation.eulerAngles = rotateRight;
        eyeRight.transform.localRotation = rotation;
        rotation.eulerAngles = rotateLeft;
        eyeLeft.transform.localRotation = rotation;
    }

    // RVA: 0x17503BC
    public void SetTarget(GameObject target)
    {
        TargetObject = target;
        ResetTarget(target != null);
    }

    // RVA: 0x1750444
    public void SetHighlightTarget(GameObject target)
    {
        highlightTargetObject = target;
    }

    // RVA: 0x175044C
    public void SetHighlight(float highlight)
    {
        highlightRenderer.GetPropertyBlock(MaterialPropertyBlock);
        MaterialPropertyBlock.SetFloat("_HighLight", 1f - highlight);
        highlightRenderer.SetPropertyBlock(MaterialPropertyBlock);
    }

    // RVA: 0x1750500
    public void SetEyeScale(float scale)
    {
        Vector3 localScale = Vector3.one * Mathf.Max(1f - scale, 0.001f);
        eyeRight.transform.localScale = localScale;
        eyeLeft.transform.localScale = localScale;
    }

    // RVA: 0x1750634
    public void Init(SkeletonSystem skeletonSystem, AvatarSystem avatarSystem, EyeSettings eyeSettings)
    {
        setting = eyeSettings;
        eyeRoot = skeletonSystem.GetBone("Head_PartsRooT_EXJ");

        Transform left = skeletonSystem.GetBone("EyeL_01");
        if (left != null)
        {
            eyeLeft = left.gameObject;
            offsetLeft = eyeLeft.transform.localPosition;
            rotateLeft = eyeLeft.transform.localEulerAngles;
        }

        Transform right = skeletonSystem.GetBone("EyeR_01");
        if (right != null)
        {
            eyeRight = right.gameObject;
            offsetRight = eyeRight.transform.localPosition;
            rotateRight = eyeRight.transform.localEulerAngles;
        }

        if (avatarSystem.GetAvatarPart(4) != null)
        {
            highlightRenderer = avatarSystem.GetAvatarPart(4).FindRenderer(
                t => t.name.ToUpper().Equals("EYE_GEO"));
        }
    }

    // RVA: 0x17508F0
    public void CustomLateUpdate()
    {
        if (highlightTargetObject != null)
        {
            Vector3 targetPosition = highlightTargetObject.transform.position;
            Vector3 eyePosition = eyeRoot.transform.position;
            Vector3 local = eyeRoot.transform.InverseTransformVector(targetPosition - eyePosition).normalized;
            float dot = Vector3.Dot(local, Vector3.right);

            if (highlightRenderer != null)
            {
                highlightRenderer.GetPropertyBlock(MaterialPropertyBlock);
                MaterialPropertyBlock.SetFloat("_HighLight", -dot);
                highlightRenderer.SetPropertyBlock(MaterialPropertyBlock);
            }
        }
        else if (highlightRenderer != null)
        {
            highlightRenderer.GetPropertyBlock(MaterialPropertyBlock);
            MaterialPropertyBlock.SetFloat("_HighLight", defaultRotateAngle);
            highlightRenderer.SetPropertyBlock(MaterialPropertyBlock);
        }

        if (TargetObject == null || !IsLooking || eyeLeft == null || eyeRight == null)
        {
            return;
        }

        Vector2 rightAngle = GetTargetAngle(TargetObject.transform, eyeRight.transform);
        Vector2 leftAngle = GetTargetAngle(TargetObject.transform, eyeLeft.transform);

        ApplyEye(rightAngle, eyeRight, offsetRight, rotateRight, true);
        ApplyEye(leftAngle, eyeLeft, offsetLeft, rotateLeft, false);
    }

    // 说明：按反汇编结构重建的轴向混合；限值取自 EyeSettings 的 maxIn/maxOut/maxUp/maxDown。
    // 右眼与左眼对 maxIn/maxOut 的符号选择相反，且 maxIn/maxUp 的 z 分量在右眼取反。
    private void ApplyEye(Vector2 angle, GameObject eye, Vector3 offset, Vector3 rotate, bool isRight)
    {
        bool useInner = isRight ? angle.x > 0f : angle.x < 0f;
        Vector3 horizontal = useInner ? setting.MaxIn : setting.MaxOut;
        Vector3 vertical = angle.y < 0f ? setting.MaxUp : setting.MaxDown;

        float h = angle.x / setting.MoveRatio;
        float v = angle.y / setting.MoveRatio;

        float hz = (isRight && angle.x > 0f) ? -horizontal.z : horizontal.z;
        float vz = (isRight && angle.y < 0f) ? -vertical.z : vertical.z;

        Vector3 position = offset;
        position.x += h * horizontal.x;
        position.y += v * vertical.x;
        position.z += (h * hz + v * vz) * 0.5f;
        eye.transform.localPosition = position;

        Quaternion rotation = Quaternion.identity;
        rotation.eulerAngles = new Vector3(rotate.x, rotate.y + h * horizontal.y, rotate.z - v * vertical.y);
        eye.transform.localRotation = rotation;
    }

    // RVA: 0x1751044
    private Vector2 GetTargetAngle(Transform target, Transform eye)
    {
        Vector3 direction = target.position - eye.position;
        Vector3 local = eyeRoot.transform.worldToLocalMatrix.MultiplyVector(direction).normalized;

        return new Vector2(
            Mathf.Clamp(Mathf.Atan2(local.x, local.z) * Mathf.Rad2Deg, -setting.MoveRatio, setting.MoveRatio),
            Mathf.Clamp(Mathf.Atan2(local.y, local.z) * Mathf.Rad2Deg, -setting.MoveRatio, setting.MoveRatio));
    }

    // RVA: 0x175129C
    public EyeDirection()
    {
        IsLooking = true;
    }

    // RVA: 0x17512AC
    static EyeDirection()
    {
    }
}
