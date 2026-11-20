// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaArrayTable
//  来源：Il2CppDumper 元数据 + 反汇编（tolua 标准实现）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;

namespace LuaInterface
{
        public class LuaArrayTable : IDisposable, IEnumerable<object>
        {       
            private LuaTable table = null;
            private LuaState state = null;

            public LuaArrayTable(LuaTable table)           
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

            public int Length
            {
                get
                {
                    return table.Length;
                }
            }

            public object this[int key]
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

            public void ForEach(Action<object> action)
            {
                using (var iter = this.GetEnumerator())
                {
                    while (iter.MoveNext())
                    {
                        action(iter.Current);
                    }                
                }
            }

            public IEnumerator<object> GetEnumerator()
            {
                return new Enumerator(this);
            }

            IEnumerator IEnumerable.GetEnumerator()
            {
                return GetEnumerator();
            }

            class Enumerator : IEnumerator<object>
            {            
                LuaState state;
                int index = 1;
                object current = null;
                int top = -1;

                public Enumerator(LuaArrayTable list)
                {                
                    state = list.state;
                    top = state.LuaGetTop();
                    state.Push(list.table);                
                }

                public object Current
                {
                    get
                    {
                        return current;
                    }
                }

                public bool MoveNext()
                {
                    state.LuaRawGetI(-1, index);
                    current = state.ToVariant(-1);
                    state.LuaPop(1);
                    ++index;
                    return current == null ? false : true;
                }

                public void Reset()
                {
                    index = 1;
                    current = null;
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
