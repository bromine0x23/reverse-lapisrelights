// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaReflection
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace LuaInterface
{
    public class LuaReflection : IDisposable
    {
        public List<Assembly> list;
        private static LuaReflection _reflection;

        // RVA: 0x22A07C4
        public LuaReflection()
        {
            #if !MULTI_STATE
                        _reflection = this;
            #endif
                        LoadAssembly("mscorlib");
                        LoadAssembly("UnityEngine");
                        //注释避免放在插件目录无法加载，需要可从lua代码loadassembly
                        //LoadAssembly("Assembly-CSharp"); 
        }

        // RVA: 0x22A09F0
        public static void OpenLibs(IntPtr L)
        {
                        InitMathf(L);
                        InitLayer(L);
        }

        // RVA: 0x22A0DA0
        public static LuaReflection Get(IntPtr L)
        {
            #if !MULTI_STATE
                        return mainState;
            #else

                        if (mainState != null && mainState.L == ptr)
                        {
                            return mainState;
                        }            

                        LuaState state = null;

                        if (stateMap.TryGetValue(ptr, out state))
                        {
                            return state;
                        }
                        else
                        {
                            return Get(LuaDLL.tolua_getmainstate(ptr));
                        }
            #endif
        }

        // RVA: 0x229DC30
        [MonoPInvokeCallback]
        private static int OpenReflectionLibs(IntPtr L)
        {
                        try
                        {
                            LuaState state = LuaState.Get(L);
                            state.BeginModule(null);
                            state.BeginModule("LuaInterface");
                            LuaInterface_LuaMethodWrap.Register(state);
                            LuaInterface_LuaPropertyWrap.Register(state);
                            LuaInterface_LuaFieldWrap.Register(state);
                            LuaInterface_LuaConstructorWrap.Register(state);                
                            state.EndModule();
                            state.EndModule();
                            return 0;
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }
        }

        // RVA: 0x229DE20
        [MonoPInvokeCallback]
        private static int FindType(IntPtr L)
        {
                        string name = ToLua.CheckString(L, 1);
                        LuaReflection reflection = LuaReflection.Get(L);            
                        List<Assembly> list = reflection.list;
                        Type t = null;            

                        for (int i = 0; i < list.Count; i++)
                        {
                            t = list[i].GetType(name);

                            if (t != null)
                            {
                                break;
                            }
                        }            

                        ToLua.Push(L, t);
                        return 1;
        }

        // RVA: 0x229DFEC
        [MonoPInvokeCallback]
        private static int LoadAssembly(IntPtr L)
        {
                        try
                        {
                            LuaReflection reflection = LuaReflection.Get(L);
                            string name = ToLua.CheckString(L, 1);
                            LuaDLL.lua_pushboolean(L, reflection.LoadAssembly(name));
                        }
                        catch(Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }

                        return 1;
        }

        // RVA: 0x22A0E08
        private static void PushLuaMethod(IntPtr L, MethodInfo md, Type t, Type[] types)
        {
                        if (md != null)
                        {
                            LuaMethod lm = new LuaMethod(md, t, types);
                            ToLua.PushSealed(L, lm);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }
        }

        // RVA: 0x229E1D0
        [MonoPInvokeCallback]
        private static int GetMethod(IntPtr L)
        {
                        try
                        {
                            int count = LuaDLL.lua_gettop(L);
                            Type t = ToLua.CheckMonoType(L, 1);
                            string name = ToLua.CheckString(L, 2);
                            Type[] types = null;

                            if (count > 2)
                            {
                                types = new Type[count - 2];

                                for (int i = 3; i <= count; i++)
                                {
                                    Type ti = ToLua.CheckMonoType(L, i);
                                    if (ti == null) LuaDLL.luaL_typerror(L, i, "Type");
                                    types[i - 3] = ti;
                                }                                       
                            }

                            MethodInfo md = null;

                            if (types == null)
                            {
                                md = t.GetMethod(name);
                            }
                            else
                            {
                                md = t.GetMethod(name, types);
                            }

                            PushLuaMethod(L, md, t, types);
                        }
                        catch(Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }

                        return 1;
        }

        // RVA: 0x22A0F08
        private static void PushLuaConstructor(IntPtr L, ConstructorInfo func, Type[] types)
        {
                        if (func != null)
                        {
                            LuaConstructor lm = new LuaConstructor(func, types);
                            ToLua.PushSealed(L, lm);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }
        }

        // RVA: 0x229E530
        [MonoPInvokeCallback]
        private static int GetConstructor(IntPtr L)
        {
                        try
                        {
                            int count = LuaDLL.lua_gettop(L);
                            Type t = (Type)ToLua.CheckObject(L, 1, typeof(Type));                
                            Type[] types = null;

                            if (count > 1)
                            {
                                types = new Type[count - 1];

                                for (int i = 2; i <= count; i++)
                                {
                                    Type ti = ToLua.CheckMonoType(L, i);
                                    if (ti == null) LuaDLL.luaL_typerror(L, i, "Type");
                                    types[i - 2] = ti;
                                }
                            }

                            ConstructorInfo ret = t.GetConstructor(types);
                            PushLuaConstructor(L, ret, types);
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }

                        return 1;
        }

        // RVA: 0x229E8B4
        [MonoPInvokeCallback]
        private static int GetTypeMethod(IntPtr L)
        {
                        try
                        {
                            int count = LuaDLL.lua_gettop(L);                

                            if (count == 2 && TypeChecker.CheckTypes<Type, string>(L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                MethodInfo o = obj.GetMethod(arg0);                    
                                PushLuaMethod(L, o, obj, null);
                                return 1;
                            }
                            else if (count == 3 && TypeChecker.CheckTypes<Type, string, Type[]>(L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                Type[] arg1 = ToLua.ToObjectArray<Type>(L, 3);
                                MethodInfo o = obj.GetMethod(arg0, arg1);
                                PushLuaMethod(L, o, obj, arg1);
                                return 1;
                            }
                            else if (count == 3 && TypeChecker.CheckTypes<Type, string, uint>(L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                BindingFlags arg1 = (BindingFlags)LuaDLL.lua_tonumber(L, 3);
                                MethodInfo o = obj.GetMethod(arg0, arg1);
                                PushLuaMethod(L, o, obj, null);
                                return 1;
                            }
                            else if (count == 4 && TypeChecker.CheckTypes<Type, string, Type[], ParameterModifier[]>(L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                Type[] arg1 = ToLua.ToObjectArray<System.Type>(L, 3);
                                ParameterModifier[] arg2 = ToLua.ToStructArray<ParameterModifier>(L, 4);
                                MethodInfo o = obj.GetMethod(arg0, arg1, arg2);
                                PushLuaMethod(L, o, obj, arg1);
                                return 1;
                            }
                            else if (count == 6 && TypeChecker.CheckTypes<Type, string, uint, Binder, Type[], ParameterModifier[]> (L, 1))
                            {
                                System.Type obj = (System.Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                BindingFlags arg1 = (BindingFlags)LuaDLL.lua_tonumber(L, 3);
                                Binder arg2 = (Binder)ToLua.ToObject(L, 4);
                                Type[] arg3 = ToLua.ToObjectArray<Type>(L, 5);
                                ParameterModifier[] arg4 = ToLua.ToStructArray<ParameterModifier>(L, 6);
                                MethodInfo o = obj.GetMethod(arg0, arg1, arg2, arg3, arg4);
                                PushLuaMethod(L, o, obj, arg3);
                                return 1;
                            }
                            else if (count == 7 && TypeChecker.CheckTypes<Type, string, uint, Binder, CallingConventions, Type[], ParameterModifier[]> (L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                BindingFlags arg1 = (BindingFlags)LuaDLL.lua_tonumber(L, 3);
                                Binder arg2 = (Binder)ToLua.ToObject(L, 4);
                                CallingConventions arg3 = (CallingConventions)ToLua.ToObject(L, 5);
                                Type[] arg4 = ToLua.ToObjectArray<Type>(L, 6);
                                ParameterModifier[] arg5 = ToLua.ToStructArray<ParameterModifier>(L, 7);
                                MethodInfo o = obj.GetMethod(arg0, arg1, arg2, arg3, arg4, arg5);
                                PushLuaMethod(L, o, obj, arg4);
                                return 1;
                            }
                            else
                            {
                                return LuaDLL.luaL_throw(L, "invalid arguments to method: tolua.gettypemethod");
                            }
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }
        }

        // RVA: 0x22A1014
        private static void PushLuaProperty(IntPtr L, PropertyInfo p, Type t)
        {
                        if (p != null)
                        {
                            LuaProperty lp = new LuaProperty(p, t);
                            ToLua.PushSealed(L, lp);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }
        }

        // RVA: 0x229F410
        [MonoPInvokeCallback]
        private static int GetProperty(IntPtr L)
        {
                        try
                        {
                            int count = LuaDLL.lua_gettop(L);                

                            if (count == 2 && TypeChecker.CheckTypes<Type, string>(L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                PropertyInfo o = obj.GetProperty(arg0);                    
                                PushLuaProperty(L, o, obj);
                                return 1;
                            }
                            else if (count == 3 && TypeChecker.CheckTypes<Type, string, Type[]>(L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                Type[] arg1 = ToLua.ToObjectArray<Type>(L, 3);
                                PropertyInfo o = obj.GetProperty(arg0, arg1);
                                PushLuaProperty(L, o, obj);
                                return 1;
                            }
                            else if (count == 3 && TypeChecker.CheckTypes<Type, string, Type>(L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                Type arg1 = (Type)ToLua.ToObject(L, 3);
                                PropertyInfo o = obj.GetProperty(arg0, arg1);
                                PushLuaProperty(L, o, obj);
                                return 1;
                            }
                            else if (count == 3 && TypeChecker.CheckTypes<Type, string, uint>(L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                BindingFlags arg1 = (BindingFlags)LuaDLL.lua_tonumber(L, 3);
                                PropertyInfo o = obj.GetProperty(arg0, arg1);
                                PushLuaProperty(L, o, obj);
                                return 1;
                            }
                            else if (count == 4 && TypeChecker.CheckTypes<Type, string, Type, Type[]>(L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                Type arg1 = (Type)ToLua.ToObject(L, 3);
                                Type[] arg2 = ToLua.ToObjectArray<Type>(L, 4);
                                PropertyInfo o = obj.GetProperty(arg0, arg1, arg2);
                                PushLuaProperty(L, o, obj);
                                return 1;
                            }
                            else if (count == 5 && TypeChecker.CheckTypes<Type, string, Type, Type[], ParameterModifier[]> (L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                Type arg1 = (Type)ToLua.ToObject(L, 3);
                                Type[] arg2 = ToLua.ToObjectArray<Type>(L, 4);
                                ParameterModifier[] arg3 = ToLua.ToStructArray<ParameterModifier>(L, 5);
                                PropertyInfo o = obj.GetProperty(arg0, arg1, arg2, arg3);
                                PushLuaProperty(L, o, obj);
                                return 1;
                            }
                            else if (count == 7 && TypeChecker.CheckTypes<Type, string, uint, Binder, Type, Type[], ParameterModifier[]> (L, 1))
                            {
                                Type obj = (Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                BindingFlags arg1 = (BindingFlags)LuaDLL.lua_tonumber(L, 3);
                                Binder arg2 = (Binder)ToLua.ToObject(L, 4);
                                Type arg3 = (Type)ToLua.ToObject(L, 5);
                                Type[] arg4 = ToLua.ToObjectArray<Type>(L, 6);
                                ParameterModifier[] arg5 = ToLua.ToStructArray<ParameterModifier>(L, 7);
                                PropertyInfo o = obj.GetProperty(arg0, arg1, arg2, arg3, arg4, arg5);
                                PushLuaProperty(L, o, obj);
                                return 1;
                            }
                            else
                            {
                                return LuaDLL.luaL_throw(L, "invalid arguments to method: tolua.getproperty");
                            }
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }            
        }

        // RVA: 0x22A1100
        private static void PushLuaField(IntPtr L, FieldInfo f, Type t)
        {
                        if (f != null)
                        {
                            LuaField lp = new LuaField(f, t);
                            ToLua.PushSealed(L, lp);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }
        }

        // RVA: 0x22A00C8
        [MonoPInvokeCallback]
        private static int GetField(IntPtr L)
        {
                        try
                        {
                            int count = LuaDLL.lua_gettop(L);                

                            if (count == 2 && TypeChecker.CheckTypes<Type, string>(L, 1))
                            {
                                Type obj = (System.Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                FieldInfo o = obj.GetField(arg0);
                                PushLuaField(L, o, obj);
                                return 1;
                            }
                            else if (count == 3 && TypeChecker.CheckTypes<Type, string, uint>(L, 1))
                            {
                                Type obj = (System.Type)ToLua.ToObject(L, 1);
                                string arg0 = ToLua.ToString(L, 2);
                                BindingFlags arg1 = (BindingFlags)LuaDLL.lua_tonumber(L, 3);
                                FieldInfo o = obj.GetField(arg0, arg1);
                                PushLuaField(L, o, obj);
                                return 1;
                            }
                            else
                            {
                                return LuaDLL.luaL_throw(L, "invalid arguments to method: tolua.getfield");
                            }
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }
        }

        // RVA: 0x22A04BC
        [MonoPInvokeCallback]
        private static int CreateInstance(IntPtr L)
        {
                        try
                        {
                            Type t = ToLua.CheckMonoType(L, 1);
                            if (t == null) LuaDLL.luaL_typerror(L, 1, "Type");
                            int count = LuaDLL.lua_gettop(L);
                            object obj = null;

                            if (count == 1)
                            {
                                obj = Activator.CreateInstance(t);
                            }
                            else
                            {
                                object[] args = new object[count - 1];

                                for (int i = 2; i <= count; i++)
                                {
                                    args[i - 2] = ToLua.ToVarObject(L, i);
                                }

                                obj = Activator.CreateInstance(t, args);
                            }

                            ToLua.Push(L, obj);
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }

                        return 1;
        }

        // RVA: 0x22A0888
        private bool LoadAssembly(string name)
        {
                        for (int i = 0; i < list.Count; i++)
                        {
                            if (list[i].GetName().Name == name)
                            {
                                return true;
                            }
                        }                

                        Assembly assembly = Assembly.Load(name);

                        if (assembly == null)
                        {
                            assembly = Assembly.Load(AssemblyName.GetAssemblyName(name));
                        }

                        if (assembly != null && !list.Contains(assembly))
                        {
                            list.Add(assembly);
                        }

                        return assembly != null;
        }

        // RVA: 0x22A11EC
        public void Dispose()
        {
                        --count;

                        if (count > 0)
                        {
                            return;
                        }

                        IsAlive = false;
                        Dispose(true);            
        }

        // RVA: 0x22A1244
        static LuaReflection()
        {

        }
    }
}
