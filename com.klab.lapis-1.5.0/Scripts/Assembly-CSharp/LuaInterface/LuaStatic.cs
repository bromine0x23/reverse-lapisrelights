// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaStatic
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
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
    public static class LuaStatic
    {

        // RVA: 0x18F3DAC
        public static int GetMetaReference(IntPtr L, Type t)
        {
                        LuaState state = LuaState.Get(L);
                        return state.GetMetaReference(t);
        }

        // RVA: 0x190BE44
        public static int GetMissMetaReference(IntPtr L, Type t)
        {
                        LuaState state = LuaState.Get(L);
                        return state.GetMissMetaReference(t);
        }

        // RVA: 0x190BF00
        public static Type GetClassType(IntPtr L, int reference)
        {
                        LuaState state = LuaState.Get(L);
                        return state.GetClassType(reference);
        }

        // RVA: 0x190BFBC
        public static LuaFunction GetFunction(IntPtr L, int reference)
        {
                        LuaState state = LuaState.Get(L);
                        return state.GetFunction(reference);
        }

        // RVA: 0x190C078
        public static LuaTable GetTable(IntPtr L, int reference)
        {
                        LuaState state = LuaState.Get(L);
                        return state.GetTable(reference);
        }

        // RVA: 0x190C134
        public static LuaThread GetLuaThread(IntPtr L, int reference)
        {
                        LuaState state = LuaState.Get(L);
                        return state.GetLuaThread(reference);
        }

        // RVA: 0x190C1F0
        public static void GetUnpackRayRef(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        LuaDLL.lua_getref(L, state.UnpackRay);
        }

        // RVA: 0x190C2D8
        public static void GetUnpackBounds(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        LuaDLL.lua_getref(L, state.UnpackBounds);
        }

        // RVA: 0x190C3C0
        public static void GetPackRay(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        LuaDLL.lua_getref(L, state.PackRay);
        }

        // RVA: 0x190C4A8
        public static void GetPackRaycastHit(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        LuaDLL.lua_getref(L, state.PackRaycastHit);
        }

        // RVA: 0x190C590
        public static void GetPackTouch(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        LuaDLL.lua_getref(L, state.PackTouch);
        }

        // RVA: 0x190C678
        public static void GetPackBounds(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        LuaDLL.lua_getref(L, state.PackBounds);
        }

        // RVA: 0x190C760
        public static int GetArrayMetatable(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        return state.ArrayMetatable;
        }

        // RVA: 0x190C810
        public static int GetTypeMetatable(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        return state.TypeMetatable;
        }

        // RVA: 0x190C8C0
        public static int GetDelegateMetatable(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        return state.DelegateMetatable;
        }

        // RVA: 0x190C970
        public static int GetEventMetatable(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        return state.EventMetatable;
        }

        // RVA: 0x190CA20
        public static int GetIterMetatable(IntPtr L)
        {
                        LuaState state = LuaState.Get(L);
                        return state.IterMetatable;
        }

        // RVA: 0x190CAD0
        public static int GetEnumObject(IntPtr L, Enum e, out object obj)
        {
            LuaState state = LuaState.Get(L);
            obj = state.GetEnumObj(e);
            return state.EnumMetatable;
        }

        // RVA: 0x190CBA0
        public static LuaCSFunction GetPreModule(IntPtr L, Type t)
        {
                        LuaState state = LuaState.Get(L);
                        return state.GetPreModule(t);
        }
    }
}
