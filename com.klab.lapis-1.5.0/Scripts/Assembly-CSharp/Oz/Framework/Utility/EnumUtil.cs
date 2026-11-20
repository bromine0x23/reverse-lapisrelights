// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.Utility.EnumUtil
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;

namespace Oz.Framework.Utility
{
    /// <summary>按类型名（短名，位于 Assembly-CSharp）解析枚举值与名称。</summary>
    public static class EnumUtil
    {
        /// <summary>枚举名字符串 → 整数值（类型不匹配时抛 InvalidCastException）。</summary>
        // RVA: 0x2EEBEE4
        public static int ToInt(string type, string eString)
        {
            Type enumType = TypeUtil.GetType(type);
            return (int)Enum.Parse(enumType, eString);
        }

        /// <summary>枚举整数值 → 名称。</summary>
        // RVA: 0x2EEBFE4
        public static string ToString(string type, int eInteger)
        {
            Type enumType = TypeUtil.GetType(type);
            return Enum.GetName(enumType, eInteger);
        }

        // RVA: 0x2EEC0D0
        public static object ToEnum(string type, string eString)
        {
            Type enumType = TypeUtil.GetType(type);
            return Enum.Parse(enumType, eString);
        }

        // RVA: 0x2EEC198
        public static int GetEnumCount(string type)
        {
            Type enumType = TypeUtil.GetType(type);
            return Enum.GetValues(enumType).Length;
        }

        // 以下泛型方法元数据中 RVA 为 -1，但 dump.cs 给出了共享泛型实例的 RVA：
        //   ToEnum<T>(string) 0x1544454 / ToEnum<T>(int) 0x154435C / Parse<T> 0x154425C
        //   TryParse<T>(string,out T) 0x26B28D8 / TryParse<T>(string,bool,out T) 0x26B270C
        // 上述 RVA 的反汇编已确认调用 Enum.Parse / Enum.ToObject / Enum.Parse(3 参)，
        // 且两参 TryParse 实为转调 ignoreCase = true。

        /// <summary>枚举名 → 枚举值（RVA 0x1544454：Enum.Parse(typeof(T), eString)）。</summary>
        // [NoToLua]
        public static T ToEnum<T>(string eString)
        {
            return (T)Enum.Parse(typeof(T), eString);
        }

        /// <summary>整数值 → 枚举值（RVA 0x154435C：Enum.ToObject(typeof(T), iValue)）。</summary>
        // [NoToLua]
        public static T ToEnum<T>(int iValue)
        {
            return (T)Enum.ToObject(typeof(T), iValue);
        }

        /// <summary>解析枚举（RVA 0x154425C：Enum.Parse(typeof(T), value, ignoreCase)）。</summary>
        public static T Parse<T>(string value, bool ignoreCase)
        {
            return (T)Enum.Parse(typeof(T), value, ignoreCase);
        }

        /// <summary>尝试解析枚举（RVA 0x26B28D8：转调三参重载，ignoreCase = true）。</summary>
        public static bool TryParse<T>(string value, out T result)
        {
            return TryParse<T>(value, true, out result);
        }

        /// <summary>尝试解析枚举（RVA 0x26B270C：Enum.Parse 失败时返回 false）。</summary>
        public static bool TryParse<T>(string value, bool ignoreCase, out T result)
        {
            try
            {
                result = (T)Enum.Parse(typeof(T), value, ignoreCase);
                return true;
            }
            catch (Exception)
            {
                result = default(T);
                return false;
            }
        }
    }
}
