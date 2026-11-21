// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.ICacheAdapter
//  来源：Il2CppDumper 元数据（签名精确）
// =============================================================================

using System;

namespace Jackpot
{
    public interface ICacheAdapter
    {
        string Id { get; }
        int ExpireSeconds { get; set; }
        TValue Get<TValue>(string key, Func<TValue> fallback);
        TValue Get<TValue>(string key, int expireSeconds, Func<TValue> fallback);
        bool TryGet<TValue>(string key, out TValue value);
        CacheAdapterAsync<TValue> GetAsync<TValue>(string key, AsyncFallbackDelegate<TValue> fallback);
        CacheAdapterAsync<TValue> GetAsync<TValue>(string key, int expireSeconds, AsyncFallbackDelegate<TValue> fallback);
        void Set(string key, object value);
        void Set(string key, int expireSeconds, object value);
        bool ContainsKey(string key);
        void Remove(string key);
        void Clear();
    }
}
