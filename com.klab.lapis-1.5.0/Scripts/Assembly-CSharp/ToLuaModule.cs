// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ToLuaModule
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  Lua 模块基类：加载 LuaApi 表，提供函数查找、调用与返回值。
// =============================================================================

using System;
using System.Collections.Generic;
using LuaInterface;
using Oz.Framework;
using Oz.Framework.LuaModule;

public class ToLuaModule : Module
{
    public List<ToLuaModule.ToLuaAPI> LuaApi;

    public LuaManager LuaMgr
    {
        // RVA: 0x1452818
        get
        {
            if (Launcher.Instance == null)
            {
                return null;
            }
            return Launcher.Instance.LuaMgr;
        }
    }

    // RVA: 0x1452968
    public override void Init()
    {
        base.Init();
        if (LuaMgr == null)
        {
            return;
        }

        for (int i = 0; i < LuaApi.Count; i++)
        {
            LuaApi[i].Require(LuaMgr.luaState);
        }
    }

    // RVA: 0x1452D40
    public override void Dispose()
    {
        base.Dispose();
        for (int i = 0; i < LuaApi.Count; i++)
        {
            LuaApi[i].Dispose();
        }
    }

    // RVA: 0x1452F50
    public LuaFunction GetFunction(string functionName, out ToLuaModule.ToLuaAPI API, string TableName = null)
    {
        API = null;
        for (int i = 0; i < LuaApi.Count; i++)
        {
            ToLuaAPI api = LuaApi[i];
            if (string.IsNullOrEmpty(TableName))
            {
                LuaFunction func = api.GetFunction(functionName);
                if (func != null)
                {
                    API = api;
                    return func;
                }
            }
            else if (api.TableName == TableName)
            {
                LuaFunction func = api.GetFunction(functionName);
                if (func != null)
                {
                    API = api;
                    return func;
                }
            }
        }
        return null;
    }

    // RVA: 0x144EF64
    public LuaTable GetEmptyTable()
    {
        return LuaMgr.luaState.NewTable();
    }

    // RVA: 0x1453164
    public void Call(string functionName)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, null);
        if (func != null)
        {
            if (API.table != null)
            {
                func.Call(API.table);
            }
            else
            {
                func.Call();
            }
        }
    }

    // RVA: 0x145322C
    public void Call(string functionName, string TableName)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                func.Call(API.table);
            }
            else
            {
                func.Call();
            }
        }
    }

    // RVA: 0x13BEA1C
    public void Call<T1>(string functionName, T1 arg1, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                func.Call(API.table, arg1);
            }
            else
            {
                func.Call(arg1);
            }
        }
    }

    // RVA: 0x13BE94C
    public void Call<T1, T2>(string functionName, T1 arg1, T2 arg2, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                func.Call(API.table, arg1, arg2);
            }
            else
            {
                func.Call(arg1, arg2);
            }
        }
    }

    // RVA: 0x13BE870
    public void Call<T1, T2, T3>(string functionName, T1 arg1, T2 arg2, T3 arg3, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                func.Call(API.table, arg1, arg2, arg3);
            }
            else
            {
                func.Call(arg1, arg2, arg3);
            }
        }
    }

    // RVA: 0x13BE360
    public void Call<T1, T2, T3, T4>(string functionName, T1 arg1, T2 arg2, T3 arg3, T4 arg4, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                func.Call(API.table, arg1, arg2, arg3, arg4);
            }
            else
            {
                func.Call(arg1, arg2, arg3, arg4);
            }
        }
    }

    // RVA: 0x13BE684
    public void Call<T1, T2, T3, T4, T5>(string functionName, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                func.Call(API.table, arg1, arg2, arg3, arg4, arg5);
            }
            else
            {
                func.Call(arg1, arg2, arg3, arg4, arg5);
            }
        }
    }

    // RVA: 0x13BE574
    public void Call<T1, T2, T3, T4, T5, T6>(string functionName, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                func.Call(API.table, arg1, arg2, arg3, arg4, arg5, arg6);
            }
            else
            {
                func.Call(arg1, arg2, arg3, arg4, arg5, arg6);
            }
        }
    }

    // RVA: 0x13BE450
    public void Call<T1, T2, T3, T4, T5, T6, T7>(string functionName, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                func.Call(API.table, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
            }
            else
            {
                func.Call(arg1, arg2, arg3, arg4, arg5, arg6, arg7);
            }
        }
    }

    // RVA: 0x244A508
    public R1 Invoke<R1>(string functionName, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                return func.Invoke<LuaTable, R1>(API.table);
            }
            return func.Invoke<R1>();
        }
        return default(R1);
    }

    // RVA: 0x244A1CC
    public R1 Invoke<T1, R1>(string functionName, T1 arg1, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                return func.Invoke<LuaTable, T1, R1>(API.table, arg1);
            }
            return func.Invoke<T1, R1>(arg1);
        }
        return default(R1);
    }

    // RVA: 0x244A370
    public R1 Invoke<T1, T2, R1>(string functionName, T1 arg1, T2 arg2, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                return func.Invoke<LuaTable, T1, T2, R1>(API.table, arg1, arg2);
            }
            return func.Invoke<T1, T2, R1>(arg1, arg2);
        }
        return default(R1);
    }

    // RVA: 0x244A28C
    public R1 Invoke<T1, T2, T3, R1>(string functionName, T1 arg1, T2 arg2, T3 arg3, string TableName = null)
    {
        ToLuaAPI API;
        LuaFunction func = GetFunction(functionName, out API, TableName);
        if (func != null)
        {
            if (API.table != null)
            {
                return func.Invoke<LuaTable, T1, T2, T3, R1>(API.table, arg1, arg2, arg3);
            }
            return func.Invoke<T1, T2, T3, R1>(arg1, arg2, arg3);
        }
        return default(R1);
    }

    // RVA: 0x1453300
    public ToLuaModule()
    {
        LuaApi = new List<ToLuaAPI>();
    }

    [Serializable]
    public class ToLuaAPI
    {
        public string TableName;
        public List<string> FunctionName;
        public LuaTable table;
        public Dictionary<string, LuaFunction> functions;

        // RVA: 0x1452AC0
        public void Require(LuaState state)
        {
            functions.Clear();
            if (!string.IsNullOrEmpty(TableName))
            {
                table = state.GetTable(TableName, true);
            }

            if (table != null)
            {
                foreach (string key in FunctionName)
                {
                    functions[key] = table.GetLuaFunction(key);
                }
            }
            else
            {
                foreach (string key in FunctionName)
                {
                    functions[key] = state.GetFunction(key, true);
                }
            }
        }

        // RVA: 0x14530EC
        public LuaFunction GetFunction(string functionName)
        {
            LuaFunction value;
            functions.TryGetValue(functionName, out value);
            return value;
        }

        // RVA: 0x1452E40
        public void Dispose()
        {
            foreach (LuaFunction func in functions.Values)
            {
                DisposeLuaObj(func);
            }
            DisposeLuaObj(table);
            functions.Clear();
        }

        // RVA: 0x1453370
        private void DisposeLuaObj(IDisposable luaObj)
        {
            if (luaObj != null)
            {
                luaObj.Dispose();
            }
        }

        // RVA: 0x1453424
        public ToLuaAPI()
        {
            TableName = string.Empty;
            FunctionName = new List<string>();
            functions = new Dictionary<string, LuaFunction>();
        }
    }
}
