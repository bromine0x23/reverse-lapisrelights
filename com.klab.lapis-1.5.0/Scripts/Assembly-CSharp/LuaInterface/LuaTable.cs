// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaTable
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

namespace LuaInterface
{
    public class LuaTable : LuaBaseRef
    {
        public object Item { get; set; }
        public object Item { get; set; }
        public int Length { get; }

        // RVA: 0x19036C0
        public void .ctor(int reference, LuaState state)
        {
            this.reference = reference;
            this.luaState = state;
        }

        // RVA: 0x190CC5C
        public object get_Item(string key)
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                luaState.Push(key);
                luaState.LuaGetTable(top + 1);
                return luaState.ToVariant(top + 1);
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        // RVA: 0x190CDD8
        public void set_Item(string key, object value)
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                luaState.Push(key);
                luaState.PushVariant(value);
                luaState.LuaSetTable(top + 1);
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        // RVA: 0x190CF4C
        public object get_Item(int key)
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                luaState.LuaRawGetI(top + 1, key);
                return luaState.ToVariant(top + 1);
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        // RVA: 0x190D0B4
        public void set_Item(int key, object value)
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                luaState.PushVariant(value);
                luaState.LuaRawSetI(top + 1, key);
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        // RVA: 0x190D214
        public int get_Length()
        {
            luaState.Push(this);
            int n = luaState.LuaObjLen(-1);
            luaState.LuaPop(1);
            return n;
        }

        public T RawGetIndex<T>(int index)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            luaState.Push(this);                
                            luaState.LuaRawGetI(top + 1, index);
                            T ret = luaState.CheckValue<T>(top + 2);
                            luaState.LuaSetTop(top);
                            return ret;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public void RawSetIndex<T>(int index, T value)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            luaState.Push(this);
                            luaState.PushGeneric(value);
                            luaState.LuaRawSetI(top + 1, index);                
                            luaState.LuaSetTop(top);                
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public V RawGet<K, V>(K key)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            luaState.Push(this);
                            luaState.PushGeneric(key);
                            luaState.LuaRawGet(top + 1);
                            V ret = luaState.CheckValue<V>(top + 2);
                            luaState.LuaSetTop(top);
                            return ret;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public void RawSet<K, V>(K key, V arg)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            luaState.Push(this);
                            luaState.PushGeneric(key);
                            luaState.PushGeneric(arg);
                            luaState.LuaRawSet(top + 1);
                            luaState.LuaSetTop(top);
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public T GetTable<T>(string key)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            luaState.Push(this);
                            luaState.Push(key);
                            luaState.LuaGetTable(top + 1);
                            T ret = luaState.CheckValue<T>(top + 2);
                            luaState.LuaSetTop(top);
                            return ret;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public void SetTable<T>(string key, T arg)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            luaState.Push(this);
                            luaState.Push(key);
                            luaState.PushGeneric(arg);
                            luaState.LuaSetTable(top + 1);
                            luaState.LuaSetTop(top);
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        // RVA: 0x190D270
        public LuaFunction RawGetLuaFunction(string key)
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                luaState.Push(key);
                luaState.LuaRawGet(top + 1);
                return luaState.CheckLuaFunction(top + 1);
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        // RVA: 0x190D3EC
        public LuaFunction GetLuaFunction(string key)
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                luaState.Push(key);
                luaState.LuaGetTable(top + 1);
                return luaState.CheckLuaFunction(top + 1);
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        // RVA: 0x190D568
        private bool BeginCall(string name, int top)
        {
            luaState.Push(this);
            luaState.ToLuaPushTraceback();
            luaState.Push(name);
            luaState.LuaGetTable(top + 1);
            return luaState.LuaType(top + 3) == LuaTypes.LUA_TFUNCTION;
        }

        // RVA: 0x190D5EC
        public void Call(string name)
        {
            int top = luaState.LuaGetTop();
            try
            {
                if (BeginCall(name, top))
                {
                    luaState.Call(0, LuaDLL.LUA_MULTRET, top + 2);
                }
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        public void Call<T1>(string name, T1 arg1)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.Call(1, top + 2, top);
                            }

                            luaState.LuaSetTop(top);
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public void Call<T1, T2>(string name, T1 arg1, T2 arg2)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.Call(2, top + 2, top);
                            }

                            luaState.LuaSetTop(top);
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public void Call<T1, T2, T3>(string name, T1 arg1, T2 arg2, T3 arg3)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.PushGeneric(arg3);
                                luaState.Call(3, top + 2, top);
                            }

                            luaState.LuaSetTop(top);
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public void Call<T1, T2, T3, T4>(string name, T1 arg1, T2 arg2, T3 arg3, T4 arg4)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.PushGeneric(arg3);
                                luaState.PushGeneric(arg4);
                                luaState.Call(4, top + 2, top);
                            }

                            luaState.LuaSetTop(top);
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public void Call<T1, T2, T3, T4, T5>(string name, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.PushGeneric(arg3);
                                luaState.PushGeneric(arg4);
                                luaState.PushGeneric(arg5);
                                luaState.Call(5, top + 2, top);
                            }

                            luaState.LuaSetTop(top);
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public void Call<T1, T2, T3, T4, T5, T6>(string name, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.PushGeneric(arg3);
                                luaState.PushGeneric(arg4);
                                luaState.PushGeneric(arg5);
                                luaState.PushGeneric(arg6);
                                luaState.Call(6, top + 2, top);
                            }

                            luaState.LuaSetTop(top);
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public R1 Invoke<R1>(string name)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            R1 ret1 = default(R1);

                            if (BeginCall(name, top))
                            {
                                luaState.Call(0, top + 2, top);
                                ret1 = luaState.CheckValue<R1>(top + 3);
                            }

                            luaState.LuaSetTop(top);
                            return ret1;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public R1 Invoke<T1, R1>(string name, T1 arg1)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            R1 ret1 = default(R1);

                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.Call(1, top + 2, top);
                                ret1 = luaState.CheckValue<R1>(top + 3);
                            }

                            luaState.LuaSetTop(top);
                            return ret1;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public R1 Invoke<T1, T2, R1>(string name, T1 arg1, T2 arg2)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            R1 ret1 = default(R1);

                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.Call(2, top + 2, top);
                                ret1 = luaState.CheckValue<R1>(top + 3);
                            }

                            luaState.LuaSetTop(top);
                            return ret1;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public R1 Invoke<T1, T2, T3, R1>(string name, T1 arg1, T2 arg2, T3 arg3)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            R1 ret1 = default(R1);

                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.PushGeneric(arg3);
                                luaState.Call(3, top + 2, top);
                                ret1 = luaState.CheckValue<R1>(top + 3);
                            }

                            luaState.LuaSetTop(top);
                            return ret1;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public R1 Invoke<T1, T2, T3, T4, R1>(string name, T1 arg1, T2 arg2, T3 arg3, T4 arg4)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            R1 ret1 = default(R1);

                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.PushGeneric(arg3);
                                luaState.PushGeneric(arg4);                    
                                luaState.Call(4, top + 2, top);
                                ret1 = luaState.CheckValue<R1>(top + 3);
                            }

                            luaState.LuaSetTop(top);
                            return ret1;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public R1 Invoke<T1, T2, T3, T4, T5, R1>(string name, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            R1 ret1 = default(R1);

                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.PushGeneric(arg3);
                                luaState.PushGeneric(arg4);
                                luaState.PushGeneric(arg5);
                                luaState.Call(5, top + 2, top);
                                ret1 = luaState.CheckValue<R1>(top + 3);
                            }

                            luaState.LuaSetTop(top);
                            return ret1;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        public R1 Invoke<T1, T2, T3, T4, T5, T6, R1>(string name, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6)
        {
                        int top = luaState.LuaGetTop();

                        try
                        {
                            R1 ret1 = default(R1);

                            if (BeginCall(name, top))
                            {
                                luaState.PushGeneric(arg1);
                                luaState.PushGeneric(arg2);
                                luaState.PushGeneric(arg3);
                                luaState.PushGeneric(arg4);
                                luaState.PushGeneric(arg5);
                                luaState.PushGeneric(arg6);
                                luaState.Call(6, top + 2, top);
                                ret1 = luaState.CheckValue<R1>(top + 3);
                            }

                            luaState.LuaSetTop(top);
                            return ret1;
                        }
                        catch (Exception e)
                        {
                            luaState.LuaSetTop(top);
                            throw e;
                        }
        }

        // RVA: 0x190D72C
        public string GetStringField(string name)
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                luaState.LuaGetField(top + 1, name);
                return luaState.CheckString(top + 1);
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        // RVA: 0x190D894
        public void AddTable(string name)
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                luaState.Push(name);
                luaState.LuaCreateTable();
                luaState.LuaRawSet(top + 1);
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        // RVA: 0x190DA08
        public object[] ToArray()
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                int len = luaState.LuaObjLen(-1);
                List<object> list = new List<object>(len);
                for (int i = 1; i <= len; i++)
                {
                    luaState.LuaRawGetI(-1, i);
                    list.Add(luaState.ToVariant(-1));
                    luaState.LuaPop(1);
                }
                return list.ToArray();
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }

        // RVA: 0x190DC38
        public override string ToString()
        {
            luaState.Push(this);
            IntPtr p = luaState.LuaToPointer(-1);
            luaState.LuaPop(1);
            return string.Format("table:0x{0}", p.ToString("X"));
        }

        // RVA: 0x190DCF0
        public LuaArrayTable ToArrayTable()
        {
            return new LuaArrayTable(this);
        }

        // RVA: 0x190891C
        public LuaDictTable ToDictTable()
        {
            return new LuaDictTable(this);
        }

        public LuaDictTable<K, V> ToDictTable<K, V>()
        {
                        return new LuaDictTable<K, V>(this);
        }

        // RVA: 0x190DD54
        public LuaTable GetMetaTable()
        {
            int top = luaState.LuaGetTop();
            try
            {
                luaState.Push(this);
                luaState.LuaGetMetaTable(-1);
                return luaState.CheckLuaTable(-1);
            }
            finally
            {
                luaState.LuaSetTop(top);
            }
        }
    }
}
