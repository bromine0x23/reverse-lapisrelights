// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.CachePool<T> / CachePool<K, V>
//  来源：Il2CppDumper 元数据 + 共享泛型实例反汇编
//  共享泛型 RVA（<object> / <object, object> 实例）：
//    CachePool<T>            ctor 0x1E41598  Get 0x1E41610  Put 0x1E41680  Clear 0x1E4176C
//    CachePool<K,V>          ctor 0x1E41794  Get 0x1E4180C  Put 0x1E4189C  Clear 0x1E41A94
//  Put 均先判空，再经 ICacheable/ICacheable<K> 取键并 Reset（与反汇编一致）。
// =============================================================================

using System.Collections.Generic;

namespace Oz.GameFramework.Runtime
{
    /// <summary>单键对象栈缓存：取出时 Pop，回收时 Reset 后 Push。</summary>
    public class CachePool<T>
    {
        private Stack<T> m_Objects;

        public CachePool()
        {
            m_Objects = new Stack<T>();
        }

        public T Get()
        {
            if (m_Objects.Count >= 1)
            {
                return m_Objects.Pop();
            }

            return default;
        }

        public void Put(T value)
        {
            if (value == null)
            {
                return;
            }

            ((ICacheable)value).Reset();
            m_Objects.Push(value);
        }

        public void Clear()
        {
            m_Objects.Clear();
        }
    }

    /// <summary>按 key 分组的对象栈缓存。</summary>
    public class CachePool<K, V>
    {
        private Dictionary<K, Stack<V>> m_Objects;

        public CachePool()
        {
            m_Objects = new Dictionary<K, Stack<V>>();
        }

        /// <summary>取 key 对应栈顶元素，栈空返回 default。</summary>
        public V Get(K key)
        {
            Stack<V> stack;
            if (m_Objects.TryGetValue(key, out stack) && stack.Count >= 1)
            {
                return stack.Pop();
            }

            return default;
        }

        /// <summary>把对象放回缓存：key 取自 ICacheable&lt;K&gt;.Index，Reset 后入栈。</summary>
        public void Put(V value)
        {
            if (value == null)
            {
                return;
            }

            K key = ((ICacheable<K>)value).Index;
            ((ICacheable)value).Reset();

            Stack<V> stack;
            if (!m_Objects.TryGetValue(key, out stack))
            {
                stack = new Stack<V>();
                m_Objects.Add(key, stack);
            }

            stack.Push(value);
        }

        public void Clear()
        {
            m_Objects.Clear();
        }
    }
}
