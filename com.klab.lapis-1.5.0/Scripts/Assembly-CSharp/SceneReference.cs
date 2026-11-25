// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  SceneReference
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using UnityEngine;

[Serializable]
public class SceneReference
{
    [SerializeField]
    public string GUID;
    public string DyamicName;
    public bool Dynamic;
    public string TypeName;
    public ReferenceObject RefObj;
    public UnityEngine.Object ResolvedObj;

    public string Identity
    {
        // RVA: 0x1949024
        get { return GUID; }
        // RVA: 0x194902C
        set
        {
            if (GUID != value)
            {
                RefObj = null;
                ResolvedObj = null;
            }
            GUID = value;
        }
    }

    public string Type
    {
        // RVA: 0x1949074
        get { return TypeName; }
        // RVA: 0x194907C
        set
        {
            if (TypeName != value)
            {
                ResolvedObj = null;
            }
            TypeName = value;
        }
    }

    // RVA: 0x194906C
    public void ClearCache()
    {
        RefObj = null;
        ResolvedObj = null;
    }

    // RVA: 0x19490BC
    public void ClearTypeCache()
    {
        ResolvedObj = null;
    }

    // RVA: 0x1544F4C
    public virtual T Resolve<T>()
    {
        if (ReferenceRoot.Instance == null)
        {
            return default(T);
        }

        if (!Dynamic && ResolvedObj != null)
        {
            return (T)(object)ResolvedObj;
        }

        RefObj = ReferenceRoot.Instance.Get(this);
        if (RefObj == null)
        {
            return default(T);
        }

        ResolvedObj = RefObj.Resolve<T>();
        return (T)(object)ResolvedObj;
    }

    // RVA: 0x19490C4
    public virtual UnityEngine.Object Resolve()
    {
        if (ReferenceRoot.Instance == null)
        {
            return null;
        }

        if (!Dynamic && ResolvedObj != null)
        {
            return ResolvedObj;
        }

        RefObj = ReferenceRoot.Instance.Get(this);
        if (RefObj == null)
        {
            return null;
        }

        ResolvedObj = null;
        if (string.IsNullOrEmpty(TypeName))
        {
            ResolvedObj = RefObj.Resolve();
        }
        else
        {
            ResolvedObj = RefObj.Resolve(TypeName);
        }
        return ResolvedObj;
    }

    // RVA: 0x1949268
    public virtual SceneReference Clone()
    {
        return MemberwiseClone() as SceneReference;
    }

    // RVA: 0x19492F4
    public SceneReference()
    {
        GUID = string.Empty;
        DyamicName = string.Empty;
        TypeName = string.Empty;
    }
}
