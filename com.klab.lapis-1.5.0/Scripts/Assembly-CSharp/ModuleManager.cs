// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ModuleManager
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;

public class ModuleManager : Module, IModuleManager
{
    public List<Module> _modules;
    private Dictionary<Type, Module> dic;

    // RVA: 0x13D40FC
    public T GetModule<T>() where T : Module
    {
        Module module;
        if (dic.TryGetValue(typeof(T), out module))
        {
            return (T)(object)module;
        }

        module = _modules.Find(x => x is T);
        if (module != null)
        {
            dic[typeof(T)] = module;
        }
        return (T)(object)module;
    }

    // RVA: 0x13D4488
    public T InitModule<T>(T managerRef) where T : Module
    {
        if (managerRef == null)
        {
            managerRef = (T)(object)_modules.Find(x => x is T);
        }
        if (managerRef != null)
        {
            managerRef.Init();
        }
        return managerRef;
    }

    // RVA: 0x16999E8
    public override void Init()
    {
        RegistEvent();
        List<Module> modules = new List<Module>(_modules);
        modules.Sort((x, y) => x.Init_index.CompareTo(y.Init_index));
        foreach (Module module in modules)
        {
            module.Init();
        }
    }

    // RVA: 0x1699BD0
    public void ShowModuleList()
    {
        System.Text.StringBuilder builder = new System.Text.StringBuilder();
        for (int i = 0; i < _modules.Count; i++)
        {
            builder.Append(_modules[i].GetType());
            builder.Append(Environment.NewLine);
        }
        Debug.Log(builder.ToString());
    }

    // RVA: 0x1699EC8
    public override void Dispose()
    {
        List<Module> modules = new List<Module>(_modules);
        modules.Sort((x, y) => x.Dispose_index.CompareTo(y.Dispose_index));
        foreach (Module module in modules)
        {
            module.Dispose();
        }
    }

    // RVA: 0x169A0A0
    public ModuleManager()
    {
        _modules = new List<Module>();
        dic = new Dictionary<Type, Module>();
    }
}
