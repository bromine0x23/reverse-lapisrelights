// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.CacheAdapter
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
    public class CacheAdapter : ICacheAdapter
    {
        public static readonly ICacheAdapter Default;
        private const string CacheAdapterPoolKey = "Jackpot.CacheAdapterPool";
        private const string DefaultCacheAdapterId = "Jackpot.CacheAdapter.Default";
        private const int DefaultExpireSeconds = 30;
        private static readonly object LifecycleLock;
        private readonly ReaderWriterLockSlim expireSlim;
        private readonly Dictionary<string, Timer> expireTimers;
        private readonly Memory memory;
        private int expireSeconds;
        public string Id { get; private set; }
        public int ExpireSeconds { get { return expireSeconds; } set { expireSeconds = value; } }
        // RVA: 0x1786C8C
        public static ICacheAdapter Create(string id)
        {
                        lock (LifecycleLock)
                        {
                            if (id == "Jackpot.CacheAdapter.Default")
                            {
                                return Default;
                            }

                            Dictionary<string, ICacheAdapter> cacheAdapterPool = GetCacheAdapterPool();
                            if (!cacheAdapterPool.ContainsKey(id) || cacheAdapterPool[id] == null)
                            {
                                cacheAdapterPool.Add(id, new CacheAdapter(id, 30));
                            }

                            return cacheAdapterPool[id];
                        }
        }

        // RVA: 0x178707C
        public static void Delete(string id)
        {
                        lock (LifecycleLock)
                        {
                            if (id == "Jackpot.CacheAdapter.Default")
                            {
                                Default.Clear();
                                return;
                            }

                            Dictionary<string, ICacheAdapter> cacheAdapterPool = GetCacheAdapterPool();
                            if (cacheAdapterPool.ContainsKey(id))
                            {
                                cacheAdapterPool[id]?.Clear();
                                cacheAdapterPool.Remove(id);
                            }
                        }
        }

        // RVA: 0x1786E80
        private static Dictionary<string, ICacheAdapter> GetCacheAdapterPool()
        {
                        ApplicationCache instance = ApplicationCache.Instance;
                        if (!instance.Contains("Jackpot.CacheAdapterPool"))
                        {
                            instance.Set("Jackpot.CacheAdapterPool", new Dictionary<string, ICacheAdapter>());
                        }

                        return instance.Get<Dictionary<string, ICacheAdapter>>("Jackpot.CacheAdapterPool");
        }



        // RVA: 0x1787324
        public int get_ExpireSeconds()
        {
            return expireSeconds;
        }

        // RVA: 0x178736C
        public void set_ExpireSeconds(int value)
        {
            expireSeconds = value;
        }

        // RVA: 0x1786FAC
        private CacheAdapter(string id, int expireSeconds)
        {
                        expireSlim = new ReaderWriterLockSlim();
                        expireTimers = new Dictionary<string, Timer>();
                        memory = new Memory();
                        Id = id;
                        ExpireSeconds = expireSeconds;
        }

        public TValue Get<TValue>(string key, Func<TValue> fallback)
        {
            return Get(key, DefaultExpireSeconds, fallback);
        }

        public TValue Get<TValue>(string key, int expireSeconds, Func<TValue> fallback)
        {
            if (string.IsNullOrEmpty(key))
            {
                throw new ArgumentNullException("key");
            }

            if (fallback == null)
            {
                throw new ArgumentNullException("fallback");
            }

            expireSlim.EnterUpgradeableReadLock();
            try
            {
                if (memory.TryGet<TValue>(key, out TValue value))
                {
                    return value;
                }

                TValue val = fallback();
                Set(key, expireSeconds, val);
                return val;
            }
            finally
            {
                expireSlim.ExitUpgradeableReadLock();
            }
        }

        public bool TryGet<TValue>(string key, out TValue value)
        {
            if (string.IsNullOrEmpty(key))
            {
                throw new ArgumentNullException("key");
            }

            expireSlim.EnterReadLock();
            try
            {
                return memory.TryGet<TValue>(key, out value);
            }
            finally
            {
                expireSlim.ExitReadLock();
            }
        }

        public CacheAdapterAsync<TValue> GetAsync<TValue>(string key, AsyncFallbackDelegate<TValue> fallback)
        {
            return GetAsync(key, ExpireSeconds, fallback);
        }

        public CacheAdapterAsync<TValue> GetAsync<TValue>(string key, int expireSeconds, AsyncFallbackDelegate<TValue> fallback)
        {
            return new CacheAdapterAsync<TValue>(this, key, expireSeconds, fallback);
        }

        // RVA: 0x1787488
        public void Set(string key, object value)
        {
                        Set(key, 30, value);
        }

        // RVA: 0x1787494
        public void Set(string key, int expireSeconds, object value)
        {
                        if (string.IsNullOrEmpty(key))
                        {
                            throw new ArgumentNullException("key");
                        }

                        if (expireSeconds < -1)
                        {
                            throw new ArgumentException(string.Format("Expected argument expireSeconds was greater than -1(-1 means Timeout.Infinite), but was {0}", expireSeconds));
                        }

                        if (expireSeconds == 0)
                        {
                            return;
                        }

                        expireSlim.EnterWriteLock();
                        try
                        {
                            memory.Set(key, value);
                            if (expireSeconds != -1)
                            {
                                RemoveExpireTimerInternal(key);
                                Timer timer = new Timer(delegate
                                {
                                    expireSlim.EnterWriteLock();
                                    try
                                    {
                                        memory.Remove(key);
                                        RemoveExpireTimerInternal(key);
                                    }
                                    finally
                                    {
                                        expireSlim.ExitWriteLock();
                                    }
                                }, null, -1, -1);
                                timer.Change(expireSeconds * 1000, -1);
                                expireTimers.Add(key, timer);
                            }
                        }
                        finally
                        {
                            expireSlim.ExitWriteLock();
                        }
        }

        // RVA: 0x17877DC
        public bool ContainsKey(string key)
        {
                        expireSlim.EnterReadLock();
                        try
                        {
                            return memory.ContainsKey(key);
                        }
                        finally
                        {
                            expireSlim.ExitReadLock();
                        }
        }

        // RVA: 0x1787880
        public void Remove(string key)
        {
                        expireSlim.EnterWriteLock();
                        try
                        {
                            memory.Remove(key);
                            RemoveExpireTimerInternal(key);
                        }
                        finally
                        {
                            expireSlim.ExitWriteLock();
                        }
        }

        // RVA: 0x178791C
        public void Clear()
        {
                        expireSlim.EnterWriteLock();
                        try
                        {
                            memory.RemoveAll();
                            foreach (Timer value in expireTimers.Values)
                            {
                                value.Dispose();
                            }

                            expireTimers.Clear();
                        }
                        finally
                        {
                            expireSlim.ExitWriteLock();
                        }
        }

        // RVA: 0x178771C
        private void RemoveExpireTimerInternal(string key)
        {
                        if (expireTimers.ContainsKey(key))
                        {
                            expireTimers[key]?.Dispose();
                            expireTimers.Remove(key);
                        }
        }

        // RVA: 0x1787B2C
        static CacheAdapter()
        {
                        Default = new CacheAdapter("Jackpot.CacheAdapter.Default", 30);
                        LifecycleLock = new object();
                        CacheAdapter cacheAdapter = new CacheAdapter("fullaot", -1);
                        cacheAdapter.Get<bool>("b");
                        cacheAdapter.TryGet<bool>("b", out bool _);
                        cacheAdapter.GetAsync<bool>("b", () => default(bool));
                        cacheAdapter.Get<int>("i");
                        cacheAdapter.TryGet<int>("i", out int _);
                        cacheAdapter.GetAsync<int>("i", () => default(int));
                        cacheAdapter.Get<long>("l");
                        cacheAdapter.TryGet<long>("l", out long _);
                        cacheAdapter.GetAsync<long>("l", () => default(long));
                        cacheAdapter.Get<short>("s");
                        cacheAdapter.TryGet<short>("s", out short _);
                        cacheAdapter.GetAsync<short>("s", () => default(short));
                        cacheAdapter.Get<byte>("bs");
                        cacheAdapter.TryGet<byte>("bs", out byte _);
                        cacheAdapter.GetAsync<byte>("bs", () => default(byte));
                        cacheAdapter.Get<float>("f");
                        cacheAdapter.TryGet<float>("f", out float _);
                        cacheAdapter.GetAsync<float>("f", () => default(float));
                        cacheAdapter.Get<decimal>("d");
                        cacheAdapter.TryGet<decimal>("d", out decimal _);
                        cacheAdapter.GetAsync<decimal>("d", () => default(decimal));
                        cacheAdapter.Get<uint>("u");
                        cacheAdapter.TryGet<uint>("u", out uint _);
                        cacheAdapter.GetAsync<uint>("u", () => default(uint));
                        cacheAdapter.Get<char>("c");
                        cacheAdapter.TryGet<char>("c", out char _);
                        cacheAdapter.GetAsync<char>("c", () => default(char));
        }
    }
}
