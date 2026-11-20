// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaDictEntry
//  来源：Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;

namespace LuaInterface
{
    public struct LuaDictEntry<K, V>
    {
        public LuaDictEntry(K key, V value)
            : this()
        {
            Key = key;
            Value = value;
        }

        public K Key { get; set; }
        public V Value { get; set; }
    }
}
