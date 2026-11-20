// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.Utility.TypeUtil
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//  注：伪代码中 sub_10B6B58 是 IL2CPP 为 Type.GetType(string) 生成的
//      il2cpp_codegen_get_type 调用（附带当前程序集全名），此处按源码语义还原。
// =============================================================================

using System;

namespace Oz.Framework.Utility
{
    /// <summary>按短名反射解析类型，依次尝试本程序集、UnityEngine、UGUI、Timeline。</summary>
    public static class TypeUtil
    {
        // RVA: 0x187CDFC
        public static bool IsTypeOf(object obj, string typeName)
        {
            Type type = GetType(typeName);
            if (obj == null)
            {
                return false;
            }
            return obj.GetType().Equals(type);
        }

        // RVA: 0x187CED8
        public static Type GetType(string s)
        {
            if (string.IsNullOrEmpty(s))
            {
                return null;
            }

            Type type = Type.GetType(s + ",Assembly-CSharp");
            if (type == null)
            {
                type = Type.GetType(string.Format("UnityEngine.{0},UnityEngine", s));
            }
            if (type == null)
            {
                type = Type.GetType(string.Format("UnityEngine.UI.{0},UnityEngine.UI", s));
            }
            if (type == null)
            {
                type = Type.GetType(string.Format("UnityEngine.Timeline.{0},UnityEngine.Timeline", s));
            }
            return type;
        }
    }
}
