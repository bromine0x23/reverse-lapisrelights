// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.StackTraits
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;

namespace LuaInterface
{
    public static class StackTraits<T>
    {
        public static Action<IntPtr, T> Push;
        public static Func<IntPtr, int, T> Check;
        public static Func<IntPtr, int, T> To;

        public static void Init(Action<IntPtr, T> push, Func<IntPtr, int, T> check, Func<IntPtr, int, T> to)
        {
            Push = push;
            Check = check;
            To = to;
        }

        private static Action<IntPtr, T> SelectPush()
        {
            if (TypeTraits<T>.IsValueType)
            {
                return PushValue;
            }

            if (TypeTraits<T>.IsArray)
            {
                return PushArray;
            }

            return PushObject;
        }

        private static void PushValue(IntPtr L, T o)
        {
        }

        private static void PushObject(IntPtr L, T o)
        {
        }

        private static void PushArray(IntPtr L, T array)
        {
        }

        private static T DefaultTo(IntPtr L, int pos)
        {
            return default(T);
        }

        private static T DefaultCheck(IntPtr L, int stackPos)
        {
            return default(T);
        }

        static StackTraits()
        {
            Push = SelectPush();
            Check = DefaultCheck;
            To = DefaultTo;
        }
    }
}
