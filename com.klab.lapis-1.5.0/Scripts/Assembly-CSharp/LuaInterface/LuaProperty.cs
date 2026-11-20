// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaProperty
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
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
    public sealed class LuaProperty
    {
        private PropertyInfo property;
        private Type kclass;

        // RVA: 0x229D4F8
        [NoToLua]
        public LuaProperty(PropertyInfo prop, Type t)
        {
                        property = prop;
                        kclass = t;            
        }

        // RVA: 0x229D530
        public int Get(IntPtr L)
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

        // RVA: 0x229D820
        public int Set(IntPtr L)
        {
                        try
                        {
                            int count = LuaDLL.lua_gettop(L);

                            if (count == 3)
                            {
                                object arg0 = ToLua.CheckVarObject(L, 2, kclass);
                                object arg1 = ToLua.ToVarObject(L, 3);
                                if (arg1 != null) arg1 = TypeChecker.ChangeType(arg1, field.FieldType);
                                field.SetValue(arg0, arg1);
                                return 0;
                            }
                            else if (count == 6)
                            {
                                object arg0 = ToLua.CheckVarObject(L, 2, kclass);
                                object arg1 = ToLua.ToVarObject(L, 3);
                                if (arg1 != null) arg1 = TypeChecker.ChangeType(arg1, field.FieldType);
                                BindingFlags arg2 = (BindingFlags)LuaDLL.luaL_checknumber(L, 4);
                                Binder arg3 = (Binder)ToLua.CheckObject(L, 5, typeof(Binder));
                                CultureInfo arg4 = (CultureInfo)ToLua.CheckObject(L, 6, typeof(CultureInfo));                    
                                field.SetValue(arg0, arg1, arg2, arg3, arg4);
                                return 0;
                            }
                            else
                            {
                                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaField.Set");
                            }
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }
        }
    }
}
