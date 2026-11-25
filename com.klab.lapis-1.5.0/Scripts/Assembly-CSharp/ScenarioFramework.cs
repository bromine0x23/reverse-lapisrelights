// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioFramework
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  编辑器场景框架配置（资源与子模块引用）。
// =============================================================================

using UnityEngine;
using UnityEngine.Timeline;

public class ScenarioFramework : ScriptableObject
{
    public int sort;
    public string Comment;
    public string Information;
    public GameObject KitCorePrefab;
    public RuntimeAnimatorController controller;
    public GameObject TimelinePrefab;
    public TimelineAsset DefaultNewTimeLineAsset;
    public ScenarioLua LuaAsset;
    public ScenarioUI UIPrefab;
    public ScenarioCamera CameraPrefab;
    public GameObject SceneObjectRootPrefab;

    // RVA: 0x1B7FFD0
    public virtual void CreateKit()
    {
    }

    // RVA: 0x1B7FFC4
    public virtual void ReCreateKit()
    {
    }

    // RVA: 0x1B7FC48
    public ScenarioFramework()
    {
    }
}
