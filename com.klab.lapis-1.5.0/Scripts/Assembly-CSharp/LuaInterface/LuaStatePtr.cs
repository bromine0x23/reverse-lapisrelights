// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaStatePtr
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
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
using System.Runtime.InteropServices;
using System.Text;

namespace LuaInterface
{
    public class LuaStatePtr
    {
        protected IntPtr L;
        private string jit;

        // RVA: 0x1909000
        public int LuaUpValueIndex(int i)
        {
            return LuaIndexes.LUA_GLOBALSINDEX - i;
        }

        // RVA: 0x18FEE94
        public IntPtr LuaNewState()
        {
            return LuaDLL.luaL_newstate();
        }

        // RVA: 0x1909070
        public void LuaOpenJit()
        {
            if (IntPtr.Size == 8)
            {
                LuaDLL.luaL_dostring(L, "jit.off()");
            }
            else
            {
                LuaDLL.luaL_dostring(L, jit);
            }
        }

        // RVA: 0x19091C0
        public void LuaClose()
        {
            LuaDLL.lua_close(L);
        }

        // RVA: 0x1909234
        public IntPtr LuaNewThread()
        {
            return LuaDLL.lua_newthread(L);
        }

        // RVA: 0x19092A0
        public IntPtr LuaAtPanic(IntPtr panic)
        {
            return LuaDLL.lua_atpanic(L, panic);
        }

        // RVA: 0x1900684
        public int LuaGetTop()
        {
            return LuaDLL.lua_gettop(L);
        }

        // RVA: 0x18FF2F4
        public void LuaSetTop(int newTop)
        {
            LuaDLL.lua_settop(L, newTop);
        }

        // RVA: 0x1905C38
        public void LuaPushValue(int idx)
        {
            LuaDLL.lua_pushvalue(L, idx);
        }

        // RVA: 0x190931C
        public void LuaRemove(int index)
        {
            LuaDLL.lua_remove(L, index);
        }

        // RVA: 0x1909398
        public void LuaInsert(int idx)
        {
            LuaDLL.lua_insert(L, idx);
        }

        // RVA: 0x1909414
        public void LuaReplace(int idx)
        {
            LuaDLL.lua_replace(L, idx);
        }

        // RVA: 0x1909490
        public bool LuaCheckStack(int args)
        {
            return LuaDLL.lua_checkstack(L, args);
        }

        // RVA: 0x1909518
        public void LuaXMove(IntPtr to, int n)
        {
            LuaDLL.lua_xmove(L, to, n);
        }

        // RVA: 0x190959C
        public bool LuaIsNumber(int idx)
        {
            return LuaDLL.lua_isnumber(L, idx);
        }

        // RVA: 0x1909624
        public bool LuaIsString(int index)
        {
            return LuaDLL.lua_isstring(L, index);
        }

        // RVA: 0x19096AC
        public bool LuaIsCFunction(int index)
        {
            return LuaDLL.lua_iscfunction(L, index);
        }

        // RVA: 0x1909734
        public bool LuaIsUserData(int index)
        {
            return LuaDLL.lua_isuserdata(L, index);
        }

        // RVA: 0x1907A84
        public bool LuaIsNil(int n)
        {
            return LuaDLL.lua_isnil(L, n);
        }

        // RVA: 0x19097BC
        public LuaTypes LuaType(int index)
        {
            return LuaDLL.lua_type(L, index);
        }

        // RVA: 0x1909838
        public string LuaTypeName(LuaTypes type)
        {
            return LuaDLL.lua_typename(L, type);
        }

        // RVA: 0x19098B4
        public string LuaTypeName(int idx)
        {
            return LuaDLL.luaL_typename(L, idx);
        }

        // RVA: 0x1909930
        public bool LuaEqual(int idx1, int idx2)
        {
            return LuaDLL.lua_equal(L, idx1, idx2);
        }

        // RVA: 0x19099C0
        public bool LuaRawEqual(int idx1, int idx2)
        {
            return LuaDLL.lua_rawequal(L, idx1, idx2);
        }

        // RVA: 0x1909A50
        public bool LuaLessThan(int idx1, int idx2)
        {
            return LuaDLL.lua_lessthan(L, idx1, idx2);
        }

        // RVA: 0x1909AE0
        public double LuaToNumber(int idx)
        {
            return LuaDLL.lua_tonumber(L, idx);
        }

        // RVA: 0x1909B5C
        public int LuaToInteger(int idx)
        {
            return LuaDLL.lua_tointeger(L, idx);
        }

        // RVA: 0x1909BD8
        public bool LuaToBoolean(int idx)
        {
            return LuaDLL.lua_toboolean(L, idx);
        }

        // RVA: 0x1902058
        public string LuaToString(int index)
        {
            return LuaDLL.lua_tostring(L, index);
        }

        // RVA: 0x1909C54
        public IntPtr LuaToLString(int index, out int len)
        {
            return LuaDLL.tolua_tolstring(L, index, out len);
        }

        // RVA: 0x1909CD8
        public IntPtr LuaToCFunction(int idx)
        {
            return LuaDLL.lua_tocfunction(L, idx);
        }

        // RVA: 0x1909D54
        public IntPtr LuaToUserData(int idx)
        {
            return LuaDLL.lua_touserdata(L, idx);
        }

        // RVA: 0x1909DD0
        public IntPtr LuaToThread(int idx)
        {
            return LuaDLL.lua_tothread(L, idx);
        }

        // RVA: 0x1909E4C
        public IntPtr LuaToPointer(int idx)
        {
            return LuaDLL.lua_topointer(L, idx);
        }

        // RVA: 0x1909EC8
        public int LuaObjLen(int index)
        {
            return LuaDLL.tolua_objlen(L, index);
        }

        // RVA: 0x1904B1C
        public void LuaPushNil()
        {
            LuaDLL.lua_pushnil(L);
        }

        // RVA: 0x1909F44
        public void LuaPushNumber(double number)
        {
            LuaDLL.lua_pushnumber(L, number);
        }

        // RVA: 0x1909FC0
        public void LuaPushInteger(int n)
        {
            LuaDLL.lua_pushnumber(L, n);
        }

        // RVA: 0x190A03C
        public void LuaPushLString(byte[] str, int size)
        {
            LuaDLL.lua_pushlstring(L, str, size);
        }

        // RVA: 0x19020D4
        public void LuaPushString(string str)
        {
            LuaDLL.lua_pushstring(L, str);
        }

        // RVA: 0x190A0C0
        public void LuaPushCClosure(IntPtr fn, int n)
        {
            LuaDLL.lua_pushcclosure(L, fn, n);
        }

        // RVA: 0x190A144
        public void LuaPushBoolean(bool value)
        {
            LuaDLL.lua_pushboolean(L, value);
        }

        // RVA: 0x190A1C4
        public void LuaPushLightUserData(IntPtr udata)
        {
            LuaDLL.lua_pushlightuserdata(L, udata);
        }

        // RVA: 0x190A240
        public int LuaPushThread()
        {
            return LuaDLL.lua_pushthread(L);
        }

        // RVA: 0x1907A08
        public void LuaGetTable(int idx)
        {
            LuaDLL.lua_gettable(L, idx);
        }

        // RVA: 0x1900150
        public void LuaGetField(int index, string key)
        {
            LuaDLL.lua_getfield(L, index, key);
        }

        // RVA: 0x19071CC
        public void LuaRawGet(int idx)
        {
            LuaDLL.lua_rawget(L, idx);
        }

        // RVA: 0x190A2AC
        public void LuaRawGetI(int tableIndex, int index)
        {
            LuaDLL.lua_rawgeti(L, tableIndex, index);
        }

        // RVA: 0x1900F24
        public void LuaCreateTable(int narr = 0, int nec = 0)
        {
            LuaDLL.lua_createtable(L, narr, nec);
        }

        // RVA: 0x190A330
        public IntPtr LuaNewUserData(int size)
        {
            return LuaDLL.tolua_newuserdata(L, size);
        }

        // RVA: 0x190A3AC
        public int LuaGetMetaTable(int idx)
        {
            return LuaDLL.lua_getmetatable(L, idx);
        }

        // RVA: 0x190A428
        public void LuaGetEnv(int idx)
        {
            LuaDLL.lua_getfenv(L, idx);
        }

        // RVA: 0x19074D8
        public void LuaSetTable(int idx)
        {
            LuaDLL.lua_settable(L, idx);
        }

        // RVA: 0x19003FC
        public void LuaSetField(int idx, string key)
        {
            LuaDLL.lua_setfield(L, idx, key);
        }

        // RVA: 0x190A4A4
        public void LuaRawSet(int idx)
        {
            LuaDLL.lua_rawset(L, idx);
        }

        // RVA: 0x190A520
        public void LuaRawSetI(int tableIndex, int index)
        {
            LuaDLL.lua_rawseti(L, tableIndex, index);
        }

        // RVA: 0x190A5A4
        public void LuaSetMetaTable(int objIndex)
        {
            LuaDLL.lua_setmetatable(L, objIndex);
        }

        // RVA: 0x190A620
        public void LuaSetEnv(int idx)
        {
            LuaDLL.lua_setfenv(L, idx);
        }

        // RVA: 0x190A69C
        public void LuaCall(int nArgs, int nResults)
        {
            LuaDLL.lua_call(L, nArgs, nResults);
        }

        // RVA: 0x1908A90
        public int LuaPCall(int nArgs, int nResults, int errfunc)
        {
            return LuaDLL.lua_pcall(L, nArgs, nResults, errfunc);
        }

        // RVA: 0x190A720
        public int LuaYield(int nresults)
        {
            return LuaDLL.lua_yield(L, nresults);
        }

        // RVA: 0x190A79C
        public int LuaResume(int narg)
        {
            return LuaDLL.lua_resume(L, narg);
        }

        // RVA: 0x190A818
        public int LuaStatus()
        {
            return LuaDLL.lua_status(L);
        }

        // RVA: 0x190A884
        public int LuaGC(LuaGCOptions what, int data = 0)
        {
            return LuaDLL.lua_gc(L, what, data);
        }

        // RVA: 0x190A908
        public bool LuaNext(int index)
        {
            return LuaDLL.lua_next(L, index);
        }

        // RVA: 0x190A990
        public void LuaConcat(int n)
        {
            LuaDLL.lua_concat(L, n);
        }

        // RVA: 0x19001FC
        public void LuaPop(int amount)
        {
            LuaDLL.lua_pop(L, amount);
        }

        // RVA: 0x190AA0C
        public void LuaNewTable()
        {
            LuaDLL.lua_createtable(L, 0, 0);
        }

        // RVA: 0x190AA80
        public void LuaPushFunction(LuaCSFunction func)
        {
            LuaDLL.lua_pushcclosure(L, Marshal.GetFunctionPointerForDelegate(func), 0);
        }

        // RVA: 0x190AB3C
        public bool lua_isfunction(int n)
        {
            return LuaDLL.lua_type(L, n);
        }

        // RVA: 0x190ABC4
        public bool lua_istable(int n)
        {
            return LuaDLL.lua_type(L, n);
        }

        // RVA: 0x190AC4C
        public bool lua_islightuserdata(int n)
        {
            return LuaDLL.lua_type(L, n);
        }

        // RVA: 0x190ACD4
        public bool lua_isnil(int n)
        {
            return LuaDLL.lua_type(L, n);
        }

        // RVA: 0x190AD5C
        public bool lua_isboolean(int n)
        {
            return LuaDLL.lua_type(L, n);
        }

        // RVA: 0x190ADE4
        public bool lua_isthread(int n)
        {
            return LuaDLL.lua_type(L, n);
        }

        // RVA: 0x190AE6C
        public bool lua_isnone(int n)
        {
            return LuaDLL.lua_type(L, n);
        }

        // RVA: 0x190AEF4
        public bool lua_isnoneornil(int n)
        {
            return LuaDLL.lua_type(L, n);
        }

        // RVA: 0x190AF7C
        public void LuaRawGlobal(string name)
        {
            LuaDLL.lua_pushstring(L, name);
            LuaDLL.lua_rawget(L, LuaIndexes.LUA_GLOBALSINDEX);
        }

        // RVA: 0x1907554
        public void LuaSetGlobal(string name)
        {
            LuaDLL.lua_setglobal(L, name);
        }

        // RVA: 0x19000D4
        public void LuaGetGlobal(string name)
        {
            LuaDLL.lua_getglobal(L, name);
        }

        // RVA: 0x190B034
        public void LuaOpenLibs()
        {
            LuaDLL.luaL_openlibs(L);
        }

        // RVA: 0x190B0A0
        public int AbsIndex(int i)
        {
            if (i > 0 || i <= LuaIndexes.LUA_REGISTRYINDEX)
            {
                return i;
            }

            return LuaDLL.lua_gettop(L) + i + 1;
        }

        // RVA: 0x190B164
        public int LuaGetN(int i)
        {
            return LuaDLL.luaL_getn(L, i);
        }

        // RVA: 0x190B1E0
        public double LuaCheckNumber(int stackPos)
        {
            return LuaDLL.luaL_checknumber(L, stackPos);
        }

        // RVA: 0x190B25C
        public int LuaCheckInteger(int idx)
        {
            return LuaDLL.luaL_checkinteger(L, idx);
        }

        // RVA: 0x190B2D8
        public bool LuaCheckBoolean(int stackPos)
        {
            return LuaDLL.luaL_checkboolean(L, stackPos);
        }

        // RVA: 0x190B354
        public string LuaCheckLString(int numArg, out int len)
        {
            return LuaDLL.luaL_checklstring(L, numArg, out len);
        }

        // RVA: 0x19089FC
        public int LuaLoadBuffer(byte[] buff, int size, string name)
        {
            return LuaDLL.luaL_loadbuffer(L, buff, size, name);
        }

        // RVA: 0x1907444
        public IntPtr LuaFindTable(int idx, string fname, int szhint = 1)
        {
            return LuaDLL.luaL_findtable(L, idx, fname, szhint);
        }

        // RVA: 0x1905318
        public int LuaTypeError(int stackPos, string tname, string t2)
        {
            return LuaDLL.luaL_typerror(L, stackPos, tname, t2);
        }

        // RVA: 0x190B3D8
        public bool LuaDoString(string chunk, string chunkName = "@LuaStatePtr.cs")
        {
            byte[] buff = Encoding.UTF8.GetBytes(chunk);

            if (LuaDLL.luaL_loadbuffer(L, buff, buff.Length, chunkName) != 0)
            {
                return false;
            }

            return LuaDLL.lua_pcall(L, 0, LuaDLL.LUA_MULTRET, 0) == 0;
        }

        // RVA: 0x190B4E8
        public bool LuaDoFile(string fileName)
        {
            return LuaDLL.luaL_dofile(L, fileName);
        }

        // RVA: 0x190B600
        public void LuaGetMetaTable(string meta)
        {
            LuaDLL.luaL_getmetatable(L, meta);
        }

        // RVA: 0x1900FA8
        public int LuaRef(int t)
        {
            return LuaDLL.luaL_ref(L, t);
        }

        // RVA: 0x1904B88
        public void LuaGetRef(int reference)
        {
            LuaDLL.lua_getref(L, reference);
        }

        // RVA: 0x1907EEC
        public void LuaUnRef(int reference)
        {
            LuaDLL.lua_unref(L, reference);
        }

        // RVA: 0x1901FDC
        public int LuaRequire(string fileName)
        {
            return LuaDLL.tolua_require(L, fileName);
        }

        // RVA: 0x190B67C
        public void ThrowLuaException(Exception e)
        {
            if (LuaException.InstantiateCount > 0 || LuaException.SendMsgCount > 0)
            {
                LuaDLL.toluaL_exception(LuaException.L, e);
                return;
            }

            throw e;
        }

        // RVA: 0x1902F98
        public int ToLuaRef()
        {
            return LuaDLL.toluaL_ref(L);
        }

        // RVA: 0x190B77C
        public int LuaUpdate(float delta, float unscaled)
        {
            return LuaDLL.tolua_update(L, delta, unscaled);
        }

        // RVA: 0x190B800
        public int LuaLateUpdate()
        {
            return LuaDLL.tolua_lateupdate(L);
        }

        // RVA: 0x190B86C
        public int LuaFixedUpdate(float fixedTime)
        {
            return LuaDLL.tolua_fixedupdate(L, fixedTime);
        }

        // RVA: 0x18FEEF4
        public void OpenToLuaLibs()
        {
            LuaDLL.tolua_openlibs(L);
        }

        // RVA: 0x190B8E8
        public void ToLuaPushTraceback()
        {
            LuaDLL.tolua_pushtraceback(L);
        }

        // RVA: 0x1908980
        public void ToLuaUnRef(int reference)
        {
            LuaDLL.toluaL_unref(L, reference);
        }

        // RVA: 0x190B954
        public int LuaGetStack(int level, ref Lua_Debug ar)
        {
            return LuaDLL.lua_getstack(L, level, ar);
        }

        // RVA: 0x190B9D8
        public int LuaGetInfo(string what, ref Lua_Debug ar)
        {
            return LuaDLL.lua_getinfo(L, what, ar);
        }

        // RVA: 0x190BA5C
        public string LuaGetLocal(ref Lua_Debug ar, int n)
        {
            return LuaDLL.lua_getlocal(L, ar, n);
        }

        // RVA: 0x190BAE0
        public string LuaSetLocal(ref Lua_Debug ar, int n)
        {
            return LuaDLL.lua_setlocal(L, ar, n);
        }

        // RVA: 0x190BB64
        public string LuaGetUpvalue(int funcindex, int n)
        {
            return LuaDLL.lua_getupvalue(L, funcindex, n);
        }

        // RVA: 0x190BBE8
        public string LuaSetUpvalue(int funcindex, int n)
        {
            return LuaDLL.lua_setupvalue(L, funcindex, n);
        }

        // RVA: 0x190BC6C
        public int LuaSetHook(LuaHookFunc func, int mask, int count)
        {
            return LuaDLL.lua_sethook(L, func, mask, count);
        }

        // RVA: 0x190BD00
        public LuaHookFunc LuaGetHook()
        {
            return LuaDLL.lua_gethook(L);
        }

        // RVA: 0x190BD6C
        public int LuaGetHookMask()
        {
            return LuaDLL.lua_gethookmask(L);
        }

        // RVA: 0x190BDD8
        public int LuaGetHookCount()
        {
            return LuaDLL.lua_gethookcount(L);
        }

        // RVA: 0x18F93D8
        public void .ctor()
        {
            jit = @"            

        function Euler(x, y, z)

            x = x * 0.0087266462599716

            y = y * 0.0087266462599716

            z = z * 0.0087266462599716



            local sinX = math.sin(x)

            local cosX = math.cos(x)

            local sinY = math.sin(y)

            local cosY = math.cos(y)

            local sinZ = math.sin(z)

            local cosZ = math.cos(z)



            local w = cosY * cosX * cosZ + sinY * sinX * sinZ

            x = cosY* sinX * cosZ + sinY* cosX * sinZ

            y = sinY * cosX * cosZ - cosY * sinX * sinZ

            z = cosY* cosX * sinZ - sinY* sinX * cosZ



            return {x = x, y = y, z= z, w = w}

        end



        function Slerp(q1, q2, t)

            local x1, y1, z1, w1 = q1.x, q1.y, q1.z, q1.w

            local x2,y2,z2,w2 = q2.x, q2.y, q2.z, q2.w

            local dot = x1* x2 + y1* y2 + z1* z2 + w1* w2



            if dot< 0 then

                dot = -dot

                x2, y2, z2, w2 = -x2, -y2, -z2, -w2

            end



            if dot< 0.95 then

                local sin = math.sin

                local angle = math.acos(dot)

                local invSinAngle = 1 / sin(angle)

                local t1 = sin((1 - t) * angle) * invSinAngle

                local t2 = sin(t * angle) * invSinAngle

                return {x = x1* t1 + x2* t2, y = y1 * t1 + y2 * t2, z = z1 * t1 + z2 * t2, w = w1 * t1 + w2 * t2}

            else

                x1 = x1 + t* (x2 - x1)

                y1 = y1 + t* (y2 - y1)                

                z1 = z1 + t* (z2 - z1)                

                w1 = w1 + t* (w2 - w1)

                dot = x1* x1 + y1* y1 + z1* z1 + w1* w1



                return {x = x1 / dot, y = y1 / dot, z = z1 / dot, w = w1 / dot}

            end

        end



        if jit then

    	    if jit.status() then                

                for i=1,10000 do

                    local q1 = Euler(i, i, i)

                    Slerp({ x = 0, y = 0, z = 0, w = 1}, q1, 0.5)

                end                

            end	                   

        end";
        }
    }
}
