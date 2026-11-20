// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaValueTypeName
//  来源：Il2CppDumper 元数据 + 反汇编
//        cctor 0x1F6D9EC：names = new string[64]，仅填充 [0..10]（字符串字面量逐一确认）
//        Get   0x1F6D900：type <= 63 取 names[type]，否则 "UnKnownType:" + ConstStringTable.GetNumIntern(type)
// =============================================================================

namespace LuaInterface
{
    public static class LuaValueTypeName
    {
        public static string[] names;

        // RVA: 0x1F6D9EC
        static LuaValueTypeName()
        {
            names = new string[64];
            names[LuaValueType.None] = "None";
            names[LuaValueType.Vector3] = "Vector3";
            names[LuaValueType.Quaternion] = "Quaternion";
            names[LuaValueType.Vector2] = "Vector2";
            names[LuaValueType.Color] = "Color";
            names[LuaValueType.Vector4] = "Vector4";
            names[LuaValueType.Ray] = "Ray";
            names[LuaValueType.Bounds] = "Bounds";
            names[LuaValueType.Touch] = "Touch";
            names[LuaValueType.LayerMask] = "LayerMask";
            names[LuaValueType.RaycastHit] = "RaycastHit";
        }

        // RVA: 0x1F6D900
        public static string Get(int type)
        {
            if (type <= 0x3F)
            {
                return names[type];
            }

            return "UnKnownType:" + ConstStringTable.GetNumIntern(type);
        }
    }
}
