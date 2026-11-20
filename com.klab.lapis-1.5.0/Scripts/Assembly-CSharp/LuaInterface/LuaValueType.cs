// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaValueType
//  来源：Il2CppDumper 元数据 + 反汇编（ctor 0x1F6D884 / op_Implicit 0x1F6D88C、0x1F6D890 / ToString 0x1F6D898）
// =============================================================================

using System;

namespace LuaInterface
{
    public struct LuaValueType
    {
        public const int None = 0;
        public const int Vector3 = 1;
        public const int Quaternion = 2;
        public const int Vector2 = 3;
        public const int Color = 4;
        public const int Vector4 = 5;
        public const int Ray = 6;
        public const int Bounds = 7;
        public const int Touch = 8;
        public const int LayerMask = 9;
        public const int RaycastHit = 10;
        public const int Int64 = 11;
        public const int UInt64 = 12;
        public const int Max = 64;

        private int type;

        // RVA: 0x1F6D884
        public LuaValueType(int value)
        {
            type = value;
        }

        // RVA: 0x1F6D88C
        public static implicit operator int(LuaValueType mask)
        {
            return mask.type;
        }

        // RVA: 0x1F6D890
        public static implicit operator LuaValueType(int intVal)
        {
            return new LuaValueType(intVal);
        }

        // RVA: 0x1F6D898
        public override string ToString()
        {
            return LuaValueTypeName.Get(type);
        }
    }
}
