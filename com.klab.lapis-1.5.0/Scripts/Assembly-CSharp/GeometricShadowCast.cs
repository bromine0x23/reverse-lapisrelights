// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  GeometricShadowCast
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  运行时维护全部几何阴影投射体，供阴影渲染统一遍历。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

public class GeometricShadowCast : MonoBehaviour
{
    public static List<GeometricShadowCast> geometricShadowCasts;
    public MeshFilter meshFilter;
    public MeshRenderer meshRenderer;

    // RVA: 0x192E1D0
    private void Awake()
    {
        if (meshFilter == null)
        {
            meshFilter = GetComponent<MeshFilter>();
        }
        if (meshRenderer == null)
        {
            meshRenderer = GetComponent<MeshRenderer>();
        }
        geometricShadowCasts.Add(this);
    }

    // RVA: 0x192E2F4
    private void OnDestroy()
    {
        geometricShadowCasts.Remove(this);
    }

    // RVA: 0x192E378
    public GeometricShadowCast()
    {
    }

    // RVA: 0x192E380
    static GeometricShadowCast()
    {
        geometricShadowCasts = new List<GeometricShadowCast>();
    }
}
