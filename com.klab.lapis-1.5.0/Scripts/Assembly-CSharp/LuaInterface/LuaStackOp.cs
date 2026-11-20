// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaStackOp
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
    public class LuaStackOp
    {

        // RVA: 0x18F1E90
        public sbyte ToSByte(IntPtr L, int stackPos)
        {
            return (sbyte)Convert.ToSByte(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F1F40
        public byte ToByte(IntPtr L, int stackPos)
        {
            return (byte)Convert.ToByte(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F1FF0
        public short ToInt16(IntPtr L, int stackPos)
        {
            return (short)Convert.ToInt16(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F20A0
        public ushort ToUInt16(IntPtr L, int stackPos)
        {
            return (ushort)Convert.ToUInt16(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F2150
        public char ToChar(IntPtr L, int stackPos)
        {
            return (char)Convert.ToChar(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F2200
        public int ToInt32(IntPtr L, int stackPos)
        {
            return (int)Convert.ToInt32(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F22B0
        public uint ToUInt32(IntPtr L, int stackPos)
        {
            return (uint)Convert.ToUInt32(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F2360
        public Decimal ToDecimal(IntPtr L, int stackPos)
        {
            return (Decimal)Convert.ToDecimal(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F2410
        public float ToFloat(IntPtr L, int stackPos)
        {
            return (float)Convert.ToSingle(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F24C0
        public LuaByteBuffer ToLuaByteBuffer(IntPtr L, int stackPos)
        {
            return new LuaByteBuffer(ToLua.ToByteBuffer(L, stackPos));
        }

        // RVA: 0x18F255C
        public IEnumerator ToIter(IntPtr L, int stackPos)
        {
            return ToLua.ToObject(L, stackPos) as IEnumerator;
        }

        // RVA: 0x18F2604
        public Type ToType(IntPtr L, int stackPos)
        {
            return ToLua.ToObject(L, stackPos) as Type;
        }

        // RVA: 0x18F26BC
        public EventObject ToEventObject(IntPtr L, int stackPos)
        {
            return ToLua.ToObject(L, stackPos) as EventObject;
        }

        // RVA: 0x18F2774
        public Transform ToTransform(IntPtr L, int stackPos)
        {
            return ToLua.ToObject(L, stackPos) as Transform;
        }

        // RVA: 0x18F282C
        public GameObject ToGameObject(IntPtr L, int stackPos)
        {
            return ToLua.ToObject(L, stackPos) as GameObject;
        }

        // RVA: 0x18F28C8
        public object ToObject(IntPtr L, int stackPos)
        {
            return ToLua.ToObject(L, stackPos);
        }

        // RVA: 0x18F2940
        public sbyte CheckSByte(IntPtr L, int stackPos)
        {
            return (sbyte)Convert.ToSByte(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F29F0
        public byte CheckByte(IntPtr L, int stackPos)
        {
            return (byte)Convert.ToByte(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F2AA0
        public short CheckInt16(IntPtr L, int stackPos)
        {
            return (short)Convert.ToInt16(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F2B50
        public ushort CheckUInt16(IntPtr L, int stackPos)
        {
            return (ushort)Convert.ToUInt16(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F2C00
        public char CheckChar(IntPtr L, int stackPos)
        {
            return (char)Convert.ToChar(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F2CB0
        public int CheckInt32(IntPtr L, int stackPos)
        {
            return (int)Convert.ToInt32(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F2D60
        public uint CheckUInt32(IntPtr L, int stackPos)
        {
            return (uint)Convert.ToUInt32(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F2E10
        public Decimal CheckDecimal(IntPtr L, int stackPos)
        {
            return (Decimal)Convert.ToDecimal(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F2EC0
        public float CheckFloat(IntPtr L, int stackPos)
        {
            return (float)Convert.ToSingle(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F2F70
        public IntPtr CheckIntPtr(IntPtr L, int stackPos)
        {
            LuaTypes t = LuaDLL.lua_type(L, stackPos);
            if (t == LuaTypes.LUA_TUSERDATA)
            {
                return LuaDLL.lua_touserdata(L, stackPos);
            }
            if (t != LuaTypes.LUA_TNONE)
            {
                LuaDLL.luaL_typerror(L, stackPos, "IntPtr");
            }
            return IntPtr.Zero;
        }

        // RVA: 0x18F3064
        public UIntPtr CheckUIntPtr(IntPtr L, int stackPos)
        {
            throw new LuaException("NYI");
        }

        // RVA: 0x18F30D8
        public LuaByteBuffer CheckLuaByteBuffer(IntPtr L, int stackPos)
        {
            return new LuaByteBuffer(ToLua.CheckByteBuffer(L, stackPos));
        }

        // RVA: 0x18F3174
        public EventObject CheckEventObject(IntPtr L, int stackPos)
        {
            return ToLua.CheckObject<EventObject>(L, stackPos);
        }

        // RVA: 0x18F3270
        public Transform CheckTransform(IntPtr L, int stackPos)
        {
            return ToLua.CheckObject<Transform>(L, stackPos);
        }

        // RVA: 0x18F336C
        public GameObject CheckGameObject(IntPtr L, int stackPos)
        {
            return ToLua.CheckObject<GameObject>(L, stackPos);
        }

        // RVA: 0x18F344C
        public void Push(IntPtr L, sbyte n)
        {
            LuaDLL.lua_pushnumber(L, n);
        }

        // RVA: 0x18F34C8
        public void Push(IntPtr L, byte n)
        {
            LuaDLL.lua_pushnumber(L, n);
        }

        // RVA: 0x18F3544
        public void Push(IntPtr L, short n)
        {
            LuaDLL.lua_pushnumber(L, n);
        }

        // RVA: 0x18F35C0
        public void Push(IntPtr L, ushort n)
        {
            LuaDLL.lua_pushnumber(L, n);
        }

        // RVA: 0x18F363C
        public void Push(IntPtr L, char n)
        {
            LuaDLL.lua_pushnumber(L, n);
        }

        // RVA: 0x18F36B8
        public void Push(IntPtr L, int n)
        {
            LuaDLL.lua_pushnumber(L, n);
        }

        // RVA: 0x18F3730
        public void Push(IntPtr L, uint n)
        {
            LuaDLL.lua_pushnumber(L, n);
        }

        // RVA: 0x18F37A8
        public void Push(IntPtr L, Decimal n)
        {
            LuaDLL.lua_pushnumber(L, (double)n);
        }

        // RVA: 0x18F3860
        public void Push(IntPtr L, float n)
        {
            LuaDLL.lua_pushnumber(L, n);
        }

        // RVA: 0x18F38D8
        public void Push(IntPtr L, UIntPtr p)
        {
            throw new LuaException("NYI");
        }

        // RVA: 0x18F394C
        public void Push(IntPtr L, Delegate ev)
        {
            ToLua.Push(L, ev);
        }

        // RVA: 0x18F39C4
        public void Push(IntPtr L, object obj)
        {
            ToLua.Push(L, obj);
        }

        // RVA: 0x18F3A3C
        public void Push(IntPtr L, GameObject o)
        {
            if (o == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }

            int reference = TypeTraits<GameObject>.GetLuaReference(L);
            if (reference <= 0)
            {
                reference = ToLua.LoadPreType(L, typeof(GameObject));
            }
            ToLua.PushUserData(L, o, reference);
        }

        // RVA: 0x18F3BD8
        public void Push(IntPtr L, Transform o)
        {
            if (o == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }

            Type t = o.GetType();
            int reference = t == typeof(Transform) ? TypeTraits<Transform>.GetLuaReference(L) : LuaStatic.GetMetaReference(L, t);
            if (reference <= 0)
            {
                reference = ToLua.LoadPreType(L, t);
            }
            ToLua.PushUserData(L, o, reference);
        }

        // RVA: 0x18F3E68
        public Nullable<sbyte> ToNullSByte(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (sbyte)Convert.ToSByte(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F3F7C
        public Nullable<byte> ToNullByte(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (byte)Convert.ToByte(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F4090
        public Nullable<short> ToNullInt16(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (short)Convert.ToInt16(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F41A4
        public Nullable<ushort> ToNullUInt16(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (ushort)Convert.ToUInt16(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F42B8
        public Nullable<char> ToNullChar(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (char)Convert.ToChar(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F43CC
        public Nullable<int> ToNullInt32(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (int)Convert.ToInt32(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F44E0
        public Nullable<uint> ToNullUInt32(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (uint)Convert.ToUInt32(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F45F4
        public Nullable<Decimal> ToNullDecimal(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (Decimal)Convert.ToDecimal(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F471C
        public Nullable<float> ToNullFloat(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (float)Convert.ToSingle(LuaDLL.lua_tonumber(L, stackPos));
        }

        // RVA: 0x18F482C
        public Nullable<double> ToNullNumber(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.lua_tonumber(L, stackPos);
        }

        // RVA: 0x18F4900
        public Nullable<bool> ToNullBool(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.lua_toboolean(L, stackPos);
        }

        // RVA: 0x18F49D4
        public Nullable<long> ToNullInt64(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.tolua_toint64(L, stackPos);
        }

        // RVA: 0x18F4AAC
        public Nullable<ulong> ToNullUInt64(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.tolua_touint64(L, stackPos);
        }

        // RVA: 0x18F4B84
        public sbyte[] ToSByteArray(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F4C04
        public short[] ToInt16Array(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F4C84
        public ushort[] ToUInt16Array(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F4D04
        public Decimal[] ToDecimalArray(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F4D84
        public float[] ToFloatArray(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F4E04
        public double[] ToDoubleArray(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F4E84
        public int[] ToInt32Array(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F4F04
        public uint[] ToUInt32Array(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F4F84
        public long[] ToInt64Array(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F5004
        public ulong[] ToUInt64Array(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F5084
        public Nullable<Vector3> ToNullVec3(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.tolua_getvec3(L, stackPos);
        }

        // RVA: 0x18F5198
        public Nullable<Quaternion> ToNullQuat(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.tolua_getquat(L, stackPos);
        }

        // RVA: 0x18F52B0
        public Nullable<Vector2> ToNullVec2(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.tolua_getvec2(L, stackPos);
        }

        // RVA: 0x18F53B4
        public Nullable<Color> ToNullColor(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.tolua_getclr(L, stackPos);
        }

        // RVA: 0x18F54CC
        public Nullable<Vector4> ToNullVec4(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.tolua_getvec4(L, stackPos);
        }

        // RVA: 0x18F55E4
        public Nullable<Ray> ToNullRay(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.ToRay(L, stackPos);
        }

        // RVA: 0x18F56E8
        public Nullable<Bounds> ToNullBounds(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.ToBounds(L, stackPos);
        }

        // RVA: 0x18F57EC
        public Nullable<LayerMask> ToNullLayerMask(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (LayerMask)LuaDLL.tolua_getlayermask(L, stackPos);
        }

        // RVA: 0x18F58C8
        public Vector3[] ToVec3Array(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F5948
        public Quaternion[] ToQuatArray(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F59C8
        public Vector2[] ToVec2Array(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F5A48
        public Color[] ToColorArray(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F5AC8
        public Vector4[] ToVec4Array(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F5B48
        public Type[] ToTypeArray(IntPtr L, int stackPos)
        {
            return ToLua.ToNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F5BC8
        public Nullable<sbyte> CheckNullSByte(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (sbyte)Convert.ToSByte(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F5CDC
        public Nullable<byte> CheckNullByte(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (byte)Convert.ToByte(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F5DF0
        public Nullable<short> CheckNullInt16(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (short)Convert.ToInt16(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F5F04
        public Nullable<ushort> CheckNullUInt16(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (ushort)Convert.ToUInt16(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F6018
        public Nullable<char> CheckNullChar(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (char)Convert.ToChar(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F612C
        public Nullable<int> CheckNullInt32(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (int)Convert.ToInt32(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F6240
        public Nullable<uint> CheckNullUInt32(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (uint)Convert.ToUInt32(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F6354
        public Nullable<Decimal> CheckNullDecimal(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (Decimal)Convert.ToDecimal(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F647C
        public Nullable<float> CheckNullFloat(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return (float)Convert.ToSingle(LuaDLL.luaL_checknumber(L, stackPos));
        }

        // RVA: 0x18F658C
        public Nullable<double> CheckNullNumber(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.luaL_checknumber(L, stackPos);
        }

        // RVA: 0x18F6660
        public Nullable<bool> CheckNullBool(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.luaL_checkboolean(L, stackPos);
        }

        // RVA: 0x18F6734
        public Nullable<long> CheckNullInt64(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.tolua_checkint64(L, stackPos);
        }

        // RVA: 0x18F680C
        public Nullable<ulong> CheckNullUInt64(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return LuaDLL.tolua_checkuint64(L, stackPos);
        }

        // RVA: 0x18F68E4
        public sbyte[] CheckSByteArray(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F6964
        public short[] CheckInt16Array(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F69E4
        public ushort[] CheckUInt16Array(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F6A64
        public Decimal[] CheckDecimalArray(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F6AE4
        public float[] CheckFloatArray(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F6B64
        public double[] CheckDoubleArray(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F6BE4
        public int[] CheckInt32Array(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F6C64
        public uint[] CheckUInt32Array(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F6CE4
        public long[] CheckInt64Array(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F6D64
        public ulong[] CheckUInt64Array(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F6DE4
        public Nullable<Vector3> CheckNullVec3(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.CheckVector3(L, stackPos);
        }

        // RVA: 0x18F6EC0
        public Nullable<Quaternion> CheckNullQuat(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.CheckQuaternion(L, stackPos);
        }

        // RVA: 0x18F6FA4
        public Nullable<Vector2> CheckNullVec2(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.CheckVector2(L, stackPos);
        }

        // RVA: 0x18F708C
        public Nullable<Color> CheckNullColor(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.CheckColor(L, stackPos);
        }

        // RVA: 0x18F7170
        public Nullable<Vector4> CheckNullVec4(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.CheckVector4(L, stackPos);
        }

        // RVA: 0x18F7254
        public Nullable<Ray> CheckNullRay(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.CheckRay(L, stackPos);
        }

        // RVA: 0x18F7358
        public Nullable<Bounds> CheckNullBounds(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.CheckBounds(L, stackPos);
        }

        // RVA: 0x18F745C
        public Nullable<LayerMask> CheckNullLayerMask(IntPtr L, int stackPos)
        {
            if (LuaDLL.lua_type(L, stackPos) == LuaTypes.LUA_TNONE)
            {
                return null;
            }
            return ToLua.CheckLayerMask(L, stackPos);
        }

        // RVA: 0x18F7538
        public Vector3[] CheckVec3Array(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F75B8
        public Quaternion[] CheckQuatArray(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F7638
        public Vector2[] CheckVec2Array(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F76B8
        public Color[] CheckColorArray(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F7738
        public Vector4[] CheckVec4Array(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F77B8
        public Type[] CheckTypeArray(IntPtr L, int stackPos)
        {
            return ToLua.CheckNumberArray<sbyte>(L, stackPos);
        }

        // RVA: 0x18F7838
        public void Push(IntPtr L, Nullable<sbyte> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, n.Value);
        }

        // RVA: 0x18F791C
        public void Push(IntPtr L, Nullable<byte> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, n.Value);
        }

        // RVA: 0x18F7A00
        public void Push(IntPtr L, Nullable<short> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, n.Value);
        }

        // RVA: 0x18F7AE0
        public void Push(IntPtr L, Nullable<ushort> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, n.Value);
        }

        // RVA: 0x18F7BC0
        public void Push(IntPtr L, Nullable<char> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, n.Value);
        }

        // RVA: 0x18F7CA0
        public void Push(IntPtr L, Nullable<int> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, n.Value);
        }

        // RVA: 0x18F7D7C
        public void Push(IntPtr L, Nullable<uint> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, n.Value);
        }

        // RVA: 0x18F7E58
        public void Push(IntPtr L, Nullable<Decimal> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, (double)n.Value);
        }

        // RVA: 0x18F7F6C
        public void Push(IntPtr L, Nullable<float> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, n.Value);
        }

        // RVA: 0x18F805C
        public void Push(IntPtr L, Nullable<double> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushnumber(L, n.Value);
        }

        // RVA: 0x18F814C
        public void Push(IntPtr L, Nullable<bool> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.lua_pushboolean(L, n.Value);
        }

        // RVA: 0x18F822C
        public void Push(IntPtr L, Nullable<long> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.tolua_pushint64(L, n.Value);
        }

        // RVA: 0x18F8314
        public void Push(IntPtr L, Nullable<ulong> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.tolua_pushuint64(L, n.Value);
        }

        // RVA: 0x18F83FC
        public void Push(IntPtr L, Nullable<Vector3> v3)
        {
            if (v3 == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.tolua_pushvec3(L, v3.Value);
        }

        // RVA: 0x18F8508
        public void Push(IntPtr L, Nullable<Quaternion> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.tolua_pushquat(L, n.Value);
        }

        // RVA: 0x18F8608
        public void Push(IntPtr L, Nullable<Vector2> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.tolua_pushvec2(L, n.Value);
        }

        // RVA: 0x18F8704
        public void Push(IntPtr L, Nullable<Color> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.tolua_pushclr(L, n.Value);
        }

        // RVA: 0x18F8804
        public void Push(IntPtr L, Nullable<Vector4> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.tolua_pushvec4(L, n.Value);
        }

        // RVA: 0x18F8904
        public void Push(IntPtr L, Nullable<Ray> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            ToLua.Push(L, n.Value);
        }

        // RVA: 0x18F89F4
        public void Push(IntPtr L, Nullable<Bounds> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            ToLua.Push(L, n.Value);
        }

        // RVA: 0x18F8AE4
        public void Push(IntPtr L, Nullable<LayerMask> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            LuaDLL.tolua_pushlayermask(L, n.Value);
        }

        // RVA: 0x18F8BCC
        public void Push(IntPtr L, Nullable<Touch> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            ToLua.Push(L, n.Value);
        }

        // RVA: 0x18F8CBC
        public void Push(IntPtr L, Nullable<RaycastHit> n)
        {
            if (n == null)
            {
                LuaDLL.lua_pushnil(L);
                return;
            }
            ToLua.Push(L, n.Value);
        }

        // RVA: 0x18F8DAC
        public void .ctor()
        {

        }
    }
}
