// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.ListChangedEventArgs
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jackpot
{
    public class ListChangedEventArgs<T> : EventArgs
    {
        private List<T> oldValue;

        public ListChangedEventKind Kind { get; private set; }
        public int Index
        {
            get
            {
                if (KindIsAnyOf(ListChangedEventKind.ForceUpdate, new ListChangedEventKind[1] { ListChangedEventKind.Edit }))
                {
                    return -1;
                }

                return Indexes[0];
            }
        }
        public List<int> Indexes { get; private set; }
        public int Count
        {
            get
            {
                if (KindIsAnyOf(ListChangedEventKind.ForceUpdate, new ListChangedEventKind[1] { ListChangedEventKind.Edit }))
                {
                    return -1;
                }

                return Indexes.Count;
            }
        }
        public List<T> OldValue
        {
            get
            {
                if (oldValue == null)
                {
                    throw new InvalidOperationException("Missing OldValue. Did you set BindableList`1 OldValueEnabled to true?");
                }

                return oldValue;
            }
        }

        public static ListChangedEventArgs<T> ForceUpdate(List<T> oldValue)
        {
            return new ListChangedEventArgs<T>(ListChangedEventKind.ForceUpdate, new List<int>(), oldValue);
        }

        public static ListChangedEventArgs<T> Update(int index, List<T> oldValue)
        {
            return new ListChangedEventArgs<T>(ListChangedEventKind.Update, new List<int> { index }, oldValue);
        }

        public static ListChangedEventArgs<T> Update(List<int> indexes, List<T> oldValue)
        {
            return new ListChangedEventArgs<T>(ListChangedEventKind.Update, indexes, oldValue);
        }

        public static ListChangedEventArgs<T> Add(int index, List<T> oldValue)
        {
            return new ListChangedEventArgs<T>(ListChangedEventKind.Add, new List<int> { index }, oldValue);
        }

        public static ListChangedEventArgs<T> Add(List<int> indexes, List<T> oldValue)
        {
            return new ListChangedEventArgs<T>(ListChangedEventKind.Add, indexes, oldValue);
        }

        public static ListChangedEventArgs<T> Remove(int index, List<T> oldValue)
        {
            return new ListChangedEventArgs<T>(ListChangedEventKind.Remove, new List<int> { index }, oldValue);
        }

        public static ListChangedEventArgs<T> Remove(List<int> indexes, List<T> oldValue)
        {
            return new ListChangedEventArgs<T>(ListChangedEventKind.Remove, indexes, oldValue);
        }

        public static ListChangedEventArgs<T> Edit(List<T> oldValue)
        {
            return new ListChangedEventArgs<T>(ListChangedEventKind.Edit, new List<int>(), oldValue);
        }

        private ListChangedEventArgs(ListChangedEventKind kind, List<int> indexes, List<T> oldValue)
        {
            Kind = kind;
            Indexes = indexes;
            this.oldValue = oldValue;
        }

        public bool KindIsAnyOf(ListChangedEventKind kind, ListChangedEventKind[] moreKinds)
        {
            if (Kind == kind)
            {
                return true;
            }

            if (moreKinds == null)
            {
                return false;
            }

            for (int i = 0; i < moreKinds.Length; i++)
            {
                if (Kind == moreKinds[i])
                {
                    return true;
                }
            }

            return false;
        }
    }
}
