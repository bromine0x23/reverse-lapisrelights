// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioLua
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;

public class ScenarioLua : ToLuaModule
{
    public TextAsset LuaText;

    // RVA: 0x1B86408
    public void Loading(bool show)
    {
        Call(show ? "ShowLoading" : "HideLoading");
    }

    // RVA: 0x1B86478
    public override void Init()
    {
        base.Init();
    }

    // RVA: 0x1B86480
    public override void Dispose()
    {
        base.Dispose();
    }

    // RVA: 0x1B86488
    public ScenarioLua()
    {
    }
}
