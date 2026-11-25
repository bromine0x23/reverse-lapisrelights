// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ReferenceObject
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  场景引用组件：维护 SceneObject 数据、解析目标对象并回写场景。
// =============================================================================

using System;
using System.Text;
using UnityEngine;

[DisallowMultipleComponent]
[ExecuteInEditMode]
public class ReferenceObject : MonoBehaviour
{
    public SceneObject Data;

    public virtual Color color
    {
        // RVA: 0x1B723FC
        get { return Color.gray; }
    }

    public string GUID
    {
        // RVA: 0x1B725C0
        get { return Data.GUID; }
        // RVA: 0x1B725DC
        set { Data.GUID = value; }
    }

    // RVA: 0x1B72404
    private void Start()
    {
        TryInit();
    }

    // RVA: 0x1B72408
    public void TryInit()
    {
        if (string.IsNullOrEmpty(Data.GUID))
        {
            Data.GUID = Guid.NewGuid().ToString();
        }

        if (string.IsNullOrEmpty(Data.RefType))
        {
            Data.RefType = GetType().Name;
        }

        if (ReferenceRoot.Instance)
        {
            ReferenceRoot.Instance.Put(this);
        }
    }

    // RVA: 0x1544980
    public virtual T Resolve<T>()
    {
        return transform.GetComponent<T>();
    }

    // RVA: 0x1B72584
    public virtual UnityEngine.Object Resolve(string TypeName)
    {
        return transform.GetComponent(TypeName);
    }

    // RVA: 0x1B725B8
    public virtual UnityEngine.Object Resolve()
    {
        return gameObject;
    }

    // RVA: 0x1B725F8
    public virtual void SetSceneData()
    {
        Data.Name = gameObject.name;
        Data.Depth = 0;

        StringBuilder builder = new StringBuilder();
        Transform parent = transform.parent;
        while (parent != null)
        {
            if (builder.Length > 0)
            {
                builder.Insert(0, "/");
            }
            builder.Insert(0, parent.name);
            Data.Depth++;
            parent = parent.parent;
        }

        Data.ChildPath = builder.ToString();
        Data.Root = parent != null ? parent.name : string.Empty;

        Data.LocalPostion = transform.localPosition;
        Data.LocalRotation = transform.localRotation;
        Data.LocalScale = transform.localScale;
        Data.Postion = transform.position;
        Data.Rotation = transform.rotation;
        Data.Scale = transform.lossyScale;
        Data.Active = gameObject.activeSelf;
    }

    // RVA: 0x1B72940
    public virtual void PuToScene()
    {
        Data.state = SceneObjectState.placed;

        Vector3 localPosition = transform.localPosition;
        Quaternion localRotation = transform.localRotation;
        Vector3 localScale = transform.localScale;
        bool active = gameObject.activeSelf;

        transform.SetParent(Data.GetSceneParent());

        if (Data.OverrideTransform)
        {
            localPosition = Data.LocalPostion;
            localRotation = Data.LocalRotation;
            localScale = Data.LocalScale;
            active = Data.Active;
        }

        transform.localPosition = localPosition;
        transform.localRotation = localRotation;
        transform.localScale = localScale;
        gameObject.SetActive(active);
    }

    // RVA: 0x1B72CC8
    protected virtual void OnDrawGizmos()
    {
        Gizmos.color = color;
        Gizmos.DrawSphere(transform.position, 0.03f);
    }

    // RVA: 0x1B72D20
    public ReferenceObject()
    {
        Data = new SceneObject
        {
            state = SceneObjectState.binding
        };
    }
}
