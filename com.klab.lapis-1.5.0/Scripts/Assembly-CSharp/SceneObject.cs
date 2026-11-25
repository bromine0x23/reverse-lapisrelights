// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  SceneObject
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  场景引用数据：绑定实例、按 Root/ChildPath 查找场景节点。
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;
using ServiceTools.Reflect;
using UnityEngine.SceneManagement;

[Serializable]
public class SceneObject
{
    public string Name;
    public string ChildPath;
    public string Root;
    public int Depth;
    public SceneObjectState state;
    public string RefType;
    public string AssetPath;
    public string GUID;
    public Vector3 LocalPostion;
    public Quaternion LocalRotation;
    public Vector3 LocalScale;
    public Vector3 Postion;
    public Quaternion Rotation;
    public Vector3 Scale;
    public bool Active;
    public bool OverrideTransform;
    public bool RuntimeBind;

    // RVA: 0x1948988
    public ReferenceObject BindInstance(GameObject go)
    {
        ReferenceObject referenceObject = ReferenceRoot.AddReference(
            AssemblyTool.FindTypesInCurrentDomainByName(RefType),
            go,
            null,
            null);

        state = SceneObjectState.binding;
        referenceObject.Data = this;
        return referenceObject;
    }

    // RVA: 0x1948A58
    public GameObject GetSceneInstance()
    {
        Transform parent = GetSceneParent();
        if (parent == null)
        {
            return null;
        }

        Transform child = parent.transform.Find(Name);
        if (child == null)
        {
            return null;
        }

        return child.gameObject;
    }

    // RVA: 0x1948B5C
    public Transform GetSceneParent()
    {
        if (string.IsNullOrEmpty(Root))
        {
            return null;
        }

        GameObject[] rootGameObjects = SceneManager.GetActiveScene().GetRootGameObjects();
        GameObject gameObject = new List<GameObject>(rootGameObjects).Find(e => e.name == Root);
        if (gameObject == null)
        {
            return null;
        }

        Transform transform = gameObject.transform;
        if (string.IsNullOrEmpty(ChildPath))
        {
            return transform;
        }

        return transform.Find(ChildPath);
    }

    // RVA: 0x1948D2C
    public SceneObject()
    {
        ChildPath = string.Empty;
        Root = string.Empty;
        RefType = string.Empty;
        Active = true;
        GUID = string.Empty;
    }
}
