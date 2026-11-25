// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Module
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;

public abstract class Module : MonoBehaviour, IScenarioEvent
{
    public int Init_index;
    public int Dispose_index;

    public ScenarioKit Kit
    {
        // RVA: 0x1699980
        get { return ScenarioKit.Instance; }
    }

    // RVA: 0x1699988
    public virtual void Init()
    {
        RegistEvent();
    }

    // RVA: 0x1699994
    public virtual void Dispose()
    {
        UnRegistEvent();
    }

    // RVA: 0x16999A0
    public virtual void RegistEvent()
    {
    }

    // RVA: 0x16999A4
    public virtual void UnRegistEvent()
    {
    }

    // RVA: 0x16999A8
    public virtual void Reset()
    {
        Dispose();
        Init();
    }

    // RVA: 0x16999DC
    public virtual void HandleEvent(object obj)
    {
    }

    // RVA: 0x16999E0
    protected Module()
    {
    }
}
