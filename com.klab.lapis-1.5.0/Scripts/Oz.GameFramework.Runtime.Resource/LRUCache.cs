// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Resource.dll
//  Oz.GameFramework.Runtime.Resource.LRUCache<T>
//  来源：Il2CppDumper 元数据 + 共享泛型实例反汇编
//  共享泛型 RVA（<AssetRef> / <object> 实例）：
//    ctor 0x1E42DF4  ContainsKey 0x1E42EA8  Clear 0x1E42F10  SetCapacity 0x1E42F88
//    Get 0x1E4300C  Set 0x1E430CC  RemoveNode 0x1E43248  RemoveLast 0x1E43324  MoveToHead 0x1E433CC
// =============================================================================

using System.Collections.Generic;

namespace Oz.GameFramework.Runtime.Resource
{
    /// <summary>按容量淘汰最久未使用项的缓存（双向链表 + 字典）。</summary>
    public class LRUCache<T>
    {
        private int m_size;
        private int m_capacity;
        private Dictionary<RequestInfo, LinkedListNode<AssetRef>> m_dicPool;
        private LinkedList<AssetRef> m_linkedList;

        public LRUCache(int _capacity)
        {
            m_capacity = _capacity;
            m_dicPool = new Dictionary<RequestInfo, LinkedListNode<AssetRef>>();
            m_linkedList = new LinkedList<AssetRef>();
        }

        public bool ContainsKey(RequestInfo _key)
        {
            return m_dicPool.ContainsKey(_key);
        }

        public void Clear()
        {
            m_dicPool.Clear();
            m_linkedList.Clear();
            m_size = 0;
        }

        public void SetCapacity(int _capacity)
        {
            m_capacity = _capacity;
            while (m_size > m_capacity)
            {
                RemoveLast();
            }
        }

        /// <summary>命中则移到表头并返回。</summary>
        public AssetRef Get(RequestInfo _key)
        {
            LinkedListNode<AssetRef> node;
            if (!m_dicPool.TryGetValue(_key, out node))
            {
                return null;
            }
            MoveToHead(node);
            return node.Value;
        }

        /// <summary>写入并返回被淘汰的项（无淘汰时返回 null）。</summary>
        public AssetRef Set(AssetRef _assetRef)
        {
            RequestInfo key = _assetRef.Info;
            LinkedListNode<AssetRef> node;
            if (m_dicPool.TryGetValue(key, out node))
            {
                m_linkedList.Remove(node);
                m_linkedList.AddFirst(_assetRef);
                m_dicPool[key] = m_linkedList.First;
                return null;
            }

            m_linkedList.AddFirst(_assetRef);
            m_dicPool[key] = m_linkedList.First;
            m_size++;
            if (m_size > m_capacity)
            {
                return RemoveLast();
            }
            return null;
        }

        public void RemoveNode(AssetRef _assetRef)
        {
            LinkedListNode<AssetRef> node;
            if (m_dicPool.TryGetValue(_assetRef.Info, out node))
            {
                m_linkedList.Remove(node);
                m_dicPool.Remove(_assetRef.Info);
                m_size--;
            }
        }

        private AssetRef RemoveLast()
        {
            if (m_linkedList.Count == 0)
            {
                return null;
            }
            AssetRef last = m_linkedList.Last.Value;
            m_dicPool.Remove(last.Info);
            m_linkedList.RemoveLast();
            m_size--;
            return last;
        }

        private void MoveToHead(LinkedListNode<AssetRef> n)
        {
            m_linkedList.Remove(n);
            m_linkedList.AddFirst(n);
        }
    }
}