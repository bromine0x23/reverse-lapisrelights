// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Memory
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot
{
    public class Memory : IMemory
    {
        private Dictionary<string, object> dict;

        // RVA: 0x19E77C0
        public Memory()
        {
                        dict = new Dictionary<string, object>();
        }

        // RVA: 0x19F6B28
        public Memory(Dictionary<string, object> dict)
        {
        }

        public TValue Get<TValue>(string key)
        {
            return Get(key, default(TValue));
        }

        public TValue Get<TValue>(string key, TValue defaultValue)
        {
            if (Contains(key))
            {
                return (TValue)dict[key];
            }

            return defaultValue;
        }

        public bool TryGet<TValue>(string key, out TValue value)
        {
            object value2;
            if (dict.TryGetValue(key, out value2))
            {
                value = (TValue)value2;
                return true;
            }

            value = default(TValue);
            return false;
        }

        // RVA: 0x19F6B54
        public bool Contains(string key)
        {
                        if (dict.ContainsKey(key))
                        {
                            return dict[key] != null;
                        }

                        return false;
        }

        // RVA: 0x19F6BF0
        public bool ContainsKey(string key)
        {
                        return dict.ContainsKey(key);
        }

        public void Set<TValue>(string key, TValue value)
        {
            Remove(key);
            dict.Add(key, value);
        }

        // RVA: 0x19F6C58
        public void Remove(string key)
        {
                        if (dict.ContainsKey(key))
                        {
                            dict.Remove(key);
                        }
        }

        // RVA: 0x19F6CF0
        public void RemoveAll()
        {
                        dict.Clear();
        }

        // RVA: 0x19F6D48
        static Memory()
        {
                        Memory memory = new Memory();
                        memory.Set<bool>("fullaot", default(bool));
                        memory.Get<bool>("fullaot");
                        memory.TryGet<bool>("fullaot", out bool _);
                        memory.Set<int>("fullaot", default(int));
                        memory.Get<int>("fullaot");
                        memory.TryGet<int>("fullaot", out int _);
                        memory.Set<long>("fullaot", default(long));
                        memory.Get<long>("fullaot");
                        memory.TryGet<long>("fullaot", out long _);
                        memory.Set<short>("fullaot", default(short));
                        memory.Get<short>("fullaot");
                        memory.TryGet<short>("fullaot", out short _);
                        memory.Set<byte>("fullaot", default(byte));
                        memory.Get<byte>("fullaot");
                        memory.TryGet<byte>("fullaot", out byte _);
                        memory.Set<float>("fullaot", default(float));
                        memory.Get<float>("fullaot");
                        memory.TryGet<float>("fullaot", out float _);
                        memory.Set<decimal>("fullaot", default(decimal));
                        memory.Get<decimal>("fullaot");
                        memory.TryGet<decimal>("fullaot", out decimal _);
                        memory.Set<uint>("fullaot", default(uint));
                        memory.Get<uint>("fullaot");
                        memory.TryGet<uint>("fullaot", out uint _);
                        memory.Set<char>("fullaot", default(char));
                        memory.Get<char>("fullaot");
                        memory.TryGet<char>("fullaot", out char _);
                        memory.Set<double>("fullaot", default(double));
                        memory.Get<double>("fullaot");
                        memory.TryGet<double>("fullaot", out double _);
                        memory.Set<DateTime>("fullaot", default(DateTime));
                        memory.Get<DateTime>("fullaot");
                        memory.TryGet<DateTime>("fullaot", out DateTime _);
        }
    }
}
