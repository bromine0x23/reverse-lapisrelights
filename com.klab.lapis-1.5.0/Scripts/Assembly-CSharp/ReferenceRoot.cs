// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ReferenceRoot
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  场景引用注册表：收集场景内 ReferenceObject，按 GUID / 动态名查找，
//  并在场景加载后自动重新收集。
// =============================================================================

using System;
using System.Collections.Generic;
using SeanLib.Core;
using UnityEngine;
using UnityEngine.SceneManagement;

[ExecuteInEditMode]
public class ReferenceRoot : MonoBehaviour
{
    private static ReferenceRoot _Instance;
    public List<ReferenceObject> Refrences;
    public Dictionary<string, ReferenceObject> dic;
    public Dictionary<string, string> DynamicNameDic;

    public static ReferenceRoot Instance
    {
        // RVA: 0x1B72B1C
        get
        {
            if (_Instance == null)
            {
                _Instance = FindObjectOfType<ReferenceRoot>();
            }
            return _Instance;
        }
    }

    // RVA: 0x1B72D98
    static ReferenceRoot()
    {
        SceneManager.sceneUnloaded -= sceneUnloaded;
        SceneManager.sceneUnloaded += sceneUnloaded;
        SceneManager.sceneLoaded -= sceneLoaded;
        SceneManager.sceneLoaded += sceneLoaded;
    }

    // RVA: 0x1B72EC8
    private static void EditorSceneManager_activeSceneChangedInEditMode(Scene arg0, Scene arg1)
    {
        if (Instance)
        {
            Instance.CollectRefrence();
        }
    }

    // RVA: 0x1B73188
    private static void sceneUnloaded(Scene arg0)
    {
    }

    // RVA: 0x1B7318C
    private static void sceneLoaded(Scene arg0, LoadSceneMode arg1)
    {
        if (Instance)
        {
            Instance.CollectRefrence();
        }
    }

    // RVA: 0x1B72F9C
    public void CollectRefrence()
    {
        Refrences = GameObjectUtilities.FindSceneAllGameObjects<ReferenceObject>();
        dic.Clear();

        foreach (ReferenceObject item in Refrences)
        {
            if (dic.ContainsKey(item.Data.GUID))
            {
                LogConflict(dic[item.Data.GUID], item);
            }
            else
            {
                dic.Add(item.Data.GUID, item);
            }
        }
    }

    // RVA: 0x1B73260
    private void LogConflict(ReferenceObject arg1, ReferenceObject arg2)
    {
    }

    // RVA: 0x1B73264
    private void Awake()
    {
        if (!_Instance)
        {
            _Instance = this;
        }
    }

    // RVA: 0x1B73330
    private void OnDisable()
    {
        Refrences.Clear();
    }

    // RVA: 0x1B72C3C
    public bool Put(ReferenceObject refObj)
    {
        return Put(refObj, LogConflict);
    }

    // RVA: 0x1B73388
    public bool Put(ReferenceObject refObj, Action<ReferenceObject, ReferenceObject> ConflictHandle)
    {
        ReferenceObject value = null;
        if (dic.TryGetValue(refObj.Data.GUID, out value))
        {
            if (value)
            {
                if (value != refObj)
                {
                    dic[refObj.Data.GUID] = refObj;
                    if (ConflictHandle != null)
                    {
                        ConflictHandle(value, refObj);
                    }
                }
                return false;
            }
        }
        else
        {
            Refrences.Add(refObj);
        }

        dic[refObj.Data.GUID] = refObj;
        return true;
    }

    // RVA: 0x1B73514
    public ReferenceObject Get(SceneReference reference)
    {
        ReferenceObject referenceObject = Get(reference.GUID);
        if (referenceObject)
        {
            return referenceObject;
        }

        if (reference.Dynamic)
        {
            return GetDynamic(reference.DyamicName);
        }

        return null;
    }

    // RVA: 0x1B7369C
    public ReferenceObject GetDynamic(string DynamicName)
    {
        string value = string.Empty;
        if (DynamicNameDic.TryGetValue(DynamicName, out value))
        {
            return Get(value);
        }

        return null;
    }

    // RVA: 0x1B735D4
    public ReferenceObject Get(string GUID)
    {
        if (string.IsNullOrEmpty(GUID))
        {
            return null;
        }

        ReferenceObject value = null;
        dic.TryGetValue(GUID, out value);
        return value == null ? null : value;
    }

    // RVA: 0x244A5C0
    public ReferenceObject Find<T>(string name)
    {
        return Refrences.Find(e => e.name == name && e is T);
    }

    // RVA: 0x15449BC
    public static T AddReference<T>(GameObject go, Type ComponentType, SceneReference sceneRef)
    {
        return (T)(object)AddReference(typeof(T), go, ComponentType, sceneRef);
    }

    // RVA: 0x1B73740
    public static ReferenceObject AddReference(
        Type RefObjType,
        GameObject go,
        Type ComponentType,
        SceneReference sceneRef)
    {
        ReferenceObject referenceObject = go.GetComponent(RefObjType) as ReferenceObject;
        if (referenceObject == null)
        {
            referenceObject = (ReferenceObject)go.AddComponent(RefObjType);
            referenceObject.TryInit();

            if (Instance)
            {
                Instance.Refrences.Add(referenceObject);
            }
        }

        if (sceneRef != null)
        {
            if (string.IsNullOrEmpty(referenceObject.Data.GUID))
            {
                referenceObject.Data.GUID = Guid.NewGuid().ToString();
            }
            sceneRef.Identity = referenceObject.Data.GUID;

            if (ComponentType != null)
            {
                sceneRef.Type = ComponentType.Name;
            }
        }

        return referenceObject;
    }

    // RVA: 0x1B739F0
    public static ReferenceObject AddReference(GameObject go, Type type, SceneReference sceneRef)
    {
        return AddReference<ReferenceObject>(go, type, sceneRef);
    }

    // RVA: 0x1B73A78
    public static ReferenceObject AddReference(GameObject go, SceneReference sceneRef)
    {
        return AddReference<ReferenceObject>(go, null, sceneRef);
    }

    // RVA: 0x1B73AFC
    public static string AddMissingReferenceGUID(GameObject go, SceneReference sceneRef)
    {
        return AddReference<ReferenceObject>(go, null, sceneRef).Data.GUID;
    }

    // RVA: 0x1B73B98
    public void SetDynamicName(string dynamicName, string TargetGUI)
    {
        DynamicNameDic[dynamicName] = TargetGUI;
    }

    // RVA: 0x1B73C08
    public void SetDynamicName(DynamicRef dynamicReference)
    {
        SetDynamicName(dynamicReference.DynamicName, dynamicReference.TargetGUID);
    }

    // RVA: 0x1B73C24
    private void OnDestroy()
    {
        _Instance = null;
    }

    // RVA: 0x1B73C8C
    public ReferenceRoot()
    {
        Refrences = new List<ReferenceObject>();
        dic = new Dictionary<string, ReferenceObject>();
        DynamicNameDic = new Dictionary<string, string>();
    }
}
