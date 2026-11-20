// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp-firstpass.dll
//  TPNSPush.JsonHelper
//  来源：Il2CppDumper 元数据 + 共享泛型实例反汇编
//  共享泛型 RVA（<object> / <int> 实例）：
//    FromJson<T>          0x25F8B0C
//    ToJson<T>(T[])       0x14637AC
//    ToJson<T>(List<T>)   0x146369C（调用 List<T>.ToArray 后写入 Items）
//    ToJson<T>(T[], bool) 0x146381C
//  Wrapper<T>.Items 为 T[]（非 List<T>），由 dump.cs 字段声明确认。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace TPNSPush
{
    /// <summary>JsonUtility 的数组/列表包装（Unity 不支持直接序列化顶层数组）。</summary>
    public static class JsonHelper
    {
        [System.Serializable]
        private class Wrapper<T>
        {
            public T[] Items;
        }

        public static T[] FromJson<T>(string json)
        {
            Wrapper<T> wrapper = JsonUtility.FromJson<Wrapper<T>>(json);
            return wrapper.Items;
        }

        public static string ToJson<T>(T[] array)
        {
            Wrapper<T> wrapper = new Wrapper<T> { Items = array };
            return JsonUtility.ToJson(wrapper);
        }

        public static string ToJson<T>(List<T> list)
        {
            Wrapper<T> wrapper = new Wrapper<T> { Items = list.ToArray() };
            return JsonUtility.ToJson(wrapper);
        }

        public static string ToJson<T>(T[] array, bool prettyPrint)
        {
            Wrapper<T> wrapper = new Wrapper<T> { Items = array };
            return JsonUtility.ToJson(wrapper, prettyPrint);
        }
    }
}
