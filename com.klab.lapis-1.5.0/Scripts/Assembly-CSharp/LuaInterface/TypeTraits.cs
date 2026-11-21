// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.TypeTraits
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;

namespace LuaInterface
{
    public static class TypeTraits<T>
    {
        public static Func<IntPtr, int, bool> Check;
        public static Type type = typeof(T);
        public static bool IsValueType = type.IsValueType;
        public static bool IsArray = type.IsArray;
        private static string typeName;
        private static int nilType;
        private static int metaref;

        public static void Init(Func<IntPtr, int, bool> check)
        {
            if (check != null)
            {
                Check = check;
            }
            else if (IsValueType)
            {
                Check = DefaultCheck;
            }
            else
            {
                Check = IsUserData;
            }

            if (typeName == null)
            {
                typeName = type.FullName;
            }
        }

        public static string GetTypeName()
        {
            return (typeName != null) ? typeName : (typeName = type.FullName);
        }

        public static int GetLuaReference(IntPtr L)
        {
            if (metaref <= 0)
            {
                metaref = LuaStatic.GetMetaReference(L, type);
            }

            return metaref;
        }

        private static bool DefaultCheck(IntPtr L, int pos)
        {
            return true;
        }

        private static bool IsNilType()
        {
            return nilType == 0;
        }

        private static bool IsUserData(IntPtr L, int pos)
        {
            return LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TUSERDATA;
        }

        private static bool IsUserTable(IntPtr L, int pos)
        {
            return LuaDLL.lua_type(L, pos) == LuaTypes.LUA_TTABLE;
        }
    }
}
