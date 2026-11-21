// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.ConcurrentMemory
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
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
    public class ConcurrentMemory : IMemory
    {
        private Dictionary<string, object> dict;
        private ReaderWriterLockSlim slim;

        // RVA: 0x1789F54
        public ConcurrentMemory()
        {
                        this(new Dictionary<string, object>());
        }

        // RVA: 0x1789FC0
        public ConcurrentMemory(Dictionary<string, object> dict)
        {
            this.dict = dict;
            slim = new ReaderWriterLockSlim();
        }

        public TValue Get<TValue>(string key)
        {
            return Get(key, default(TValue));
        }

        public TValue Get<TValue>(string key, TValue defaultValue)
        {
            slim.EnterReadLock();
            try
            {
                if (dict.ContainsKey(key))
                {
                    return (TValue)dict[key];
                }

                return defaultValue;
            }
            finally
            {
                slim.ExitReadLock();
            }
        }

        public bool TryGet<TValue>(string key, out TValue value)
        {
            slim.EnterReadLock();
            try
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
            finally
            {
                slim.ExitReadLock();
            }
        }

        // RVA: 0x178A03C
        public bool Contains(string key)
        {
                        slim.EnterReadLock();
                        try
                        {
                            if (dict.ContainsKey(key))
                            {
                                return dict[key] != null;
                            }

                            return false;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x178A144
        public bool ContainsKey(string key)
        {
                        slim.EnterReadLock();
                        try
                        {
                            return dict.ContainsKey(key);
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        public void Set<TValue>(string key, TValue value)
        {
            slim.EnterWriteLock();
            try
            {
                if (dict.ContainsKey(key))
                {
                    dict.Remove(key);
                }

                dict.Add(key, value);
            }
            finally
            {
                slim.ExitWriteLock();
            }
        }

        // RVA: 0x178A214
        public void Remove(string key)
        {
                        slim.EnterWriteLock();
                        try
                        {
                            if (dict.ContainsKey(key))
                            {
                                dict.Remove(key);
                            }
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x178A300
        public void RemoveAll()
        {
                        slim.EnterWriteLock();
                        try
                        {
                            dict.Clear();
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x178A3B0
        static ConcurrentMemory()
        {
                        ConcurrentMemory concurrentMemory = new ConcurrentMemory();
                        concurrentMemory.Set<bool>("fullaot", default(bool));
                        concurrentMemory.Get<bool>("fullaot");
                        concurrentMemory.TryGet<bool>("fullaot", out bool _);
                        concurrentMemory.Set<int>("fullaot", default(int));
                        concurrentMemory.Get<int>("fullaot");
                        concurrentMemory.TryGet<int>("fullaot", out int _);
                        concurrentMemory.Set<long>("fullaot", default(long));
                        concurrentMemory.Get<long>("fullaot");
                        concurrentMemory.TryGet<long>("fullaot", out long _);
                        concurrentMemory.Set<short>("fullaot", default(short));
                        concurrentMemory.Get<short>("fullaot");
                        concurrentMemory.TryGet<short>("fullaot", out short _);
                        concurrentMemory.Set<byte>("fullaot", default(byte));
                        concurrentMemory.Get<byte>("fullaot");
                        concurrentMemory.TryGet<byte>("fullaot", out byte _);
                        concurrentMemory.Set<float>("fullaot", default(float));
                        concurrentMemory.Get<float>("fullaot");
                        concurrentMemory.TryGet<float>("fullaot", out float _);
                        concurrentMemory.Set<decimal>("fullaot", default(decimal));
                        concurrentMemory.Get<decimal>("fullaot");
                        concurrentMemory.TryGet<decimal>("fullaot", out decimal _);
                        concurrentMemory.Set<uint>("fullaot", default(uint));
                        concurrentMemory.Get<uint>("fullaot");
                        concurrentMemory.TryGet<uint>("fullaot", out uint _);
                        concurrentMemory.Set<char>("fullaot", default(char));
                        concurrentMemory.Get<char>("fullaot");
                        concurrentMemory.TryGet<char>("fullaot", out char _);
                        concurrentMemory.Set<double>("fullaot", default(double));
                        concurrentMemory.Get<double>("fullaot");
                        concurrentMemory.TryGet<double>("fullaot", out double _);
                        concurrentMemory.Set<DateTime>("fullaot", default(DateTime));
                        concurrentMemory.Get<DateTime>("fullaot");
                        concurrentMemory.TryGet<DateTime>("fullaot", out DateTime _);
        }
    }
}
