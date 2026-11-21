// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaDLL
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;
using System.Text;

namespace LuaInterface
{
    public class LuaDLL
    {
        public static string version;
        public static int LUA_MULTRET;
        public static string[] LuaTypeName;
        private const string LUADLL = "tolua";

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_pb(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_ffi(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_bit(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_struct(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_lpeg(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_socket_core(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_mime_core(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_cjson(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_cjson_safe(IntPtr L);

        // RVA: 0x2289B0C
        public static int lua_upvalueindex(int i)
        {
            return LuaIndexes.LUA_GLOBALSINDEX - i;
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_close(IntPtr luaState);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr lua_newthread(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr lua_atpanic(IntPtr luaState, IntPtr panic);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_gettop(IntPtr luaState);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_settop(IntPtr luaState, int top);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_pushvalue(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_remove(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_insert(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_replace(IntPtr luaState, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_checkstack(IntPtr luaState, int extra);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_xmove(IntPtr from, IntPtr to, int n);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_isnumber(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_isstring(IntPtr luaState, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_iscfunction(IntPtr luaState, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_isuserdata(IntPtr luaState, int stackPos);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern LuaTypes lua_type(IntPtr luaState, int index);

        // RVA: 0x228A44C
        public static string lua_typename(IntPtr luaState, LuaTypes type)
        {
            return LuaTypeName[(int)type];
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_equal(IntPtr luaState, int idx1, int idx2);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_rawequal(IntPtr luaState, int idx1, int idx2);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_lessthan(IntPtr luaState, int idx1, int idx2);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern double lua_tonumber(IntPtr luaState, int idx);

        // RVA: 0x228A738
        public static int lua_tointeger(IntPtr luaState, int idx)
        {
            return tolua_tointeger(luaState, idx);
        }

        // RVA: 0x228A83C
        public static bool lua_toboolean(IntPtr luaState, int idx)
        {
            return tolua_toboolean(luaState, idx);
        }

        // RVA: 0x228A948
        public static IntPtr lua_tolstring(IntPtr luaState, int index, out int strLen)
        {
            return tolua_tolstring(luaState, index, out strLen);
        }

        // RVA: 0x228AA5C
        public static int lua_objlen(IntPtr luaState, int idx)
        {
            return tolua_objlen(luaState, idx);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr lua_tocfunction(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr lua_touserdata(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr lua_tothread(IntPtr L, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr lua_topointer(IntPtr L, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_pushnil(IntPtr luaState);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_pushnumber(IntPtr luaState, double number);

        // RVA: 0x228AEA8
        public static void lua_pushinteger(IntPtr L, int n)
        {
            lua_pushnumber(L, n);
        }

        // RVA: 0x228AF1C
        public static void lua_pushlstring(IntPtr luaState, byte[] str, int size)
        {
            if (size >= 0x7FFFFF00)
            {
                throw new LuaException("string length overflow");
            }

            tolua_pushlstring(luaState, str, size);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_pushstring(IntPtr luaState, string str);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_pushcclosure(IntPtr luaState, IntPtr fn, int n);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_pushboolean(IntPtr luaState, int value);

        // RVA: 0x228822C
        public static void lua_pushboolean(IntPtr luaState, bool value)
        {
            lua_pushboolean(luaState, value ? 1 : 0);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_pushlightuserdata(IntPtr luaState, IntPtr udata);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_pushthread(IntPtr L);

        // RVA: 0x228B594
        public static void lua_gettable(IntPtr L, int idx)
        {
            if (tolua_gettable(L, idx) != 0)
            {
                string msg = lua_tostring(L, -1);
                throw new LuaException(msg);
            }
        }

        // RVA: 0x228B7C8
        public static void lua_getfield(IntPtr L, int idx, string key)
        {
            if (tolua_getfield(L, idx, key) != 0)
            {
                string msg = lua_tostring(L, -1);
                throw new LuaException(msg);
            }
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_rawget(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_rawgeti(IntPtr luaState, int idx, int n);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_createtable(IntPtr luaState, int narr, int nrec);

        // RVA: 0x228BB24
        public static IntPtr lua_newuserdata(IntPtr luaState, int size)
        {
            return tolua_newuserdata(luaState, size);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_getmetatable(IntPtr luaState, int objIndex);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_getfenv(IntPtr luaState, int idx);

        // RVA: 0x228BD48
        public static void lua_settable(IntPtr L, int idx)
        {
            if (tolua_settable(L, idx) != 0)
            {
                string msg = lua_tostring(L, -1);
                throw new LuaException(msg);
            }
        }

        // RVA: 0x228BEB8
        public static void lua_setfield(IntPtr L, int idx, string key)
        {
            if (tolua_setfield(L, idx, key) != 0)
            {
                string msg = lua_tostring(L, -1);
                throw new LuaException(msg);
            }
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_rawset(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_rawseti(IntPtr luaState, int tableIndex, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_setmetatable(IntPtr luaState, int objIndex);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_setfenv(IntPtr luaState, int stackPos);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_call(IntPtr luaState, int nArgs, int nResults);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_pcall(IntPtr luaState, int nArgs, int nResults, int errfunc);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_cpcall(IntPtr L, IntPtr func, IntPtr ud);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_yield(IntPtr L, int nresults);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_resume(IntPtr L, int narg);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_status(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_gc(IntPtr luaState, LuaGCOptions what, int data);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_next(IntPtr luaState, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_concat(IntPtr luaState, int n);

        // RVA: 0x228C7CC
        public static void lua_pop(IntPtr luaState, int amount)
        {
            lua_settop(luaState, -amount - 1);
        }

        // RVA: 0x228C840
        public static void lua_newtable(IntPtr luaState)
        {
            lua_createtable(luaState, 0, 0);
        }

        // RVA: 0x228C8AC
        public static void lua_register(IntPtr luaState, string name, LuaCSFunction func)
        {
            lua_pushcfunction(luaState, func);
            lua_setglobal(luaState, name);
        }

        // RVA: 0x228C930
        public static void lua_pushcfunction(IntPtr luaState, LuaCSFunction func)
        {
            IntPtr fn = Marshal.GetFunctionPointerForDelegate(func);
            lua_pushcclosure(luaState, fn, 0);
        }

        // RVA: 0x228CA8C
        public static bool lua_isfunction(IntPtr luaState, int n)
        {
            return lua_type(luaState, n) == LuaTypes.LUA_TFUNCTION;
        }

        // RVA: 0x228CB0C
        public static bool lua_istable(IntPtr luaState, int n)
        {
            return lua_type(luaState, n) == LuaTypes.LUA_TTABLE;
        }

        // RVA: 0x228CB8C
        public static bool lua_islightuserdata(IntPtr luaState, int n)
        {
            return lua_type(luaState, n) == LuaTypes.LUA_TLIGHTUSERDATA;
        }

        // RVA: 0x228CC0C
        public static bool lua_isnil(IntPtr luaState, int n)
        {
            return lua_type(luaState, n) == LuaTypes.LUA_TNIL;
        }

        // RVA: 0x228CC8C
        public static bool lua_isboolean(IntPtr luaState, int n)
        {
            return lua_type(luaState, n) == LuaTypes.LUA_TBOOLEAN;
        }

        // RVA: 0x228CD0C
        public static bool lua_isthread(IntPtr luaState, int n)
        {
            return lua_type(luaState, n) == LuaTypes.LUA_TTHREAD;
        }

        // RVA: 0x228CD8C
        public static bool lua_isnone(IntPtr luaState, int n)
        {
            return lua_type(luaState, n) == LuaTypes.LUA_TNONE;
        }

        // RVA: 0x228CE0C
        public static bool lua_isnoneornil(IntPtr luaState, int n)
        {
            return lua_type(luaState, n) <= LuaTypes.LUA_TNIL;
        }

        // RVA: 0x228C9E4
        public static void lua_setglobal(IntPtr luaState, string name)
        {
            lua_setfield(luaState, LuaIndexes.LUA_GLOBALSINDEX, name);
        }

        // RVA: 0x228CE8C
        public static void lua_getglobal(IntPtr luaState, string name)
        {
            lua_getfield(luaState, LuaIndexes.LUA_GLOBALSINDEX, name);
        }

        // RVA: 0x228CF34
        public static string lua_ptrtostring(IntPtr str, int len)
        {
            string ss = Marshal.PtrToStringAnsi(str, len);
            if (ss == null)
            {
                byte[] buffer = new byte[len];
                Marshal.Copy(str, buffer, 0, len);
                return Encoding.UTF8.GetString(buffer);
            }
            return ss;
        }

        // RVA: 0x228B704
        public static string lua_tostring(IntPtr luaState, int index)
        {
            int len;
            IntPtr str = tolua_tolstring(luaState, index, out len);
            if (str != IntPtr.Zero)
            {
                return lua_ptrtostring(str, len);
            }
            return null;
        }

        // RVA: 0x228D030
        public static IntPtr lua_open()
        {
            return luaL_newstate();
        }

        // RVA: 0x228D100
        public static void lua_getregistry(IntPtr L)
        {
            lua_pushvalue(L, LuaIndexes.LUA_REGISTRYINDEX);
        }

        // RVA: 0x228D198
        public static int lua_getgccount(IntPtr L)
        {
            return lua_gc(L, (int)LuaGCOptions.LUA_GCCOUNT, 0);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_getstack(IntPtr L, int level, ref Lua_Debug ar);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_getinfo(IntPtr L, string what, ref Lua_Debug ar);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern string lua_getlocal(IntPtr L, ref Lua_Debug ar, int n);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern string lua_setlocal(IntPtr L, ref Lua_Debug ar, int n);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern string lua_getupvalue(IntPtr L, int funcindex, int n);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern string lua_setupvalue(IntPtr L, int funcindex, int n);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_sethook(IntPtr L, LuaHookFunc func, int mask, int count);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern LuaHookFunc lua_gethook(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_gethookmask(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_gethookcount(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void luaL_openlibs(IntPtr luaState);

        // RVA: 0x228DA5C
        public static int abs_index(IntPtr L, int i)
        {
            if (i > 0 || i <= LuaIndexes.LUA_REGISTRYINDEX)
            {
                return i;
            }
            return lua_gettop(L) + i + 1;
        }

        // RVA: 0x228DB18
        public static int luaL_getn(IntPtr luaState, int i)
        {
            return tolua_getn(luaState, i);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaL_getmetafield(IntPtr luaState, int stackPos, string field);

        // RVA: 0x228DCD0
        public static int luaL_callmeta(IntPtr L, int stackPos, string field)
        {
            stackPos = abs_index(L, stackPos);
            if (luaL_getmetafield(L, stackPos, field) == 0)
            {
                return 0;
            }

            lua_pushvalue(L, stackPos);
            int ret = lua_pcall(L, 1, 1, 0);
            if (ret != 0)
            {
                string msg = lua_tostring(L, -1);
                lua_pop(L, 1);
                throw new LuaException(msg);
            }
            return 1;
        }

        // RVA: 0x228DE18
        public static int luaL_argerror(IntPtr L, int narg, string extramsg)
        {
            if (tolua_argerror(L, narg, extramsg) != 0)
            {
                string msg = lua_tostring(L, -1);
                lua_pop(L, 1);
                throw new LuaException(msg);
            }
            return 0;
        }

        // RVA: 0x228DFBC
        public static int luaL_typerror(IntPtr L, int stackPos, string tname, string t2)
        {
            if (t2 == null)
            {
                t2 = luaL_typename(L, stackPos);
            }

            string msg = string.Format("{0} expected, got {1}", tname, t2);
            luaL_argerror(L, stackPos, msg);
            return 0;
        }

        // RVA: 0x228E120
        public static string luaL_checklstring(IntPtr L, int numArg, out int len)
        {
            IntPtr p = tolua_tolstring(L, numArg, out len);
            if (p == IntPtr.Zero)
            {
                luaL_typerror(L, numArg, "string");
            }
            return lua_ptrtostring(p, len);
        }

        // RVA: 0x228E22C
        public static string luaL_optlstring(IntPtr L, int narg, string def, out int len)
        {
            if (lua_isnoneornil(L, narg))
            {
                len = def == null ? 0 : def.Length;
                return def;
            }
            return luaL_checklstring(L, narg, out len);
        }

        // RVA: 0x2286304
        public static double luaL_checknumber(IntPtr L, int stackPos)
        {
            double d = lua_tonumber(L, stackPos);
            if (d == 0.0 && !lua_isnumber(L, stackPos))
            {
                luaL_typerror(L, stackPos, "number");
            }
            return d;
        }

        // RVA: 0x228E308
        public static double luaL_optnumber(IntPtr L, int idx, double def)
        {
            if (lua_isnoneornil(L, idx))
            {
                return def;
            }
            return luaL_checknumber(L, idx);
        }

        // RVA: 0x228E3C8
        public static int luaL_checkinteger(IntPtr L, int stackPos)
        {
            int d = tolua_tointeger(L, stackPos);
            if (d == 0 && !lua_isnumber(L, stackPos))
            {
                luaL_typerror(L, stackPos, "number");
            }
            return d;
        }

        // RVA: 0x228E4A8
        public static int luaL_optinteger(IntPtr L, int idx, int def)
        {
            if (lua_isnoneornil(L, idx))
            {
                return def;
            }
            return luaL_checkinteger(L, idx);
        }

        // RVA: 0x228E55C
        public static bool luaL_checkboolean(IntPtr luaState, int index)
        {
            if (!lua_isboolean(luaState, index))
            {
                luaL_typerror(luaState, index, "boolean");
            }
            return lua_toboolean(luaState, index);
        }

        // RVA: 0x228E640
        public static void luaL_checkstack(IntPtr L, int space, string mes)
        {
            if (!lua_checkstack(L, space))
            {
                throw new LuaException(string.Format("stack overflow {0}", space));
            }
        }

        // RVA: 0x228E718
        public static void luaL_checktype(IntPtr L, int narg, LuaTypes t)
        {
            if (lua_type(L, narg) != t)
            {
                luaL_typerror(L, narg, lua_typename(L, t));
            }
        }

        // RVA: 0x228E7DC
        public static void luaL_checkany(IntPtr L, int narg)
        {
            if (lua_type(L, narg) == LuaTypes.LUA_TNONE)
            {
                luaL_argerror(L, narg, "value expected");
            }
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaL_newmetatable(IntPtr luaState, string meta);

        // RVA: 0x228E944
        public static IntPtr luaL_checkudata(IntPtr L, int ud, string tname)
        {
            IntPtr p = lua_touserdata(L, ud);
            if (p != IntPtr.Zero)
            {
                if (lua_getmetatable(L, ud) != 0)
                {
                    lua_getfield(L, LuaIndexes.LUA_REGISTRYINDEX, tname);
                    if (lua_rawequal(L, -1, -2) != 0)
                    {
                        lua_pop(L, 2);
                        return p;
                    }
                }
            }

            luaL_typerror(L, ud, tname);
            return IntPtr.Zero;
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void luaL_where(IntPtr luaState, int level);

        // RVA: 0x228EB5C
        public static int luaL_throw(IntPtr L, string message)
        {
            tolua_pushtraceback(L);
            lua_pushstring(L, message);
            lua_pushnumber(L, 1);
            if (lua_pcall(L, 2, LuaDLL.LUA_MULTRET, 0) != 0)
            {
                lua_pop(L, 1);
            }
            else
            {
                message = lua_tostring(L, -1);
            }
            throw new LuaException(message, null, 2);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaL_ref(IntPtr luaState, int t);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void luaL_unref(IntPtr luaState, int registryIndex, int reference);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaL_loadfile(IntPtr luaState, string filename);

        // RVA: 0x228EECC
        public static int luaL_loadbuffer(IntPtr luaState, byte[] buff, int size, string name)
        {
            return tolua_loadbuffer(luaState, buff, size, name);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaL_loadstring(IntPtr luaState, string chunk);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr luaL_newstate();

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr luaL_gsub(IntPtr luaState, string str, string pattern, string replacement);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr luaL_findtable(IntPtr luaState, int idx, string fname, int szhint = 1);

        // RVA: 0x228E0A4
        public static string luaL_typename(IntPtr luaState, int stackPos)
        {
            return lua_typename(luaState, lua_type(luaState, stackPos));
        }

        // RVA: 0x228F284
        public static bool luaL_dofile(IntPtr luaState, string fileName)
        {
            bool ret = luaL_loadfile(luaState, fileName) == 0;
            if (ret)
            {
                ret = lua_pcall(luaState, 0, LuaDLL.LUA_MULTRET, 0) == 0;
            }
            return ret;
        }

        // RVA: 0x228F344
        public static bool luaL_dostring(IntPtr luaState, string chunk)
        {
            Debug.Log("load string !!" + chunk);
            bool ret = luaL_loadstring(luaState, chunk) == 0;
            if (ret)
            {
                ret = lua_pcall(luaState, 0, LuaDLL.LUA_MULTRET, 0) == 0;
            }
            return ret;
        }

        // RVA: 0x228F450
        public static void luaL_getmetatable(IntPtr luaState, string meta)
        {
            lua_getfield(luaState, LuaIndexes.LUA_REGISTRYINDEX, meta);
        }

        // RVA: 0x228F4F8
        public static int lua_ref(IntPtr luaState)
        {
            return luaL_ref(luaState, LuaIndexes.LUA_REGISTRYINDEX);
        }

        // RVA: 0x228F590
        public static void lua_getref(IntPtr luaState, int reference)
        {
            lua_rawgeti(luaState, LuaIndexes.LUA_REGISTRYINDEX, reference);
        }

        // RVA: 0x228F638
        public static void lua_unref(IntPtr luaState, int reference)
        {
            luaL_unref(luaState, LuaIndexes.LUA_REGISTRYINDEX, reference);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_openlibs(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_openint64(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_openlualibs(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr tolua_tag();

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_newudata(IntPtr luaState, int val);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_rawnetobj(IntPtr luaState, int obj);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_pushudata(IntPtr L, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_pushnewudata(IntPtr L, int metaRef, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_beginpcall(IntPtr L, int reference);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushtraceback(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_getvec2(IntPtr luaState, int stackPos, out float x, out float y);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_getvec3(IntPtr luaState, int stackPos, out float x, out float y, out float z);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_getvec4(IntPtr luaState, int stackPos, out float x, out float y, out float z, out float w);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_getclr(IntPtr luaState, int stackPos, out float r, out float g, out float b, out float a);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_getquat(IntPtr luaState, int stackPos, out float x, out float y, out float z, out float w);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_getlayermask(IntPtr luaState, int stackPos);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushvec2(IntPtr luaState, float x, float y);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushvec3(IntPtr luaState, float x, float y, float z);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushvec4(IntPtr luaState, float x, float y, float z, float w);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushquat(IntPtr luaState, float x, float y, float z, float w);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushclr(IntPtr luaState, float r, float g, float b, float a);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushlayermask(IntPtr luaState, int mask);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_isint64(IntPtr luaState, int stackPos);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern long tolua_toint64(IntPtr luaState, int stackPos);

        // RVA: 0x22904EC
        public static long tolua_checkint64(IntPtr L, int stackPos)
        {
            long l = tolua_toint64(L, stackPos);
            if (l == 0 && !tolua_isint64(L, stackPos))
            {
                luaL_typerror(L, stackPos, "long");
            }
            return l;
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushint64(IntPtr luaState, long n);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_isuint64(IntPtr luaState, int stackPos);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern ulong tolua_touint64(IntPtr luaState, int stackPos);

        // RVA: 0x2290784
        public static ulong tolua_checkuint64(IntPtr L, int stackPos)
        {
            ulong l = tolua_touint64(L, stackPos);
            if (l == 0 && !tolua_isuint64(L, stackPos))
            {
                luaL_typerror(L, stackPos, "ulong");
            }
            return l;
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushuint64(IntPtr luaState, ulong n);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_setindex(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_setnewindex(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int toluaL_ref(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void toluaL_unref(IntPtr L, int reference);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr tolua_getmainstate(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_getvaluetype(IntPtr L, int stackPos);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_createtable(IntPtr L, string fullPath, int szhint = 0);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_pushluatable(IntPtr L, string fullPath);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_beginmodule(IntPtr L, string name);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_endmodule(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_beginpremodule(IntPtr L, string fullPath, int szhint = 0);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_endpremodule(IntPtr L, int reference);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_addpreload(IntPtr L, string path);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_beginclass(IntPtr L, string name, int baseMetaRef, int reference = -1);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_endclass(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_function(IntPtr L, string name, IntPtr fn);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr tolua_tocbuffer(string name, int sz);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_freebuffer(IntPtr buffer);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_variable(IntPtr L, string name, IntPtr get, IntPtr set);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_constant(IntPtr L, string name, double val);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_beginenum(IntPtr L, string name);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_endenum(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_beginstaticclass(IntPtr L, string name);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_endstaticclass(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_require(IntPtr L, string fileName);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_getmetatableref(IntPtr L, int pos);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_setflag(int bit, bool flag);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_isvptrtable(IntPtr L, int index);

        // RVA: 0x2286474
        public static int toluaL_exception(IntPtr L, Exception e)
        {
            LuaException luaEx = new LuaException(e.Message, e, 2);
            LuaException.luaStack = luaEx;
            return tolua_error(L, e.Message);
        }

        // RVA: 0x2291A7C
        public static int toluaL_exception(IntPtr L, Exception e, object o, string msg)
        {
            if (o != null && !o.Equals(null))
            {
                msg = e.Message;
            }

            LuaException luaEx = new LuaException(msg, e, 2);
            LuaException.luaStack = luaEx;
            return tolua_error(L, msg);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_loadbuffer(IntPtr luaState, byte[] buff, int size, string name);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool tolua_toboolean(IntPtr luaState, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_tointeger(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr tolua_tolstring(IntPtr luaState, int index, out int strLen);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushlstring(IntPtr luaState, byte[] str, int size);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_objlen(IntPtr luaState, int stackPos);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr tolua_newuserdata(IntPtr luaState, int size);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_argerror(IntPtr luaState, int narg, string extramsg);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_error(IntPtr L, string msg);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_getfield(IntPtr L, int idx, string key);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_setfield(IntPtr L, int idx, string key);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_gettable(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_settable(IntPtr luaState, int idx);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_getn(IntPtr luaState, int stackPos);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_strlen(IntPtr str);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushcfunction(IntPtr L, IntPtr fn);

        // RVA: 0x2291C90
        public static void tolua_pushcfunction(IntPtr luaState, LuaCSFunction func)
        {
            IntPtr fn = Marshal.GetFunctionPointerForDelegate(func);
            lua_pushcclosure(luaState, fn, 0);
        }

        // RVA: 0x2291D40
        public static string tolua_findtable(IntPtr L, int idx, string name, int size = 1)
        {
            int top = lua_gettop(L);
            IntPtr p = luaL_findtable(L, idx, name, size);
            if (p != IntPtr.Zero)
            {
                lua_settop(L, top);
                return lua_ptrtostring(p, tolua_strlen(p));
            }
            return null;
        }

        // RVA: 0x2291E3C
        public static IntPtr tolua_atpanic(IntPtr L, LuaCSFunction func)
        {
            IntPtr fn = Marshal.GetFunctionPointerForDelegate(func);
            return lua_atpanic(L, fn);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr tolua_buffinit(IntPtr luaState);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_addlstring(IntPtr b, string str, int l);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_addstring(IntPtr b, string s);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_addchar(IntPtr b, byte s);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_pushresult(IntPtr b);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_update(IntPtr L, float deltaTime, float unscaledDelta);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_lateupdate(IntPtr L);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_fixedupdate(IntPtr L, float fixedTime);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void tolua_regthis(IntPtr L, IntPtr get, IntPtr set);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_where(IntPtr L, int level);

        // RVA: 0x229249C
        public static void tolua_bindthis(IntPtr L, LuaCSFunction get, LuaCSFunction set)
        {
            IntPtr getp = Marshal.GetFunctionPointerForDelegate(get);
            IntPtr setp = Marshal.GetFunctionPointerForDelegate(set);
            tolua_regthis(L, getp, setp);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int tolua_getclassref(IntPtr L, int pos);

        // RVA: 0x2292620
        public void .ctor()
        {

        }

        // RVA: 0x2292628
        static LuaDLL()
        {
            version = "1.0.7.386";
            LUA_MULTRET = -1;
            LuaTypeName = new string[]
            {
                "none",
                "nil",
                "boolean",
                "lightuserdata",
                "number",
                "string",
                "table",
                "function",
                "userdata",
                "thread",
            };
        }
    }
}
