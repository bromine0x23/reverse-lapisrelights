// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.ReferencePool<K, V>
//  来源：Il2CppDumper 元数据 + 共享泛型实例反汇编
//  共享泛型 RVA（<object, object> 实例）：
//    ctor 0x1E425CC / Contains 0x1E42644 / Put 0x1E4266C
//    Get 0x1E4274C / Remove(K) 0x1E42830 / Remove(V) 0x1E428AC / Clear 0x1E42B98
//  Put 先判空，键取自 ICacheable<K>.Index（与反汇编一致）。
// =============================================================================

using System.Collections.Generic;

namespace Oz.GameFramework.Runtime
{
    /// <summary>键值引用池：按 key 保存单实例。</summary>
    public class ReferencePool<K, V>
    {
        private Dictionary<K, V> m_Objects;

        public ReferencePool()
        {
            m_Objects = new Dictionary<K, V>();
        }

        public bool Contains(K key)
        {
            return m_Objects.ContainsKey(key);
        }

        /// <summary>把 value 放入池：键取自 ICacheable&lt;K&gt;.Index。</summary>
        public void Put(V value)
        {
            if (value == null)
            {
                return;
            }

            K key = ((ICacheable<K>)value).Index;
            m_Objects[key] = value;
        }

        public V Get(K key)
        {
            V value;
            m_Objects.TryGetValue(key, out value);
            return value;
        }

        public bool Remove(K key)
        {
            return m_Objects.Remove(key);
        }

        public bool Remove(V value)
        {
            return m_Objects.Remove((K)(object)value.GetType());
        }

        public void Clear()
        {
            m_Objects.Clear();
        }
    }
}
