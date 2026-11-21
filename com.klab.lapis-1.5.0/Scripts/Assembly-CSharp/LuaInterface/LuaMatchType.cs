// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaMatchType
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
    public class LuaMatchType
    {
        private static Type monoType;

        // RVA: 0x2297F74
        public bool CheckNumber(IntPtr L, int pos)
        {
                        return LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TNUMBER;
        }

        // RVA: 0x2297FF4
        public bool CheckBool(IntPtr L, int pos)
        {
                        return LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TBOOLEAN;
        }

        // RVA: 0x2298074
        public bool CheckLong(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNUMBER:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Int64;                    
                            default:
                                return false;
                        }                        
        }

        // RVA: 0x2298138
        public bool CheckULong(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNUMBER:
                                return LuaDLL.lua_tonumber(L, pos) >= 0;
                            case LuaTypes.LUA_TUSERDATA:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.UInt64;                    
                            default:
                                return false;
                        }
        }

        // RVA: 0x2298224
        public bool CheckNullNumber(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TNUMBER || luaType == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x22982B0
        public bool CheckNullBool(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TBOOLEAN || luaType == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x2298330
        public bool CheckNullLong(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TNUMBER:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Int64;                    
                            default:
                                return false;
                        }
        }

        // RVA: 0x22983F8
        public bool CheckNullULong(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TNUMBER:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.UInt64;                    
                            default:
                                return false;
                        }
        }

        // RVA: 0x22984C0
        public bool CheckString(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TSTRING:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return CheckClassType(typeof(string), L, pos);
                            default:
                                return false;
                        }            
        }

        // RVA: 0x229870C
        public bool CheckByteArray(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TSTRING:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return CheckClassType(typeof(byte[]), L, pos);
                            default:
                                return false;
                        }
        }

        // RVA: 0x22987F8
        public bool CheckCharArray(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TSTRING:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return CheckClassType(typeof(char[]), L, pos);
                            default:
                                return false;
                        }
        }

        // RVA: 0x22988E4
        public bool CheckArray(Type t, IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:                                
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return CheckClassType(t, L, pos);
                            default:
                                return false;
                        }
        }

        // RVA: 0x229899C
        public bool CheckBoolArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(bool[]), L, pos);
        }

        // RVA: 0x2298A2C
        public bool CheckSByteArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(sbyte[]), L, pos);
        }

        // RVA: 0x2298ABC
        public bool CheckInt16Array(IntPtr L, int pos)
        {
                        return CheckArray(typeof(short[]), L, pos);
        }

        // RVA: 0x2298B4C
        public bool CheckUInt16Array(IntPtr L, int pos)
        {
                        return CheckArray(typeof(ushort[]), L, pos);
        }

        // RVA: 0x2298BDC
        public bool CheckDecimalArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(decimal[]), L, pos);
        }

        // RVA: 0x2298C6C
        public bool CheckSingleArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(float[]), L, pos);
        }

        // RVA: 0x2298CFC
        public bool CheckDoubleArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(double[]), L, pos);
        }

        // RVA: 0x2298D8C
        public bool CheckInt32Array(IntPtr L, int pos)
        {
                        return CheckArray(typeof(int[]), L, pos);
        }

        // RVA: 0x2298E1C
        public bool CheckUInt32Array(IntPtr L, int pos)
        {
                        return CheckArray(typeof(uint[]), L, pos);
        }

        // RVA: 0x2298EAC
        public bool CheckInt64Array(IntPtr L, int pos)
        {
                        return CheckArray(typeof(long[]), L, pos);
        }

        // RVA: 0x2298F3C
        public bool CheckUInt64Array(IntPtr L, int pos)
        {
                        return CheckArray(typeof(ulong[]), L, pos);
        }

        // RVA: 0x2298FCC
        public bool CheckStringArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(string[]), L, pos);
        }

        // RVA: 0x229905C
        public bool CheckTypeArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(Type[]), L, pos);
        }

        // RVA: 0x22990EC
        public bool CheckObjectArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(object[]), L, pos);
        }

        // RVA: 0x229917C
        private bool CheckValueType(IntPtr L, int pos, int valueType, Type nt)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            int vt = LuaDLL.tolua_getvaluetype(L, pos);                
                            return vt == valueType;
                        }

                        return false;
        }

        // RVA: 0x2299234
        public bool CheckVec3(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Vector3;
                        }

                        return false;            
        }

        // RVA: 0x22992E8
        public bool CheckQuat(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Quaternion;
                        }

                        return false;            
        }

        // RVA: 0x229939C
        public bool CheckVec2(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Vector2;
                        }

                        return false;            
        }

        // RVA: 0x2299450
        public bool CheckColor(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Color;
                        }

                        return false;            
        }

        // RVA: 0x2299504
        public bool CheckVec4(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Vector4;
                        }

                        return false;            
        }

        // RVA: 0x22995B8
        public bool CheckRay(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Ray;
                        }

                        return false;            
        }

        // RVA: 0x229966C
        public bool CheckBounds(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Bounds;
                        }

                        return false;            
        }

        // RVA: 0x2299720
        public bool CheckTouch(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Touch;
                        }

                        return false;            
        }

        // RVA: 0x22997D4
        public bool CheckLayerMask(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.LayerMask;
                        }

                        return false;            
        }

        // RVA: 0x2299888
        public bool CheckRaycastHit(IntPtr L, int pos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.RaycastHit;
                        }

                        return false;            
        }

        // RVA: 0x229993C
        public bool CheckNullVec3(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Vector3;
                            default:
                                return false;
                        }
        }

        // RVA: 0x22999FC
        public bool CheckNullQuat(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Quaternion;
                            default:
                                return false;
                        }
        }

        // RVA: 0x2299ABC
        public bool CheckNullVec2(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Vector2;
                            default:
                                return false;
                        }
        }

        // RVA: 0x2299B7C
        public bool CheckNullColor(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Color;
                            default:
                                return false;
                        }
        }

        // RVA: 0x2299C3C
        public bool CheckNullVec4(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Vector4;
                            default:
                                return false;
                        }
        }

        // RVA: 0x2299CFC
        public bool CheckNullRay(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Ray;
                            default:
                                return false;
                        }
        }

        // RVA: 0x2299DBC
        public bool CheckNullBounds(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Bounds;
                            default:
                                return false;
                        }
        }

        // RVA: 0x2299E7C
        public bool CheckNullTouch(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Touch;
                            default:
                                return false;
                        }
        }

        // RVA: 0x2299F3C
        public bool CheckNullLayerMask(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.LayerMask;
                            default:
                                return false;
                        }
        }

        // RVA: 0x2299FFC
        public bool CheckNullRaycastHit(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.RaycastHit;
                            default:
                                return false;
                        }
        }

        // RVA: 0x229A0BC
        public bool CheckVec3Array(IntPtr L, int pos)
        {
                        return CheckArray(typeof(Vector3[]), L, pos);
        }

        // RVA: 0x229A14C
        public bool CheckQuatArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(Quaternion[]), L, pos);
        }

        // RVA: 0x229A1DC
        public bool CheckVec2Array(IntPtr L, int pos)
        {
                        return CheckArray(typeof(Vector2[]), L, pos);
        }

        // RVA: 0x229A26C
        public bool CheckVec4Array(IntPtr L, int pos)
        {
                        return CheckArray(typeof(Vector4[]), L, pos);
        }

        // RVA: 0x229A2FC
        public bool CheckColorArray(IntPtr L, int pos)
        {
                        return CheckArray(typeof(Color[]), L, pos);
        }

        // RVA: 0x229A38C
        public bool CheckPtr(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TLIGHTUSERDATA || luaType == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x229A410
        public bool CheckLuaFunc(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TFUNCTION || luaType == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x229A49C
        public bool CheckLuaTable(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TTABLE || luaType == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x229A528
        public bool CheckLuaThread(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TTHREAD || luaType == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x229A5AC
        public bool CheckLuaBaseRef(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch(luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TFUNCTION:
                                return true;
                            case LuaTypes.LUA_TTABLE:
                                return true;
                            case LuaTypes.LUA_TTHREAD:
                                return true;
                            default:
                                return false;
                        }            
        }

        // RVA: 0x229A640
        public bool CheckByteBuffer(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TSTRING || luaType == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x229A6C4
        public bool CheckEventObject(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return CheckClassType(typeof(EventObject), L, pos);
                            default:
                                return false;
                        }
        }

        // RVA: 0x229A7A8
        public bool CheckEnumerator(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:                    
                                int udata = LuaDLL.tolua_rawnetobj(L, pos);

                                if (udata != -1)
                                {
                                    ObjectTranslator translator = ObjectTranslator.Get(L);
                                    object obj = translator.GetObject(udata);
                                    return obj == null ? true : obj is IEnumerator;
                                }
                                return false;                    
                            default:
                                return false;
                        }
        }

        // RVA: 0x229A904
        private bool CheckFinalType(Type type, IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return CheckClassType(type, L, pos);
                            default:
                                return false;
                        }
        }

        // RVA: 0x229A9B4
        public bool CheckGameObject(IntPtr L, int pos)
        {
                        return CheckFinalType(typeof(GameObject), L, pos);
        }

        // RVA: 0x229AA44
        public bool CheckTransform(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:                    
                                int udata = LuaDLL.tolua_rawnetobj(L, pos);

                                if (udata != -1)
                                {
                                    ObjectTranslator translator = ObjectTranslator.Get(L);
                                    object obj = translator.GetObject(udata);
                                    return obj == null ? true : obj is Transform;
                                }

                                return false;                    
                            default:
                                return false;
                        }
        }

        // RVA: 0x229ABBC
        public bool CheckMonoType(IntPtr L, int pos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return true;
                            case LuaTypes.LUA_TUSERDATA:
                                return CheckClassType(monoType, L, pos);
                            default:
                                return false;
                        }            
        }

        // RVA: 0x229AC90
        public bool CheckVariant(IntPtr L, int pos)
        {
                        return true;
        }

        // RVA: 0x22985AC
        private bool CheckClassType(Type t, IntPtr L, int pos)
        {
                        int udata = LuaDLL.tolua_rawnetobj(L, pos);

                        if (udata != -1)
                        {                
                            ObjectTranslator translator = ObjectTranslator.Get(L);
                            object obj = translator.GetObject(udata);
                            return obj == null ? true : obj.GetType() == t;
                        }

                        return false;
        }

        // RVA: 0x229AC98
        public LuaMatchType()
        {

        }

        // RVA: 0x229ACA0
        static LuaMatchType()
        {
            monoType = typeof(Type).GetType();
        }
    }
}
