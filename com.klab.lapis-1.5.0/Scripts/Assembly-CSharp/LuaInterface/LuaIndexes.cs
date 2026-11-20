// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaIndexes
//  来源：Il2CppDumper 元数据 + 反汇编（cctor 0x2297A84）
// =============================================================================

namespace LuaInterface
{
    public class LuaIndexes
    {
        public static int LUA_REGISTRYINDEX;
        public static int LUA_ENVIRONINDEX;
        public static int LUA_GLOBALSINDEX;

        // RVA: 0x2297A7C
        public LuaIndexes()
        {
        }

        // RVA: 0x2297A84
        static LuaIndexes()
        {
            // -10000 / -10001 / -10002（反汇编常量 0xFFFFD8F0 / 0xFFFFD8EF / 0xFFFFD8EE）
            LUA_REGISTRYINDEX = -10000;
            LUA_ENVIRONINDEX = -10001;
            LUA_GLOBALSINDEX = -10002;
        }
    }
}
