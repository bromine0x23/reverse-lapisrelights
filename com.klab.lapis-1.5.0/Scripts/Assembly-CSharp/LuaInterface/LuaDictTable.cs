// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaDictTable
//  来源：Il2CppDumper 元数据 + 反汇编（tolua 标准实现）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;

namespace LuaInterface
{
        public class LuaDictTable : IDisposable, IEnumerable<DictionaryEntry>
        {
            LuaTable table;
            LuaState state;

            public LuaDictTable(LuaTable table)            
            {
                table.AddRef();
                this.table = table;
                this.state = table.GetLuaState() ;
            }

            public void Dispose()
            {
                if (table != null)
                {
                    table.Dispose();
                    table = null;
                }
            }

            public object this[string key]
            {
                get
                {
                    return table[key];
                }

                set
                {
                    table[key] = value;
                }
            }

            public Hashtable ToHashtable()
            {
                Hashtable hash = new Hashtable();
                var iter = GetEnumerator();

                while (iter.MoveNext())
                {
                    hash.Add(iter.Current.Key, iter.Current.Value);                
                }

                iter.Dispose();
                return hash;
            }

            public IEnumerator<DictionaryEntry> GetEnumerator()
            {
                return new Enumerator(this);
            }

            IEnumerator IEnumerable.GetEnumerator()
            {
                return GetEnumerator();
            }

            class Enumerator : IEnumerator<DictionaryEntry>
            {            
                LuaState state;                        
                DictionaryEntry current = new DictionaryEntry();
                int top = -1;

                public Enumerator(LuaDictTable list)
                {                
                    state = list.state;
                    top = state.LuaGetTop();
                    state.Push(list.table);
                    state.LuaPushNil();                
                }

                public DictionaryEntry Current
                {
                    get 
                    {
                        return current;
                    }
                }

                object IEnumerator.Current
                {
                    get
                    {
                        return Current;
                    }
                }

                public bool MoveNext()
                {
                    if (state.LuaNext(-2))
                    {
                        current = new DictionaryEntry();
                        current.Key = state.ToVariant(-2);
                        current.Value = state.ToVariant(-1);
                        state.LuaPop(1);
                        return true;
                    }
                    else
                    {
                        current = new DictionaryEntry();
                        return false;
                    }                
                }

                public void Reset()
                {
                    current = new DictionaryEntry();
                }

                public void Dispose()
                {
                    if (state != null)
                    {
                        state.LuaSetTop(top);
                        state = null;
                    }
                }
            }
        }

        public class LuaDictTable<K, V> : IDisposable, IEnumerable<LuaDictEntry<K, V>>
        {
            LuaTable table;
            LuaState state;

            public LuaDictTable(LuaTable table)
            {
                table.AddRef();
                this.table = table;
                this.state = table.GetLuaState();
            }

            public void Dispose()
            {
                if (table != null)
                {
                    table.Dispose();
                    table = null;
                }
            }

            public V this[K key]
            {
                get
                {
                    return table.RawGet<K, V>(key);
                }

                set
                {                
                    table.RawSet(key, value);
                }
            }

            public Dictionary<K, V> ToDictionary()
            {
                Dictionary<K, V> dict = new Dictionary<K, V>();
                var iter = GetEnumerator();

                while (iter.MoveNext())
                {
                    dict.Add(iter.Current.Key, iter.Current.Value);
                }

                iter.Dispose();
                return dict;
            }

            public IEnumerator<LuaDictEntry<K, V>> GetEnumerator()
            {
                return new Enumerator(this);
            }

            IEnumerator IEnumerable.GetEnumerator()
            {
                return GetEnumerator();
            }

            class Enumerator : IEnumerator<LuaDictEntry<K, V>>
            {
                LuaState state;
                LuaDictEntry<K, V> current = new LuaDictEntry<K, V>();
                int top = -1;

                public Enumerator(LuaDictTable<K, V> list)
                {
                    state = list.state;
                    top = state.LuaGetTop();
                    state.Push(list.table);
                    state.LuaPushNil();
                }

                public LuaDictEntry<K, V> Current
                {
                    get
                    {
                        return current;
                    }
                }

                object IEnumerator.Current
                {
                    get
                    {
                        return Current;
                    }
                }

                public bool MoveNext()
                {
                    if (state.LuaNext(-2))
                    {
                        current = new LuaDictEntry<K, V>();
                        current.Key = state.CheckValue<K>(-2);
                        current.Value = state.CheckValue<V>(-1);
                        state.LuaPop(1);
                        return true;
                    }
                    else
                    {
                        current = new LuaDictEntry<K, V>();
                        return false;
                    }
                }

                public void Reset()
                {
                    current = new LuaDictEntry<K, V>();
                }

                public void Dispose()
                {
                    if (state != null)
                    {
                        state.LuaSetTop(top);
                        state = null;
                    }
                }
            }
        }
}
