// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.ToLua
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Runtime.InteropServices;
using System.Text;
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
    public static class ToLua
    {
        private static Type monoType;
        public static ToLua.LuaTableToVar[] ToVarMap;
        public static Dictionary<Type, ToLua.LuaPushVarObject> VarPushMap;

        // RVA: 0x1F70760
        static ToLua()
        {
                        ToVarMap[LuaValueType.Vector3] = ToObjectVec3;
                        ToVarMap[LuaValueType.Quaternion] = ToObjectQuat;
                        ToVarMap[LuaValueType.Vector2] = ToObjectVec2;
                        ToVarMap[LuaValueType.Color] = ToObjectColor;
                        ToVarMap[LuaValueType.Vector4] = ToObjectVec4;
                        ToVarMap[LuaValueType.Ray] = ToObjectRay;
                        ToVarMap[LuaValueType.LayerMask] = ToObjectLayerMask;
                        ToVarMap[LuaValueType.Bounds] = ToObjectBounds;
        }

        // RVA: 0x1F70B5C
        public static void OpenLibs(IntPtr L)
        {
                        InitMathf(L);
                        InitLayer(L);
        }

        // RVA: 0x1F70F74
        private static void AddLuaLoader(IntPtr L)
        {
                        LuaDLL.lua_getglobal(L, "package");
                        LuaDLL.lua_getfield(L, -1, "loaders");
                        LuaDLL.tolua_pushcfunction(L, Loader);

                        for (int i = LuaDLL.lua_objlen(L, -2) + 1; i > 2; i--)
                        {
                            LuaDLL.lua_rawgeti(L, -2, i - 1);
                            LuaDLL.lua_rawseti(L, -3, i);
                        }

                        LuaDLL.lua_rawseti(L, -2, 2);
                        LuaDLL.lua_pop(L, 2);
        }

        // RVA: 0x1F6EC04
        [MonoPInvokeCallback]
        private static int Panic(IntPtr L)
        {
                        string reason = String.Format("PANIC: unprotected error in call to Lua API ({0})", LuaDLL.lua_tostring(L, -1));
                        throw new LuaException(reason);
        }

        // RVA: 0x1F6ECC8
        [MonoPInvokeCallback]
        private static int Print(IntPtr L)
        {
                        try
                        {
                            int n = LuaDLL.lua_gettop(L);   

                            using (CString.Block())
                            {
                                CString sb = CString.Alloc(256);
            #if UNITY_EDITOR
                                int line = LuaDLL.tolua_where(L, 1);
                                string filename = LuaDLL.lua_tostring(L, -1);
                                LuaDLL.lua_settop(L, n);
                                int offset = filename[0] == '@' ? 1 : 0;

                                if (!filename.Contains("."))
                                {
                                    sb.Append('[').Append(filename, offset, filename.Length - offset).Append(".lua:").Append(line).Append("]:");
                                }
                                else
                                {
                                    sb.Append('[').Append(filename, offset, filename.Length - offset).Append(':').Append(line).Append("]:");
                                }
            #endif

                                for (int i = 1; i <= n; i++)
                                {
                                    if (i > 1) sb.Append("    ");

                                    if (LuaDLL.lua_isstring(L, i) == 1)
                                    {
                                        sb.Append(LuaDLL.lua_tostring(L, i));
                                    }
                                    else if (LuaDLL.lua_isnil(L, i))
                                    {
                                        sb.Append("nil");
                                    }
                                    else if (LuaDLL.lua_isboolean(L, i))
                                    {
                                        sb.Append(LuaDLL.lua_toboolean(L, i) ? "true" : "false");
                                    }
                                    else
                                    {
                                        IntPtr p = LuaDLL.lua_topointer(L, i);

                                        if (p == IntPtr.Zero)
                                        {
                                            sb.Append("nil");
                                        }
                                        else
                                        {
                                            sb.Append(LuaDLL.luaL_typename(L, i)).Append(":0x").Append(p.ToString("X"));
                                        }
                                    }
                                }

                                Debugger.Log(sb.ToString());            //203行与_line一致
                            }
                            return 0;
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }
        }

        // RVA: 0x1F6F244
        [MonoPInvokeCallback]
        private static int Loader(IntPtr L)
        {
                        try
                        {
                            string fileName = LuaDLL.lua_tostring(L, 1);
                            fileName = fileName.Replace(".", "/");
                            byte[] buffer = LuaFileUtils.Instance.ReadFile(fileName);

                            if (buffer == null)
                            {
                                string error = LuaFileUtils.Instance.FindFileError(fileName);
                                LuaDLL.lua_pushstring(L, error);
                                return 1;
                            }

                            if (LuaConst.openLuaDebugger)
                            {
                                fileName = LuaFileUtils.Instance.FindFile(fileName);
                            }                

                            if (LuaDLL.luaL_loadbuffer(L, buffer, buffer.Length, "@"+ fileName) != 0)
                            {
                                string err = LuaDLL.lua_tostring(L, -1);
                                throw new LuaException(err, LuaException.GetLastError());
                            }

                            return 1;
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }
        }

        // RVA: 0x1F6F6A4
        [MonoPInvokeCallback]
        public static int DoFile(IntPtr L)
        {
                        try
                        {
                            string fileName = LuaDLL.lua_tostring(L, 1);
                            int n = LuaDLL.lua_gettop(L);
                            byte[] buffer = LuaFileUtils.Instance.ReadFile(fileName);

                            if (buffer == null)
                            {
                                string error = string.Format("cannot open {0}: No such file or directory", fileName);
                                error += LuaFileUtils.Instance.FindFileError(fileName);
                                throw new LuaException(error);
                            }

                            if (LuaDLL.luaL_loadbuffer(L, buffer, buffer.Length, fileName) == 0)
                            {
                                if (LuaDLL.lua_pcall(L, 0, LuaDLL.LUA_MULTRET, 0) != 0)
                                {
                                    string error = LuaDLL.lua_tostring(L, -1);
                                    throw new LuaException(error, LuaException.GetLastError());
                                }
                            }
            				else
            				{
            					string err = LuaDLL.lua_tostring(L, -1);
            					throw new LuaException(err, LuaException.GetLastError());
            				}

                            return LuaDLL.lua_gettop(L) - n;
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }
        }

        // RVA: 0x1F6FB5C
        [MonoPInvokeCallback]
        public static int LoadFile(IntPtr L)
        {
                        try
                        {
                            string fileName = LuaDLL.lua_tostring(L, 1);
                            byte[] buffer = LuaFileUtils.Instance.ReadFile(fileName);

                            if (buffer == null)
                            {
                                string error = string.Format("cannot open {0}: No such file or directory", fileName);
                                error += LuaFileUtils.Instance.FindFileError(fileName);
                                throw new LuaException(error);
                            }

                            if (LuaDLL.luaL_loadbuffer(L, buffer, buffer.Length, fileName) == 0)
                            {
                                return 1;
                            }

                            LuaDLL.lua_pushnil(L);
                            LuaDLL.lua_insert(L, -2);  /* put before error message */
                            return 2;
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }
        }

        // RVA: 0x1F6FE98
        [MonoPInvokeCallback]
        private static int IsNull(IntPtr L)
        {
                        LuaTypes t = LuaDLL.lua_type(L, 1);

                        if (t == LuaTypes.LUA_TNIL)
                        {
                            LuaDLL.lua_pushboolean(L, true);
                        }
                        else
                        {
                            object o = ToLua.ToObject(L, -1);

                            if (o == null || o.Equals(null))
                            {
                                LuaDLL.lua_pushboolean(L, true);
                            }
                            else
                            {
                                LuaDLL.lua_pushboolean(L, false);
                            }
                        }

                        return 1;
        }

        // RVA: 0x1F6FFA0
        [MonoPInvokeCallback]
        private static int BufferToString(IntPtr L)
        {
                        try
                        {
                            object o = CheckObject(L, 1);

                            if (o is byte[])
                            {
                                byte[] buff = (byte[])o;
                                LuaDLL.lua_pushlstring(L, buff, buff.Length);
                            }
                            else if (o is char[])
                            {
                                byte[] buff = System.Text.Encoding.UTF8.GetBytes((char[])o);
                                LuaDLL.lua_pushlstring(L, buff, buff.Length);
                            }
                            else if (o is string)
                            {
                                LuaDLL.lua_pushstring(L, (string)o);
                            }
                            else
                            {
                                LuaDLL.luaL_typerror(L, 1, "byte[] or char[]");
                            }

                            return 1;
                        }
                        catch (Exception e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }            
        }

        // RVA: 0x1F702C0
        [MonoPInvokeCallback]
        private static int GetClassType(IntPtr L)
        {
                        int reference = LuaDLL.tolua_getmetatableref(L, 1);

                        if (reference > 0)
                        {
                            Type t = LuaStatic.GetClassType(L, reference);
                            Push(L, t);
                        }
                        else
                        {
                            int ret = LuaDLL.tolua_getvaluetype(L, -1);

                            if (ret != LuaValueType.None)
                            {
                                Type t = TypeChecker.LuaValueTypeMap[ret];
                                Push(L, t);
                            }
                            else
                            {
                                Debugger.LogError("type not register to lua");
                                LuaDLL.lua_pushnil(L);
                            }
                        }

                        return 1;
        }

        // RVA: 0x1F70488
        [MonoPInvokeCallback]
        private static int TableToArray(IntPtr L)
        {
                        try
                        {
                            object[] objs = ToLua.CheckObjectArray(L, 1);
                            Type t = ToLua.CheckMonoType(L, 2);
                            Array ret = System.Array.CreateInstance(t, objs.Length);

                            for (int i = 0; i < objs.Length; i++)
                            {
                                ret.SetValue(objs[i], i);
                            }

                            ToLua.Push(L, ret);
                            return 1;
                        }
                        catch(LuaException e)
                        {
                            return LuaDLL.toluaL_exception(L, e);
                        }            
        }

        // RVA: 0x1F70678
        [MonoPInvokeCallback]
        public static int op_ToString(IntPtr L)
        {
                        object obj = ToLua.ToObject(L, 1);

                        if (obj != null)
                        {
                            LuaDLL.lua_pushstring(L, obj.ToString());
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }

                        return 1;
        }

        // RVA: 0x1F71A44
        public static string ToString(IntPtr L, int stackPos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, stackPos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TSTRING:
                                return LuaDLL.lua_tostring(L, stackPos);
                            case LuaTypes.LUA_TUSERDATA:
                                return (string)ToObject(L, stackPos);
                            default:
                                return null;
                        }
        }

        // RVA: 0x1F71104
        public static object ToObject(IntPtr L, int stackPos)
        {
                        return ToLua.ToObject(L, stackPos);
        }

        // RVA: 0x1F71B54
        public static LuaFunction ToLuaFunction(IntPtr L, int stackPos)
        {
                        LuaTypes type = LuaDLL.lua_type(L, stackPos);

                        if (type == LuaTypes.LUA_TNIL)
                        {
                            return null;
                        }

                        stackPos = LuaDLL.abs_index(L, stackPos);
                        LuaDLL.lua_pushvalue(L, stackPos);
                        int reference = LuaDLL.toluaL_ref(L);
                        return LuaStatic.GetFunction(L, reference);
        }

        // RVA: 0x1F71C38
        public static LuaTable ToLuaTable(IntPtr L, int stackPos)
        {
                        LuaTypes type = LuaDLL.lua_type(L, stackPos);

                        if (type == LuaTypes.LUA_TNIL)
                        {
                            return null;
                        }

                        stackPos = LuaDLL.abs_index(L, stackPos);
                        LuaDLL.lua_pushvalue(L, stackPos);
                        int reference = LuaDLL.toluaL_ref(L);
                        return LuaStatic.GetTable(L, reference);
        }

        // RVA: 0x1F71D1C
        public static LuaThread ToLuaThread(IntPtr L, int stackPos)
        {
                        LuaTypes type = LuaDLL.lua_type(L, stackPos);

                        if (type == LuaTypes.LUA_TNIL)
                        {
                            return null;
                        }

                        stackPos = LuaDLL.abs_index(L, stackPos);
                        LuaDLL.lua_pushvalue(L, stackPos);
                        int reference = LuaDLL.toluaL_ref(L);
                        return LuaStatic.GetLuaThread(L, reference);
        }

        // RVA: 0x1F71E00
        public static Vector3 ToVector3(IntPtr L, int stackPos)
        {
                        float x = 0, y = 0, z = 0;
                        LuaDLL.tolua_getvec3(L, stackPos, out x, out y, out z);
                        return new Vector3(x, y, z);
        }

        // RVA: 0x1F71EBC
        public static Vector4 ToVector4(IntPtr L, int stackPos)
        {
                        float x, y, z, w;
                        LuaDLL.tolua_getvec4(L, stackPos, out x, out y, out z, out w);
                        return new Vector4(x, y, z, w);
        }

        // RVA: 0x1F71F7C
        public static Vector2 ToVector2(IntPtr L, int stackPos)
        {
                        float x, y;
                        LuaDLL.tolua_getvec2(L, stackPos, out x, out y);
                        return new Vector2(x, y);
        }

        // RVA: 0x1F72024
        public static Quaternion ToQuaternion(IntPtr L, int stackPos)
        {
                        float x, y, z, w;
                        LuaDLL.tolua_getquat(L, stackPos, out x, out y, out z, out w);
                        return new Quaternion(x, y, z, w);
        }

        // RVA: 0x1F720E4
        public static Color ToColor(IntPtr L, int stackPos)
        {
                        float r, g, b, a;
                        LuaDLL.tolua_getclr(L, stackPos, out r, out g, out b, out a);
                        return new Color(r, g, b, a);
        }

        // RVA: 0x1F721A4
        public static Ray ToRay(IntPtr L, int stackPos)
        {
                        int top = LuaDLL.lua_gettop(L);
                        LuaStatic.GetUnpackRayRef(L);
                        stackPos = LuaDLL.abs_index(L, stackPos);
                        LuaDLL.lua_pushvalue(L, stackPos);

                        if (LuaDLL.lua_pcall(L, 1, 6, 0) == 0)
                        {            
                            float ox = (float)LuaDLL.lua_tonumber(L, top + 1);
                            float oy = (float)LuaDLL.lua_tonumber(L, top + 2);
                            float oz = (float)LuaDLL.lua_tonumber(L, top + 3);
                            float dx = (float)LuaDLL.lua_tonumber(L, top + 4);
                            float dy = (float)LuaDLL.lua_tonumber(L, top + 5);
                            float dz = (float)LuaDLL.lua_tonumber(L, top + 6);
                            LuaDLL.lua_settop(L, top);
                            return new Ray(new Vector3(ox, oy, oz), new Vector3(dx, dy, dz));
                        }
                        else
                        {
                            string error = LuaDLL.lua_tostring(L, -1);
                            LuaDLL.lua_settop(L, top);
                            throw new LuaException(error);
                        }
        }

        // RVA: 0x1F72410
        public static Bounds ToBounds(IntPtr L, int stackPos)
        {
                        int top = LuaDLL.lua_gettop(L);
                        LuaStatic.GetUnpackBounds(L);
                        stackPos = LuaDLL.abs_index(L, stackPos);
                        LuaDLL.lua_pushvalue(L, stackPos);

                        if (LuaDLL.lua_pcall(L, 1, 2, 0) == 0)
                        {
                            Vector3 center = ToVector3(L, top + 1);
                            Vector3 size = ToVector3(L, top + 2);
                            LuaDLL.lua_settop(L, top);
                            return new Bounds(center, size);
                        }
                        else
                        {
                            string error = LuaDLL.lua_tostring(L, -1);
                            LuaDLL.lua_settop(L, top);
                            throw new LuaException(error);
                        }
        }

        // RVA: 0x1F72610
        public static LayerMask ToLayerMask(IntPtr L, int stackPos)
        {
                        return LuaDLL.tolua_getlayermask(L, stackPos);
        }

        // RVA: 0x1F72698
        public static object ToVarObject(IntPtr L, int stackPos)
        {
                        LuaTypes type = LuaDLL.lua_type(L, stackPos);

                        switch (type)
                        {
                            case LuaTypes.LUA_TNUMBER:                    
                                return LuaDLL.lua_tonumber(L, stackPos);
                            case LuaTypes.LUA_TSTRING:
                                return LuaDLL.lua_tostring(L, stackPos);
                            case LuaTypes.LUA_TUSERDATA:                    
                                switch(LuaDLL.tolua_getvaluetype(L, stackPos))
                                {                                                    
                                    case LuaValueType.Int64:
                                        return LuaDLL.tolua_toint64(L, stackPos);
                                    case LuaValueType.UInt64:
                                        return LuaDLL.tolua_touint64(L, stackPos);
                                    default:
                                        return ToObject(L, stackPos);
                                }
                            case LuaTypes.LUA_TBOOLEAN:
                                return LuaDLL.lua_toboolean(L, stackPos);
                            case LuaTypes.LUA_TFUNCTION:
                                return ToLuaFunction(L, stackPos);
                            case LuaTypes.LUA_TTABLE:
                                return ToVarTable(L, stackPos);
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TLIGHTUSERDATA:
                                return LuaDLL.lua_touserdata(L, stackPos);
                            case LuaTypes.LUA_TTHREAD:
                                return ToLuaThread(L, stackPos);
                            default:
                                return null;
                        }
        }

        // RVA: 0x1F72AF0
        public static object ToVarObject(IntPtr L, int stackPos, Type t)
        {
                        LuaTypes type = LuaDLL.lua_type(L, stackPos);

                        if (type == LuaTypes.LUA_TNUMBER)
                        {
                            object o = LuaDLL.lua_tonumber(L, stackPos);
                            o = Convert.ChangeType(o, t);
                            return o;
                        }

                        return ToVarObject(L, stackPos);
        }

        // RVA: 0x1F7299C
        public static object ToVarTable(IntPtr L, int stackPos)
        {
                        stackPos = LuaDLL.abs_index(L, stackPos);
                        int ret = LuaDLL.tolua_getvaluetype(L, stackPos);
                        LuaTableToVar _ToObject = ToVarMap[ret];

                        if (_ToObject != null)
                        {
                            return _ToObject(L, stackPos);
                        }
                        else
                        {
                            LuaDLL.lua_pushvalue(L, stackPos);
                            int reference = LuaDLL.toluaL_ref(L);
                            return LuaStatic.GetTable(L, reference);
                        }
        }

        public static Nullable<T> ToNullable<T>(IntPtr L, int stackPos)
        {
                        if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNIL)
                        {
                            return null;
                        }

                        return StackTraits<T>.To(L, stackPos);
        }

        // RVA: 0x1F72EB8
        private static object ToObjectVec3(IntPtr L, int stackPos)
        {
                        return ToVector3(L, stackPos);
        }

        // RVA: 0x1F72F54
        private static object ToObjectQuat(IntPtr L, int stackPos)
        {
                        return ToQuaternion(L, stackPos);
        }

        // RVA: 0x1F72FF4
        private static object ToObjectColor(IntPtr L, int stackPos)
        {
                        return ToColor(L, stackPos);
        }

        // RVA: 0x1F73094
        private static object ToObjectVec4(IntPtr L, int stackPos)
        {
                        return ToVector4(L, stackPos);
        }

        // RVA: 0x1F73134
        private static object ToObjectVec2(IntPtr L, int stackPos)
        {
                        return ToVector2(L, stackPos);
        }

        // RVA: 0x1F731C4
        private static object ToObjectRay(IntPtr L, int stackPos)
        {
                        return ToRay(L, stackPos);
        }

        // RVA: 0x1F7326C
        private static object ToObjectLayerMask(IntPtr L, int stackPos)
        {
                        return ToLayerMask(L, stackPos);
        }

        // RVA: 0x1F73300
        private static object ToObjectBounds(IntPtr L, int stackPos)
        {
                        return ToBounds(L, stackPos);
        }

        // RVA: 0x1F733A8
        public static LuaFunction CheckLuaFunction(IntPtr L, int stackPos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, stackPos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TFUNCTION:
                                stackPos = LuaDLL.abs_index(L, stackPos);
                                LuaDLL.lua_pushvalue(L, stackPos);
                                int reference = LuaDLL.toluaL_ref(L);
                                return LuaStatic.GetFunction(L, reference);
                            default:
                                LuaDLL.luaL_typerror(L, stackPos, "function");
                                return null;
                        }
        }

        // RVA: 0x1F734C8
        public static LuaTable CheckLuaTable(IntPtr L, int stackPos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TTABLE || luaType == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x1F735E8
        public static LuaThread CheckLuaThread(IntPtr L, int stackPos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TTHREAD || luaType == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x1F73708
        public static LuaBaseRef CheckLuaBaseRef(IntPtr L, int stackPos)
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

        // RVA: 0x1F738EC
        public static string CheckString(IntPtr L, int stackPos)
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

        // RVA: 0x1F73B4C
        public static IntPtr CheckIntPtr(IntPtr L, int stackPos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, stackPos);

                        switch(luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return IntPtr.Zero;
                            case LuaTypes.LUA_TLIGHTUSERDATA:
                                return LuaDLL.lua_touserdata(L, stackPos);
                            default:
                                LuaDLL.luaL_typerror(L, stackPos, "IntPtr");
                                return IntPtr.Zero;
                        }            
        }

        // RVA: 0x1F71750
        public static Type CheckMonoType(IntPtr L, int stackPos)
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

        // RVA: 0x1F73C40
        public static IEnumerator CheckIter(IntPtr L, int stackPos)
        {
                        int udata = LuaDLL.tolua_rawnetobj(L, stackPos);

                        if (udata != -1)
                        {
                            ObjectTranslator translator = ObjectTranslator.Get(L);
                            object obj = translator.GetObject(udata);

                            if (obj != null)
                            {                    
                                if (obj is IEnumerator)
                                {
                                    return (IEnumerator)obj;
                                }

                                LuaDLL.luaL_argerror(L, stackPos, string.Format("Type expected, got {0}", obj.GetType().FullName));
                            }

                            return null;
                        }
                        else if (LuaDLL.lua_isnil(L, stackPos))
                        {
                            return null;
                        }

                        LuaDLL.luaL_typerror(L, stackPos, "Type");
                        return null;
        }

        // RVA: 0x1F71220
        public static object CheckObject(IntPtr L, int stackPos)
        {
                        int udata = LuaDLL.tolua_rawnetobj(L, stackPos);

                        if (udata != -1)
                        {
                            ObjectTranslator translator = ObjectTranslator.Get(L);
                            return translator.GetObject(udata);
                        }
                        else if (LuaDLL.lua_isnil(L, stackPos))
                        {
                            return null;
                        }

                        LuaDLL.luaL_typerror(L, stackPos, "object");
                        return null;
        }

        // RVA: 0x1F73E74
        public static object CheckObject(IntPtr L, int stackPos, Type type)
        {
                        int udata = LuaDLL.tolua_rawnetobj(L, stackPos);

                        if (udata != -1)
                        {
                            ObjectTranslator translator = ObjectTranslator.Get(L);
                            object obj = translator.GetObject(udata);

                            if (obj != null)
                            {
                                Type objType = obj.GetType();

                                if (type == objType || type.IsAssignableFrom(objType))
                                {
                                    return obj;
                                }

                                LuaDLL.luaL_argerror(L, stackPos, string.Format("{0} expected, got {1}", LuaMisc.GetTypeName(type), LuaMisc.GetTypeName(objType)));
                            }

                            return null;
                        }
                        else if (LuaDLL.lua_isnil(L, stackPos))
                        {
                            return null;
                        }

                        LuaDLL.luaL_typerror(L, stackPos, LuaMisc.GetTypeName(type));
                        return null;
        }

        public static object CheckObject<T>(IntPtr L, int stackPos)
        {
                        int udata = LuaDLL.tolua_rawnetobj(L, stackPos);

                        if (udata != -1)
                        {
                            ObjectTranslator translator = ObjectTranslator.Get(L);
                            object obj = translator.GetObject(udata);

                            if (obj != null)
                            {
                                if (obj is T)
                                {
                                    return obj;
                                }

                                Type objType = obj.GetType();
                                LuaDLL.luaL_argerror(L, stackPos, string.Format("{0} expected, got {1}", TypeTraits<T>.GetTypeName(), objType.FullName));
                            }

                            return null;
                        }
                        else if (LuaDLL.lua_isnil(L, stackPos))
                        {
                            return null;
                        }

                        LuaDLL.luaL_typerror(L, stackPos, TypeTraits<T>.GetTypeName());
                        return null;
        }

        // RVA: 0x1F740F4
        public static Vector3 CheckVector3(IntPtr L, int stackPos)
        {
                        int type = LuaDLL.tolua_getvaluetype(L, stackPos);

                        if (type != LuaValueType.Vector3)
                        {
                            LuaDLL.luaL_typerror(L, stackPos, "Vector3", LuaValueTypeName.Get(type));
                            return Vector3.zero;
                        }

                        float x, y, z;
                        LuaDLL.tolua_getvec3(L, stackPos, out x, out y, out z);
                        return new Vector3(x, y, z);
        }

        // RVA: 0x1F74280
        public static Quaternion CheckQuaternion(IntPtr L, int stackPos)
        {
                        int type = LuaDLL.tolua_getvaluetype(L, stackPos);

                        if (type != LuaValueType.Quaternion)
                        {
                            LuaDLL.luaL_typerror(L, stackPos, "Quaternion", LuaValueTypeName.Get(type));
                            return Quaternion.identity;
                        }

                        float x, y, z, w;
                        LuaDLL.tolua_getquat(L, stackPos, out x, out y, out z, out w);
                        return new Quaternion(x, y, z, w);
        }

        // RVA: 0x1F74410
        public static Vector2 CheckVector2(IntPtr L, int stackPos)
        {
                        int type = LuaDLL.tolua_getvaluetype(L, stackPos);

                        if (type != LuaValueType.Vector2)
                        {
                            LuaDLL.luaL_typerror(L, stackPos, "Vector2", LuaValueTypeName.Get(type));
                            return Vector2.zero;
                        }

                        float x, y;
                        LuaDLL.tolua_getvec2(L, stackPos, out x, out y);
                        return new Vector2(x, y);
        }

        // RVA: 0x1F74584
        public static Vector4 CheckVector4(IntPtr L, int stackPos)
        {
                        int type = LuaDLL.tolua_getvaluetype(L, stackPos);

                        if (type != LuaValueType.Vector4)
                        {
                            LuaDLL.luaL_typerror(L, stackPos, "Vector4", LuaValueTypeName.Get(type));
                            return Vector4.zero;
                        }

                        float x, y, z, w;
                        LuaDLL.tolua_getvec4(L, stackPos, out x, out y, out z, out w);
                        return new Vector4(x, y, z, w);
        }

        // RVA: 0x1F74714
        public static Color CheckColor(IntPtr L, int stackPos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Color;
                        }

                        return false;            
        }

        // RVA: 0x1F74884
        public static Ray CheckRay(IntPtr L, int stackPos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Ray;
                        }

                        return false;            
        }

        // RVA: 0x1F749C8
        public static Bounds CheckBounds(IntPtr L, int stackPos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Bounds;
                        }

                        return false;            
        }

        // RVA: 0x1F74B0C
        public static LayerMask CheckLayerMask(IntPtr L, int stackPos)
        {
                        if (LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE)
                        {
                            return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.LayerMask;
                        }

                        return false;            
        }

        public static T CheckValue<T>(IntPtr L, int stackPos)
        {
                        return StackTraits<T>.Check(L, stackPos);
        }

        public static Nullable<T> CheckNullable<T>(IntPtr L, int stackPos)
        {
                        if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNIL)
                        {
                            return null;
                        }

                        return StackTraits<T>.Check(L, stackPos);
        }

        // RVA: 0x1F74C38
        public static object CheckVarObject(IntPtr L, int stackPos, Type t)
        {
                        bool beValue = TypeChecker.IsValueType(t);            
                        LuaTypes luaType = LuaDLL.lua_type(L, stackPos);

                        if (!beValue && luaType == LuaTypes.LUA_TNIL)
                        {
                            return null;
                        }

                        if (beValue)
                        {
                            if (TypeChecker.IsNullable(t))
                            {
                                if (luaType == LuaTypes.LUA_TNIL)
                                {
                                    return null;
                                }

                                Type[] ts = t.GetGenericArguments();
                                t = ts[0];
                            }

                            if (t == typeof(bool))
                            {
                                return LuaDLL.luaL_checkboolean(L, stackPos);
                            }
                            else if (t == typeof(long))
                            {
                                return LuaDLL.tolua_checkint64(L, stackPos);
                            }
                            else if (t == typeof(ulong))
                            {
                                return LuaDLL.tolua_checkuint64(L, stackPos);
                            }
                            else if (t.IsPrimitive)
                            {
                                double d = LuaDLL.luaL_checknumber(L, stackPos);
                                return Convert.ChangeType(d, t);
                            }
                            else if (t == typeof(LuaByteBuffer))
                            {
                                int len = 0;
                                IntPtr source = LuaDLL.tolua_tolstring(L, stackPos, out len);
                                return new LuaByteBuffer(source, len);
                            }
                            else if (t == typeof(Vector3))
                            {
                                return CheckVector3(L, stackPos);
                            }
                            else if (t == typeof(Quaternion))
                            {
                                return CheckQuaternion(L, stackPos);
                            }
                            else if (t == typeof(Vector2))
                            {
                                return CheckVector2(L, stackPos);
                            }
                            else if (t == typeof(Vector4))
                            {
                                return CheckVector4(L, stackPos);
                            }
                            else if (t == typeof(Color))
                            {
                                return CheckColor(L, stackPos);
                            }
                            else if (t == typeof(Ray))
                            {
                                return CheckRay(L, stackPos);
                            }
                            else if (t == typeof(Bounds))
                            {
                                return CheckBounds(L, stackPos);
                            }
                            else if (t == typeof(LayerMask))
                            {
                                return CheckLayerMask(L, stackPos);
                            }
                            else
                            {
                                if (luaType == LuaTypes.LUA_TTABLE)
                                {
                                    object o = ToVarTable(L, stackPos);

                                    if (o.GetType() != t)
                                    {
                                        LuaDLL.luaL_typerror(L, stackPos, LuaMisc.GetTypeName(t));
                                    }

                                    return o;
                                }
                                else
                                {
                                    return CheckObject(L, stackPos, t);
                                }
                            }
                        }
                        else
                        {
                            if (t.IsEnum)
                            {
                                return ToLua.CheckObject(L, stackPos, t);
                            }
                            else if ( t == typeof(string))
                            {
                                return CheckString(L, stackPos);
                            }
                            else
                            {
                                return CheckObject(L, stackPos, t);
                            }
                        }
        }

        // RVA: 0x1F756EC
        public static Object CheckUnityObject(IntPtr L, int stackPos, Type type)
        {
                        int udata = LuaDLL.tolua_rawnetobj(L, stackPos);
                        object obj = null;

                        if (udata != -1)
                        {
                            ObjectTranslator translator = ObjectTranslator.Get(L);
                            obj = translator.GetObject(udata);

                            if (obj != null)
                            {
                                UnityEngine.Object uObj = (UnityEngine.Object)obj;

                                if (uObj == null)
                                {
                                    LuaDLL.luaL_argerror(L, stackPos, string.Format("{0} expected, got nil", type.FullName));
                                    return null;
                                }

                                Type objType = uObj.GetType();

                                if (type == objType || objType.IsSubclassOf(type))
                                {
                                    return uObj;
                                }

                                LuaDLL.luaL_argerror(L, stackPos, string.Format("{0} expected, got {1}", type.FullName, objType.FullName));
                            }

                            //传递了tolua.null过来
                            return null;
                        }
                        else if (LuaDLL.lua_isnil(L, stackPos))
                        {
                            return null;
                        }

                        LuaDLL.luaL_typerror(L, stackPos, type.FullName);
                        return null;
        }

        // RVA: 0x1F75A2C
        public static TrackedReference CheckTrackedReference(IntPtr L, int stackPos, Type type)
        {
                        int udata = LuaDLL.tolua_rawnetobj(L, stackPos);
                        object obj = null;

                        if (udata != -1)
                        {
                            ObjectTranslator translator = ObjectTranslator.Get(L);
                            obj = translator.GetObject(udata);

                            if (obj != null)
                            {                    
                                UnityEngine.TrackedReference uObj = (UnityEngine.TrackedReference)obj;

                                if (uObj == null)
                                {
                                    LuaDLL.luaL_argerror(L, stackPos, string.Format("{0} expected, got nil", type.FullName));
                                    return null;
                                }

                                Type objType = uObj.GetType();

                                if (type == objType || objType.IsSubclassOf(type))
                                {
                                    return uObj;
                                }

                                LuaDLL.luaL_argerror(L, stackPos, string.Format("{0} expected, got {1}", type.FullName, objType.FullName));
                            }

                            return null;
                        }
                        else if (LuaDLL.lua_isnil(L, stackPos))
                        {
                            return null;
                        }

                        LuaDLL.luaL_typerror(L, stackPos, type.FullName);
                        return null;
        }

        // RVA: 0x1F71498
        public static object[] CheckObjectArray(IntPtr L, int stackPos)
        {
                        return CheckArray(typeof(object[]), L, pos);
        }

        public static T[] CheckObjectArray<T>(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch(luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TTABLE:
                                int len = LuaDLL.lua_objlen(L, stackPos);
                                T[] list = new T[len];
                                int pos = LuaDLL.lua_gettop(L) + 1;

                                for (int i = 1; i <= len; i++)
                                {
                                    LuaDLL.lua_rawgeti(L, stackPos, i);

                                    if (!TypeTraits<T>.Check(L, pos))
                                    {
                                        LuaDLL.lua_pop(L, 1);
                                        LuaDLL.luaL_typerror(L, stackPos, typeof(T[]).FullName);
                                        return list;
                                    }

                                    list[i - 1] = StackTraits<T>.To(L, pos);
                                    LuaDLL.lua_pop(L, 1);
                                }
                                return list;
                            case LuaTypes.LUA_TUSERDATA:
                                return (T[])CheckObject(L, stackPos, typeof(T[]));
                            default:
                                LuaDLL.luaL_typerror(L, stackPos, TypeTraits<T[]>.GetTypeName());
                                return null;
                        }
        }

        public static T[] CheckStructArray<T>(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch (luatype)
                        {
                            case LuaTypes.LUA_TTABLE:                    
                                int len = LuaDLL.lua_objlen(L, stackPos);
                                T[] list = new T[len];
                                int pos = LuaDLL.lua_gettop(L) + 1;

                                for (int i = 1; i <= len; i++)
                                {
                                    LuaDLL.lua_rawgeti(L, stackPos, i);                        

                                    if (!TypeTraits<T>.Check(L, pos))
                                    {
                                        LuaDLL.lua_pop(L, 1);
                                        LuaDLL.luaL_typerror(L, stackPos, typeof(T[]).FullName);
                                        return list;
                                    }

                                    list[i-1] = StackTraits<T>.To(L, pos);
                                    LuaDLL.lua_pop(L, 1);                        
                                }
                                return list;       
                            case LuaTypes.LUA_TUSERDATA:
                                return (T[])CheckObject(L, stackPos, typeof(T[]));
                            default:
                                LuaDLL.luaL_typerror(L, stackPos, TypeTraits<T[]>.GetTypeName());
                                return null;
                        }
        }

        // RVA: 0x1F75D54
        public static char[] CheckCharBuffer(IntPtr L, int stackPos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, stackPos);            

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TSTRING:
                                string str = LuaDLL.lua_tostring(L, stackPos);
                                return str.ToCharArray(); ;
                            case LuaTypes.LUA_TUSERDATA:
                                return (char[])CheckObject(L, stackPos, typeof(char[]));
                            default:
                                LuaDLL.luaL_typerror(L, stackPos, "string or char[]");
                                return null;
                        }
        }

        // RVA: 0x1F75F00
        public static byte[] CheckByteBuffer(IntPtr L, int stackPos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, pos);
                        return luaType == LuaTypes.LUA_TSTRING || luaType == LuaTypes.LUA_TNIL;
        }

        public static T[] CheckNumberArray<T>(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch(luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TTABLE:                    
                                int len = LuaDLL.lua_objlen(L, stackPos);
                                T[] list = new T[len];
                                int pos = LuaDLL.lua_gettop(L) + 1;

                                for (int i = 1; i <= len; i++)
                                {
                                    LuaDLL.lua_rawgeti(L, stackPos, i);                        

                                    if (!TypeTraits<T>.Check(L, pos))
                                    {
                                        LuaDLL.lua_pop(L, 1);
                                        LuaDLL.luaL_typerror(L, stackPos, TypeTraits<T[]>.GetTypeName());
                                        return list;
                                    }

                                    list[i - 1] = StackTraits<T>.To(L, pos);
                                    LuaDLL.lua_pop(L, 1);
                                }

                                return list;
                            case LuaTypes.LUA_TUSERDATA:
                                return (T[])CheckObject(L, stackPos, typeof(T[]));
                            default:
                                LuaDLL.luaL_typerror(L, stackPos, TypeTraits<T[]>.GetTypeName());
                                return null;
                        }
        }

        // RVA: 0x1F76104
        public static bool[] CheckBoolArray(IntPtr L, int stackPos)
        {
                        return CheckArray(typeof(bool[]), L, pos);
        }

        // RVA: 0x1F763F0
        public static string[] CheckStringArray(IntPtr L, int stackPos)
        {
                        return CheckArray(typeof(string[]), L, pos);
        }

        // RVA: 0x1F76774
        public static object CheckGenericObject(IntPtr L, int stackPos, Type type, out Type ArgType)
        {
                        object obj = ToLua.ToObject(L, 1);
                        Type t = obj.GetType();
                        ArgType = null;

                        if (t.IsGenericType && t.GetGenericTypeDefinition() == type)
                        {
                            Type[] ts = t.GetGenericArguments();
                            ArgType = ts[0];
                            return obj;
                        }

                        LuaDLL.luaL_argerror(L, stackPos, LuaMisc.GetTypeName(type));
                        return null;
        }

        // RVA: 0x1F76910
        public static object CheckGenericObject(IntPtr L, int stackPos, Type type, out Type t1, out Type t2)
        {
                        object obj = ToLua.ToObject(L, 1);
                        Type t = obj.GetType();
                        t1 = null;
                        t2 = null;

                        if (t.IsGenericType && t.GetGenericTypeDefinition() == type)
                        {
                            Type[] ts = t.GetGenericArguments();
                            t1 = ts[0];
                            t2 = ts[1];
                            return obj;
                        }

                        LuaDLL.luaL_argerror(L, stackPos, LuaMisc.GetTypeName(type));
                        return null;
        }

        // RVA: 0x1F76AC8
        public static object CheckGenericObject(IntPtr L, int stackPos, Type type)
        {
                        object obj = ToLua.ToObject(L, 1);
                        Type t = obj.GetType();

                        if (t.IsGenericType && t.GetGenericTypeDefinition() == type)
                        {
                            return obj;
                        }

                        LuaDLL.luaL_argerror(L, stackPos, LuaMisc.GetTypeName(type));
                        return null;
        }

        // RVA: 0x1F76C1C
        public static object[] ToParamsObject(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        object[] list = new object[count];
                        int pos = 0;

                        while (pos < count)
                        {
                            list[pos++] = ToVarObject(L, stackPos++);                                                
                        }

                        return list;
        }

        public static T[] ToParamsObject<T>(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        T[] list = new T[count];            
                        int pos = 0; 

                        while (pos < count)
                        {
                            list[pos++] = StackTraits<T>.To(L, stackPos++);                 
                        }

                        return list;
        }

        // RVA: 0x1F76D44
        public static string[] ToParamsString(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        string[] list = new string[count];
                        int pos = 0;   

                        while (pos < count)
                        {
                            list[pos++] = ToString(L, stackPos++);                       
                        }

                        return list;
        }

        public static T[] ToParamsNumber<T>(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        T[] list = new T[count];            
                        int pos = 0;       

                        while (pos < count)
                        {                                
                            list[pos++] = StackTraits<T>.To(L, stackPos++);
                        }

                        return list;
        }

        // RVA: 0x1F76E6C
        public static char[] ToParamsChar(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        char[] list = new char[count];
                        int pos = 0;

                        while (pos < count)
                        {
                            list[pos++] = (char)LuaDLL.lua_tointeger(L, stackPos++);                                 
                        }

                        return list;
        }

        // RVA: 0x1F76F70
        public static bool[] CheckParamsBool(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        bool[] list = new bool[count];
                        int pos = 0;

                        while (pos < count)
                        {
                            list[pos++] = LuaDLL.luaL_checkboolean(L, stackPos++);                
                        }

                        return list;
        }

        public static T[] CheckParamsNumber<T>(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        T[] list = new T[count];                                    
                        int pos = 0;

                        while (pos < count)
                        {                                
                            list[pos++] = StackTraits<T>.Check(L, stackPos++);
                        }

                        return list;
        }

        // RVA: 0x1F77078
        public static char[] CheckParamsChar(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        char[] list = new char[count];
                        int pos = 0;

                        while (pos < count)
                        {
                            list[pos++] = (char)LuaDLL.luaL_checkinteger(L, stackPos++);                
                        }

                        return list;
        }

        // RVA: 0x1F7717C
        public static string[] CheckParamsString(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        string[] list = new string[count];                        
                        int pos = 0;

                        while (pos < count)
                        {
                            list[pos++] = CheckString(L, stackPos++);                                                
                        }

                        return list;
        }

        public static T[] CheckParamsObject<T>(IntPtr L, int stackPos, int count)
        {
                        if (count <= 0)
                        {
                            return null;
                        }

                        T[] list = new T[count];            
                        int pos = 0;

                        while (pos < count)
                        {                
                            list[pos++] = StackTraits<T>.Check(L, stackPos++);
                        }

                        return list;
        }

        // RVA: 0x1F772A4
        public static char[] ToCharBuffer(IntPtr L, int stackPos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, stackPos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TSTRING:
                                string str = LuaDLL.lua_tostring(L, stackPos);
                                return str.ToCharArray();
                            case LuaTypes.LUA_TUSERDATA:
                                return (char[])ToObject(L, stackPos);
                            default:                    
                                return null;
                        }
        }

        // RVA: 0x1F773D0
        public static byte[] ToByteBuffer(IntPtr L, int stackPos)
        {
                        LuaTypes luaType = LuaDLL.lua_type(L, stackPos);

                        switch (luaType)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TSTRING:
                                int len;
                                IntPtr source = LuaDLL.lua_tolstring(L, stackPos, out len);
                                byte[] buffer = new byte[len];
                                Marshal.Copy(source, buffer, 0, len);
                                return buffer;
                            case LuaTypes.LUA_TUSERDATA:
                                return (byte[])ToObject(L, stackPos);
                            default:                    
                                return null;
                        }
        }

        public static T[] ToNumberArray<T>(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch (luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TTABLE:
                                int len = LuaDLL.lua_objlen(L, stackPos);
                                T[] list = new T[len];
                                int pos = LuaDLL.lua_gettop(L) + 1;

                                for (int i = 1; i <= len; i++)
                                {
                                    LuaDLL.lua_rawgeti(L, stackPos, i);

                                    if (!TypeTraits<T>.Check(L, pos))
                                    {
                                        LuaDLL.lua_pop(L, 1);
                                        LuaDLL.luaL_typerror(L, stackPos, TypeTraits<T[]>.GetTypeName());
                                        return list;
                                    }

                                    list[i - 1] = StackTraits<T>.To(L, pos);
                                    LuaDLL.lua_pop(L, 1);
                                }

                                return list;
                            case LuaTypes.LUA_TUSERDATA:
                                return (T[])ToObject(L, stackPos);
                            default:
                                return null;
                        }
        }

        // RVA: 0x1F77560
        public static bool[] ToBoolArray(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch (luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TTABLE:
                                int len = LuaDLL.lua_objlen(L, stackPos);
                                bool[] list = new bool[len];
                                int pos = LuaDLL.lua_gettop(L) + 1;

                                for (int i = 1; i <= len; i++)
                                {
                                    LuaDLL.lua_rawgeti(L, stackPos, i);

                                    if (LuaDLL.lua_type(L, pos) != LuaTypes.LUA_TBOOLEAN)
                                    {
                                        LuaDLL.lua_pop(L, 1);
                                        LuaDLL.luaL_typerror(L, stackPos, "bool[]");
                                        return list;
                                    }

                                    list[i - 1] = LuaDLL.lua_toboolean(L, pos);
                                    LuaDLL.lua_pop(L, 1);
                                }

                                return list;
                            case LuaTypes.LUA_TUSERDATA:
                                return (bool[])ToObject(L, stackPos);
                            default:
                                return null;
                        }
        }

        // RVA: 0x1F777D0
        public static string[] ToStringArray(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch(luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TTABLE:
                                int len = LuaDLL.lua_objlen(L, stackPos);
                                string[] list = new string[len];
                                int pos = LuaDLL.lua_gettop(L) + 1;

                                for (int i = 1; i <= len; i++)
                                {
                                    LuaDLL.lua_rawgeti(L, stackPos, i);

                                    if (!TypeTraits<string>.Check(L, pos))
                                    {
                                        LuaDLL.lua_pop(L, 1);
                                        LuaDLL.luaL_typerror(L, stackPos, "string[]");
                                        return list;
                                    }

                                    list[i - 1] = StackTraits<string>.To(L, pos);
                                    LuaDLL.lua_pop(L, 1);
                                }
                                return list;
                            case LuaTypes.LUA_TUSERDATA:
                                return (string[])ToObject(L, stackPos);
                            default:
                                return null;
                        }                    
        }

        // RVA: 0x1F77AD8
        public static object[] ToObjectArray(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch(luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TTABLE:
                                int len = LuaDLL.lua_objlen(L, stackPos);
                                object[] list = new object[len];
                                int pos = LuaDLL.lua_gettop(L) + 1;

                                for (int i = 1; i <= len; i++)
                                {
                                    LuaDLL.lua_rawgeti(L, stackPos, i);
                                    list[i - 1] = ToVarObject(L, pos);
                                    LuaDLL.lua_pop(L, 1);
                                }
                                return list;
                            case LuaTypes.LUA_TUSERDATA:
                                return (object[])ToObject(L, stackPos);
                            default:
                                return null;
                        }
        }

        public static T[] ToObjectArray<T>(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch (luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TTABLE:
                                int len = LuaDLL.lua_objlen(L, stackPos);
                                T[] list = new T[len];
                                int pos = LuaDLL.lua_gettop(L) + 1;

                                for (int i = 1; i <= len; i++)
                                {
                                    LuaDLL.lua_rawgeti(L, stackPos, i);

                                    if (!TypeTraits<T>.Check(L, pos))
                                    {
                                        LuaDLL.lua_pop(L, 1);
                                        LuaDLL.luaL_typerror(L, stackPos, typeof(T[]).FullName);
                                        return list;
                                    }

                                    list[i - 1] = StackTraits<T>.To(L, pos);
                                    LuaDLL.lua_pop(L, 1);
                                }
                                return list;
                            case LuaTypes.LUA_TUSERDATA:
                                return (T[])ToObject(L, stackPos);
                            default:
                                return null;
                        }
        }

        public static T[] ToStructArray<T>(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch (luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TTABLE:
                                int len = LuaDLL.lua_objlen(L, stackPos);
                                T[] list = new T[len];
                                int pos = LuaDLL.lua_gettop(L) + 1;

                                for (int i = 1; i <= len; i++)
                                {
                                    LuaDLL.lua_rawgeti(L, stackPos, i);

                                    if (!TypeTraits<T>.Check(L, pos))
                                    {
                                        LuaDLL.lua_pop(L, 1);
                                        LuaDLL.luaL_typerror(L, stackPos, typeof(T[]).FullName);
                                        return list;
                                    }

                                    list[i - 1] = StackTraits<T>.To(L, pos);
                                    LuaDLL.lua_pop(L, 1);
                                }
                                return list;
                            case LuaTypes.LUA_TUSERDATA:
                                return (T[])ToObject(L, stackPos);
                            default:
                                return null;
                        }
        }

        // RVA: 0x1F77D14
        public static void Push(IntPtr L, Vector3 v3)
        {
                        LuaDLL.tolua_pushvec3(L, v3.x, v3.y, v3.z);
        }

        // RVA: 0x1F77DA4
        public static void Push(IntPtr L, Vector2 v2)
        {
                        LuaDLL.tolua_pushvec2(L, v2.x, v2.y);
        }

        // RVA: 0x1F77E24
        public static void Push(IntPtr L, Vector4 v4)
        {
                        LuaDLL.tolua_pushvec4(L, v4.x, v4.y, v4.z, v4.w);
        }

        // RVA: 0x1F77EBC
        public static void Push(IntPtr L, Quaternion q)
        {
                        LuaDLL.tolua_pushquat(L, q.x, q.y, q.z, q.w);
        }

        // RVA: 0x1F77F54
        public static void Push(IntPtr L, Color clr)
        {
                        LuaDLL.tolua_pushclr(L, clr.r, clr.g, clr.b, clr.a);
        }

        // RVA: 0x1F77FEC
        public static void Push(IntPtr L, Ray ray)
        {
                        LuaStatic.GetPackRay(L);
                        Push(L, ray.direction);
                        Push(L, ray.origin);

                        if (LuaDLL.lua_pcall(L, 2, 1, 0) != 0)
                        {
                            string error = LuaDLL.lua_tostring(L, -1);
                            throw new LuaException(error);
                        }
        }

        // RVA: 0x1F7815C
        public static void Push(IntPtr L, Bounds bound)
        {
                        LuaStatic.GetPackBounds(L);
                        Push(L, bound.center);
                        Push(L, bound.size);

                        if (LuaDLL.lua_pcall(L, 2, 1, 0) != 0)
                        {
                            string error = LuaDLL.lua_tostring(L, -1);
                            throw new LuaException(error);
                        }
        }

        // RVA: 0x1F782CC
        public static void Push(IntPtr L, RaycastHit hit)
        {
                        LuaStatic.GetPackRaycastHit(L);
                        Push(L, hit.collider);
                        LuaDLL.lua_pushnumber(L, hit.distance);
                        Push(L, hit.normal);
                        Push(L, hit.point);
                        Push(L, hit.rigidbody);
                        Push(L, hit.transform);

                        if (LuaDLL.lua_pcall(L, 6, 1, 0) != 0)
                        {
                            string error = LuaDLL.lua_tostring(L, -1);
                            throw new LuaException(error);
                        }
        }

        // RVA: 0x1F7856C
        public static void Push(IntPtr L, RaycastHit hit, int flag)
        {
                        LuaStatic.GetPackRaycastHit(L);

                        if ((flag & RaycastBits.Collider) != 0)
                        {
                            Push(L, hit.collider);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }

                        LuaDLL.lua_pushnumber(L, hit.distance);

                        if ((flag & RaycastBits.Normal) != 0)
                        {
                            Push(L, hit.normal);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }

                        if ((flag & RaycastBits.Point) != 0)
                        {
                            Push(L, hit.point);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }

                        if ((flag & RaycastBits.Rigidbody) != 0)
                        {            
                            Push(L, hit.rigidbody);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }

                        if ((flag & RaycastBits.Transform) != 0)
                        {
                            Push(L, hit.transform);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }

                        if (LuaDLL.lua_pcall(L, 6, 1, 0) != 0)
                        {
                            string error = LuaDLL.lua_tostring(L, -1);
                            throw new LuaException(error);
                        }
        }

        // RVA: 0x1F788FC
        public static void Push(IntPtr L, Touch t)
        {
                        Push(L, t, TouchBits.ALL);
        }

        // RVA: 0x1F789A0
        public static void Push(IntPtr L, Touch t, int flag)
        {
                        LuaStatic.GetPackTouch(L);
                        LuaDLL.lua_pushinteger(L, t.fingerId);

                        if ((flag & TouchBits.Position) != 0)
                        {
                            Push(L, t.position);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }

                        if ((flag & TouchBits.RawPosition) != 0)
                        {
                            Push(L, t.rawPosition);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }

                        if ((flag & TouchBits.DeltaPosition) != 0)
                        {
                            Push(L, t.deltaPosition);
                        }
                        else
                        {
                            LuaDLL.lua_pushnil(L);
                        }

                        LuaDLL.lua_pushnumber(L, t.deltaTime);
                        LuaDLL.lua_pushinteger(L, t.tapCount);
                        LuaDLL.lua_pushinteger(L, (int)t.phase);

                        if (LuaDLL.lua_pcall(L, 7, -1, 0) != 0)
                        {
                            string error = LuaDLL.lua_tostring(L, -1);
                            throw new LuaException(error);
                        }
        }

        // RVA: 0x1F78C98
        public static void PushLayerMask(IntPtr L, LayerMask l)
        {
                        LuaDLL.tolua_pushlayermask(L, l.value);
        }

        // RVA: 0x1F78D28
        public static void Push(IntPtr L, LuaByteBuffer bb)
        {
                        LuaDLL.lua_pushlstring(L, bb.buffer, bb.buffer.Length);
        }

        // RVA: 0x1F78DAC
        public static void PushByteBuffer(IntPtr L, byte[] buffer)
        {
                        LuaDLL.tolua_pushlstring(L, buffer, buffer.Length);
        }

        // RVA: 0x1F7197C
        public static void Push(IntPtr L, Array array)
        {
                        if (array == null)
                        {
                            LuaDLL.lua_pushnil(L);
                        }
                        else
                        {                
                            int arrayMetaTable = LuaStatic.GetArrayMetatable(L);
                            PushUserData(L, array, arrayMetaTable);
                        }
        }

        // RVA: 0x1F78FA8
        public static void Push(IntPtr L, LuaBaseRef lbr)
        {
                        if (lbr == null)
                        {
                            LuaDLL.lua_pushnil(L);
                        }
                        else
                        {                
                            LuaDLL.lua_getref(L, lbr.GetReference());
                        }
        }

        // RVA: 0x1F713A0
        public static void Push(IntPtr L, Type t)
        {
                        if (t == null)
                        {
                            LuaDLL.lua_pushnil(L);
                        }
                        else
                        {
                            int typeMetatable = LuaStatic.GetTypeMetatable(L);
                            PushUserData(L, t, typeMetatable);
                        }
        }

        // RVA: 0x1F7908C
        public static void Push(IntPtr L, Delegate ev)
        {
                        ToLua.Push(L, ev);
        }

        // RVA: 0x1F79154
        public static void Push(IntPtr L, EventObject ev)
        {
                        if (ev == null)
                        {
                            LuaDLL.lua_pushnil(L);
                        }
                        else
                        {
                            int eventMetatable = LuaStatic.GetEventMetatable(L);                
                            PushUserData(L, ev, eventMetatable);
                        }
        }

        // RVA: 0x1F7921C
        public static void Push(IntPtr L, IEnumerator iter)
        {
                        if (iter == null)
                        {
                            LuaDLL.lua_pushnil(L);
                        }
                        else
                        {                
                            int reference = LuaStatic.GetMetaReference(L, iter.GetType());

                            if (reference > 0)
                            {
                                PushUserData(L, iter, reference);
                            }
                            else
                            {
                                int iterMetatable = LuaStatic.GetIterMetatable(L);
                                PushUserData(L, iter, iterMetatable);
                            }            
                        }
        }

        // RVA: 0x1F7932C
        public static void Push(IntPtr L, Enum e)
        {
            object obj = null;
            int reference = LuaStatic.GetEnumObject(L, e, out obj);
            PushUserData(L, obj, reference);
        }

        public static void PushOut<T>(IntPtr L, LuaOut<T> lo)
        {
                        ObjectTranslator translator = ObjectTranslator.Get(L);
                        int index = translator.AddObject(lo);
                        LuaDLL.tolua_pushnewudata(L, LuaIndexes.LUA_REGISTRYINDEX, index);
        }

        // RVA: 0x1F793CC
        public static void PushStruct(IntPtr L, object o)
        {
                        if (o == null || o.Equals(null))
                        {
                            LuaDLL.lua_pushnil(L);
                            return;
                        }

                        if (o is Enum)
                        {
                            ToLua.Push(L, (Enum)o);
                            return;
                        }

                        Type type = o.GetType();
                        int reference = LuaStatic.GetMetaReference(L, type);            

                        if (reference <= 0)
                        {
                            reference = LoadPreType(L, type);
                        }

                        ObjectTranslator translator = ObjectTranslator.Get(L);
                        int index = translator.AddObject(o);
                        LuaDLL.tolua_pushnewudata(L, reference, index);
        }

        public static void PushValue<T>(IntPtr L, T v)
        {
                        StackTraits<T>.Push(L, v);
        }

        public static void PusNullable<T>(IntPtr L, Nullable<T> v)
        {
                        if (v == null)
                        {
                            LuaDLL.lua_pushnil(L);
                            return;
                        }

                        StackTraits<T>.Push(L, v.Value);
        }

        // RVA: 0x1F78E30
        public static void PushUserData(IntPtr L, object o, int reference)
        {
                        int index;
                        ObjectTranslator translator = ObjectTranslator.Get(L);

                        if (translator.Getudata(o, out index))
                        {
                            if (LuaDLL.tolua_pushudata(L, index))
                            {
                                return;
                            }

                            translator.Destroyudata(index);
                        }

                        index = translator.AddObject(o);
                        LuaDLL.tolua_pushnewudata(L, reference, index);
        }

        // RVA: 0x1F796D0
        private static int LuaPCall(IntPtr L, LuaCSFunction func)
        {
                        int top = LuaDLL.lua_gettop(L);
                        LuaDLL.tolua_pushcfunction(L, func);

                        if (LuaDLL.lua_pcall(L, 0, -1, 0) != 0)
                        {
                            string error = LuaDLL.lua_tostring(L, -1);
                            LuaDLL.lua_settop(L, top);
                            throw new LuaException(error, LuaException.GetLastError());
                        }

                        int reference = LuaDLL.tolua_getclassref(L, -1);              
                        LuaDLL.lua_settop(L, top);
                        return reference;
        }

        // RVA: 0x1F79628
        public static int LoadPreType(IntPtr L, Type type)
        {
                        LuaCSFunction LuaOpenLib = LuaStatic.GetPreModule(L, type);
                        int reference = -1;

                        if (LuaOpenLib != null)
                        {
            #if UNITY_EDITOR
                            Debugger.LogWarning("register PreLoad type {0} to lua", LuaMisc.GetTypeName(type));
            #endif
                            reference = LuaPCall(L, LuaOpenLib);                
                        }
                        else
                        {
                            //类型未Wrap                            
                            reference = LuaStatic.GetMissMetaReference(L, type);                
                        }

                        return reference;
        }

        // RVA: 0x1F79858
        private static void PushUserObject(IntPtr L, object o)
        {
                        Type type = o.GetType();
                        int reference = LuaStatic.GetMetaReference(L, type);

                        if (reference <= 0)
                        {
                            reference = LoadPreType(L, type);
                        }

                        PushUserData(L, o, reference);
        }

        // RVA: 0x1F7848C
        public static void Push(IntPtr L, Object obj)
        {
            if (obj == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            PushUserObject(L, obj);
        }

        // RVA: 0x1F79934
        public static void Push(IntPtr L, TrackedReference obj)
        {
            if (obj == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            PushUserObject(L, obj);
        }

        public static void PushSealed<T>(IntPtr L, T o)
        {
                        if (o == null || o.Equals(null))
                        {
                            LuaDLL.lua_pushnil(L);
                        }
                        else
                        {
                            int reference = TypeTraits<T>.GetLuaReference(L);

                            if (reference <= 0)
                            {
                                reference = LoadPreType(L, o.GetType());
                            }

                            ToLua.PushUserData(L, o, reference);
                        }
        }

        // RVA: 0x1F799F4
        public static void PushObject(IntPtr L, object o)
        {
                        if (o == null || o.Equals(null))
                        {
                            LuaDLL.lua_pushnil(L);
                        }
                        else
                        {
                            if (o is Enum)
                            {
                                ToLua.Push(L, (Enum)o);
                            }
                            else
                            {
                                PushUserObject(L, o);
                            }
                        }
        }

        // RVA: 0x1F79B64
        public static void Push(IntPtr L, nil obj)
        {
                        LuaDLL.lua_pushnil(L);
        }

        // RVA: 0x1F79BCC
        public static void Push(IntPtr L, object obj)
        {
                        ToLua.Push(L, obj);
        }

        // RVA: 0x1F7AF18
        public static void SetBack(IntPtr L, int stackPos, object o)
        {
                        int udata = LuaDLL.tolua_rawnetobj(L, stackPos);
                        ObjectTranslator translator = ObjectTranslator.Get(L);

                        if (udata != -1)
                        {
                            translator.SetBack(udata, o);
                        }
        }

        // RVA: 0x1F7B03C
        public static int Destroy(IntPtr L)
        {
                        int udata = LuaDLL.tolua_rawnetobj(L, 1);
                        ObjectTranslator translator = ObjectTranslator.Get(L);
                        translator.Destroy(udata);
                        return 0;
        }

        // RVA: 0x1F7B138
        public static void CheckArgsCount(IntPtr L, string method, int count)
        {
                        int c = LuaDLL.lua_gettop(L);

                        if (c != count)
                        {
                            throw new LuaException(string.Format("no overload for method '{0}' takes '{1}' arguments", method, c));
                        }
        }

        // RVA: 0x1F7B244
        public static void CheckArgsCount(IntPtr L, int count)
        {
                        int c = LuaDLL.lua_gettop(L);

                        if (c != count)
                        {
                            throw new LuaException(string.Format("no overload for method takes '{0}' arguments", c));
                        }
        }

        // RVA: 0x1F7B340
        public static Delegate CheckDelegate(Type t, IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch (luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TFUNCTION:
                                LuaFunction func = ToLua.ToLuaFunction(L, stackPos);
                                return DelegateFactory.CreateDelegate(t, func);
                            case LuaTypes.LUA_TUSERDATA:
                                return (Delegate)ToLua.CheckObject(L, stackPos, t);
                            default:
                                LuaDLL.luaL_typerror(L, stackPos, LuaMisc.GetTypeName(t));
                                return null;                    
                        }
        }

        public static Delegate CheckDelegate<T>(IntPtr L, int stackPos)
        {
                        LuaTypes luatype = LuaDLL.lua_type(L, stackPos);

                        switch (luatype)
                        {
                            case LuaTypes.LUA_TNIL:
                                return null;
                            case LuaTypes.LUA_TFUNCTION:
                                LuaFunction func = ToLua.ToLuaFunction(L, stackPos);
                                return DelegateTraits<T>.Create(func);
                            case LuaTypes.LUA_TUSERDATA:
                                return (Delegate)ToLua.CheckObject(L, stackPos, typeof(T));
                            default:
                                LuaDLL.luaL_typerror(L, stackPos, TypeTraits<T>.GetTypeName());
                                return null;
                        }
        }
    }
}
