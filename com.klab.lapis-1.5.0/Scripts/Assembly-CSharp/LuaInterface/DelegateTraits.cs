// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.DelegateTraits / LuaOut
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;

namespace LuaInterface
{
    public static class DelegateTraits<T>
    {
        private static Func<LuaFunction, LuaTable, Delegate> _Create;

        public static void Init(Func<LuaFunction, LuaTable, Delegate> func)
        {
            _Create = func;
        }

        public static Delegate Create(LuaFunction func)
        {
            return (_Create != null) ? _Create(func, null) : null;
        }

        public static Delegate Create(LuaFunction func, LuaTable self)
        {
            return (_Create != null) ? _Create(func, self) : null;
        }
    }

    public class LuaOut<T>
    {
        public LuaOut()
        {
        }
    }
}
