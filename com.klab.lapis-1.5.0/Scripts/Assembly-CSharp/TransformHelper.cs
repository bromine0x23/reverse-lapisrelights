// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  TransformHelper
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;

public static class TransformHelper
{
    // RVA: 0x14555B8
    public static void SetParentLocalScale(Transform source, Transform parent, bool worldPositionStays = false)
    {
        Vector3 localScale = source.localScale;
        source.SetParent(parent, worldPositionStays);
        source.localScale = localScale;
    }

    // RVA: 0x1455638
    public static void SyncTransform(Transform source, Transform destination)
    {
        source.position = destination.position;
        source.rotation = destination.rotation;
    }

    // RVA: 0x1455690
    public static Quaternion GetRotation(Matrix4x4 matrix)
    {
        float s = Mathf.Sqrt(1f + matrix.m00 + matrix.m11 + matrix.m22) * 0.5f;
        float inv = 1f / (4f * s);
        return new Quaternion(
            (matrix.m21 - matrix.m12) * inv,
            (matrix.m02 - matrix.m20) * inv,
            (matrix.m10 - matrix.m01) * inv,
            s);
    }

    // RVA: 0x145578C
    public static Vector3 GetPostion(Matrix4x4 matrix)
    {
        return new Vector3(matrix.m03, matrix.m13, matrix.m23);
    }

    // RVA: 0x14557C8
    public static Vector3 GetScale(Matrix4x4 matrix)
    {
        return new Vector3(
            Mathf.Sqrt(matrix.m00 * matrix.m00 + matrix.m01 * matrix.m01 + matrix.m02 * matrix.m02),
            Mathf.Sqrt(matrix.m10 * matrix.m10 + matrix.m11 * matrix.m11 + matrix.m12 * matrix.m12),
            Mathf.Sqrt(matrix.m20 * matrix.m20 + matrix.m21 * matrix.m21 + matrix.m22 * matrix.m22));
    }
}
