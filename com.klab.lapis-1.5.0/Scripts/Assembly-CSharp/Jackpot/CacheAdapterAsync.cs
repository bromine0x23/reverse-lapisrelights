// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.CacheAdapterAsync
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;

namespace Jackpot
{
    public class CacheAdapterAsync<TValue> : Context
    {
        private readonly ICacheAdapter cache;
        private readonly string key;
        private readonly int expireSeconds;
        private readonly AsyncFallbackDelegate<TValue> fallback;
        private readonly Action<TValue> successCallback;
        private readonly Action<object> failureCallback;

        public CacheAdapterAsync(ICacheAdapter cache, string key, int expireSeconds, AsyncFallbackDelegate<TValue> fallback)
            : this(cache, key, expireSeconds, fallback, null, null)
        {
        }

        private CacheAdapterAsync(ICacheAdapter cache, string key, int expireSeconds, AsyncFallbackDelegate<TValue> fallback, Action<TValue> successCallback, Action<object> failureCallback)
        {
            if (cache == null)
            {
                throw new ArgumentNullException("cache");
            }

            if (string.IsNullOrEmpty(key))
            {
                throw new ArgumentException("key");
            }

            if (fallback == null)
            {
                throw new ArgumentNullException("fallback");
            }

            this.cache = cache;
            this.key = key;
            this.expireSeconds = expireSeconds;
            this.fallback = fallback;
            this.successCallback = successCallback;
            this.failureCallback = failureCallback;
        }

        private CacheAdapterAsync(int id, ICacheAdapter cache, string key, int expireSeconds, AsyncFallbackDelegate<TValue> fallback, Action<TValue> successCallback, Action<object> failureCallback)
            : base(id)
        {
            if (cache == null)
            {
                throw new ArgumentNullException("cache");
            }

            if (string.IsNullOrEmpty(key))
            {
                throw new ArgumentException("key");
            }

            if (expireSeconds <= -2)
            {
                throw new ArgumentException("expireSeconds");
            }

            if (fallback == null)
            {
                throw new ArgumentNullException("fallback");
            }

            this.cache = cache;
            this.key = key;
            this.expireSeconds = expireSeconds;
            this.fallback = fallback;
            this.successCallback = successCallback;
            this.failureCallback = failureCallback;
        }

        public CacheAdapterAsync<TValue> OnSuccess(Action<TValue> successCallback)
        {
            return new CacheAdapterAsync<TValue>(Id, cache, key, expireSeconds, fallback, successCallback, failureCallback);
        }

        public CacheAdapterAsync<TValue> OnFailure(Action<object> failureCallback)
        {
            return new CacheAdapterAsync<TValue>(Id, cache, key, expireSeconds, fallback, successCallback, failureCallback);
        }

        public override void Execute()
        {
            TValue value;
            if (cache.TryGet<TValue>(key, out value))
            {
                InvokeSuccessCallback(value);
            }
            else
            {
                InvokeFallback();
            }
        }

        private void InvokeFallback()
        {
            if (fallback != null)
            {
                fallback(InvokeSuccessCallback, InvokeFailureCallback);
            }
        }

        private void InvokeSuccessCallback(TValue result)
        {
            if (successCallback != null)
            {
                successCallback(result);
            }
        }

        private void InvokeFailureCallback(object error)
        {
            if (failureCallback != null)
            {
                failureCallback(error);
            }

            cache.Remove(key);
        }
    }
}
