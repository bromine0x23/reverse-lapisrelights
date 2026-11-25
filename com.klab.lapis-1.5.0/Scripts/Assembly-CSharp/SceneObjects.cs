// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  SceneObjects
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  场景特效实例句柄表（特效名 → Handle）。
// =============================================================================

using System.Collections.Generic;

public class SceneObjects : Module
{
    public Dictionary<string, int> EffectInstance;

    // RVA: 0x1948DF0
    public int AddEffectInstance(string effectName, int Handle)
    {
        int result = EffectInstance.ContainsKey(effectName)
            ? EffectInstance[effectName]
            : -1;

        EffectInstance[effectName] = Handle;
        return result;
    }

    // RVA: 0x1948EB0
    public void RemoveEffectInstance(string effectName)
    {
        EffectInstance.Remove(effectName);
    }

    // RVA: 0x1948F18
    public int GetEffectInstance(string effectName)
    {
        if (EffectInstance.ContainsKey(effectName))
        {
            return EffectInstance[effectName];
        }

        return -1;
    }

    // RVA: 0x1948FB4
    public SceneObjects()
    {
        EffectInstance = new Dictionary<string, int>();
    }
}
