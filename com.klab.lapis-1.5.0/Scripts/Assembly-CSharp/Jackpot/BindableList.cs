// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.BindableList
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;

namespace Jackpot
{
    public class BindableList<T> : IList<T>, ICollection<T>, IEnumerable<T>, IEnumerable, IList, ICollection, ICloneable
    {
        protected enum EditType
        {
            None,
            Update,
            Remove,
            Edit
        }

        private static readonly Func<T, T, bool> DefaultChangesPolicy;
        private List<T> items;
        private EventDispatcher<ListChangedEventArgs<T>> dispatcher;
        private Func<T, T, bool> changesPolicy;
        private EditType editType;

        public BindableRules Rule { get; private set; }
        public bool OldValueEnabled { get; private set; }
        public int Count { get { return items.Count; } }
        public T this[int index]
        {
            get { return items[index]; }
            set { SetItem(index, value); }
        }
        public bool Editting { get { return editType != EditType.None; } }

        object IList.this[int index]
        {
            get { return this[index]; }
            set
            {
                ValidateNullAndNullsAreIllegal(value);
                this[index] = (T)value;
            }
        }
        bool ICollection.IsSynchronized { get { return false; } }
        object ICollection.SyncRoot { get { return this; } }
        bool ICollection<T>.IsReadOnly { get { return false; } }
        bool IList.IsFixedSize { get { return false; } }
        bool IList.IsReadOnly { get { return false; } }

        public BindableList()
            : this(BindableRules.NotAllowCallStackChanging)
        {
        }

        public BindableList(BindableRules rule)
            : this(new List<T>(), rule)
        {
        }

        public BindableList(bool oldValueEnabled)
            : this(new List<T>(), oldValueEnabled)
        {
        }

        public BindableList(BindableRules rule, bool oldValueEnabled)
            : this(new List<T>(), rule, oldValueEnabled)
        {
        }

        public BindableList(IEnumerable<T> collection)
            : this(collection, BindableRules.NotAllowCallStackChanging)
        {
        }

        public BindableList(IEnumerable<T> collection, BindableRules rule)
            : this(collection, rule, false)
        {
        }

        public BindableList(IEnumerable<T> collection, bool oldValueEnabled)
            : this(collection, BindableRules.NotAllowCallStackChanging, oldValueEnabled)
        {
        }

        public BindableList(IEnumerable<T> collection, BindableRules rule, bool oldValueEnabled)
        {
            items = ((collection != null) ? new List<T>(collection) : new List<T>());
            Rule = rule;
            OldValueEnabled = oldValueEnabled;
            dispatcher = new EventDispatcher<ListChangedEventArgs<T>>();
            changesPolicy = DefaultChangesPolicy;
            editType = EditType.None;
        }

        public BindableList(BindableList<T> that)
            : this(that, true)
        {
        }

        public BindableList(BindableList<T> that, bool withTakeOverHandler)
            : this(that, withTakeOverHandler, false)
        {
        }

        public BindableList(BindableList<T> that, bool withTakeOverHandler, bool withCopyItem)
        {
            if (that == null)
            {
                throw new ArgumentNullException("that");
            }

            items = (withCopyItem ? that.ResolveOldValue() : new List<T>(that.items));
            Rule = that.Rule;
            OldValueEnabled = that.OldValueEnabled;
            dispatcher = (withTakeOverHandler ? new EventDispatcher<ListChangedEventArgs<T>>(that.dispatcher) : new EventDispatcher<ListChangedEventArgs<T>>());
            changesPolicy = that.changesPolicy;
            editType = EditType.None;
        }

        public void Bind(EventHandler<ListChangedEventArgs<T>> handler)
        {
            dispatcher.AddHandler(handler, false);
        }

        public void Bind(object target, EventHandler<ListChangedEventArgs<T>> handler)
        {
            dispatcher.AddHandler(target, handler, false);
        }

        public void BindOnce(EventHandler<ListChangedEventArgs<T>> handler)
        {
            dispatcher.AddHandler(handler, true);
        }

        public void BindOnce(object target, EventHandler<ListChangedEventArgs<T>> handler)
        {
            dispatcher.AddHandler(target, handler, true);
        }

        public bool IsBinding()
        {
            return !dispatcher.HandlerIsEmpty;
        }

        public bool IsBinding(EventHandler<ListChangedEventArgs<T>> binder)
        {
            return dispatcher.ContainsHandler(binder, false);
        }

        public bool IsBindingOnce()
        {
            return !dispatcher.OnceHandlerIsEmpty;
        }

        public bool IsBindingOnce(EventHandler<ListChangedEventArgs<T>> binder)
        {
            return dispatcher.ContainsHandler(binder, true);
        }

        public void Unbind(EventHandler<ListChangedEventArgs<T>> binder)
        {
            dispatcher.RemoveHandler(binder);
        }

        public void UnBindAll()
        {
            dispatcher.RemoveAllHandlers();
        }

        public void SetChangesPolicy(Func<T, T, bool> changesPolicy)
        {
            this.changesPolicy = changesPolicy;
        }

        public IEnumerator<T> GetEnumerator()
        {
            return items.GetEnumerator();
        }

        public void CopyTo(T[] array, int arrayIndex)
        {
            items.CopyTo(array, arrayIndex);
        }

        public T[] ToArray()
        {
            return items.ToArray();
        }

        public bool IsEmpty()
        {
            return items.Count < 1;
        }

        public int CountBy(Predicate<T> predicate)
        {
            int count = 0;
            for (int i = 0; i < items.Count; i++)
            {
                if (predicate(items[i]))
                {
                    count++;
                }
            }

            return count;
        }

        public bool Contains(T item)
        {
            return items.Contains(item);
        }

        public bool Contains(Predicate<T> predicate)
        {
            return items.Exists(predicate);
        }

        public int IndexOf(T item)
        {
            return items.IndexOf(item);
        }

        public int LastIndexOf(T item)
        {
            return items.LastIndexOf(item);
        }

        public T Find(Predicate<T> match)
        {
            return items.Find(match);
        }

        public T Find(Predicate<T> match, T defaultValue)
        {
            for (int i = 0; i < items.Count; i++)
            {
                if (match(items[i]))
                {
                    return items[i];
                }
            }

            return defaultValue;
        }

        public T FindLast(Predicate<T> match)
        {
            return items.FindLast(match);
        }

        public T FindLast(Predicate<T> match, T defaultValue)
        {
            for (int i = items.Count - 1; i >= 0; i--)
            {
                if (match(items[i]))
                {
                    return items[i];
                }
            }

            return defaultValue;
        }

        public Tuple<List<int>, List<T>> FindAllIndexAndItem(Predicate<T> match)
        {
            List<int> indexes = new List<int>();
            List<T> found = new List<T>();
            for (int i = 0; i < items.Count; i++)
            {
                if (match(items[i]))
                {
                    indexes.Add(i);
                    found.Add(items[i]);
                }
            }

            return Tuple.Create(indexes, found);
        }

        public List<T> AsList()
        {
            return new List<T>(items);
        }

        public List<T> Filter(Predicate<T> match)
        {
            return items.FindAll(match);
        }

        public List<T> Reject(Predicate<T> match)
        {
            return items.FindAll(delegate (T item) { return !match(item); });
        }

        public List<U> Map<U>(Func<T, U> callback)
        {
            List<U> result = new List<U>(items.Count);
            for (int i = 0; i < items.Count; i++)
            {
                result.Add(callback(items[i]));
            }

            return result;
        }

        public List<U> FlatMap<U>(Func<T, IEnumerable<U>> callback)
        {
            List<U> result = new List<U>();
            for (int i = 0; i < items.Count; i++)
            {
                result.AddRange(callback(items[i]));
            }

            return result;
        }

        public void Add(T item)
        {
            ValidateNullAndNullsAreIllegal(item);
            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            int index = items.Count;
            items.Add(item);
            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Add(index, oldValue));
            }
        }

        public void Add(T item, T[] moreItems)
        {
            ValidateNullAndNullsAreIllegal(item);
            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            List<int> indexes = new List<int>();
            indexes.Add(items.Count);
            items.Add(item);
            if (moreItems != null)
            {
                for (int i = 0; i < moreItems.Length; i++)
                {
                    ValidateNullAndNullsAreIllegal(moreItems[i]);
                    indexes.Add(items.Count);
                    items.Add(moreItems[i]);
                }
            }

            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Add(indexes, oldValue));
            }
        }

        public void AddRange(IEnumerable<T> items)
        {
            if (items == null)
            {
                throw new ArgumentNullException("items");
            }

            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            List<int> indexes = new List<int>();
            foreach (T item in items)
            {
                ValidateNullAndNullsAreIllegal(item);
                indexes.Add(this.items.Count);
                this.items.Add(item);
            }

            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Add(indexes, oldValue));
            }
        }

        public void AddUnique(T item, T[] moreItems)
        {
            if (!items.Contains(item))
            {
                Add(item);
            }

            if (moreItems != null)
            {
                for (int i = 0; i < moreItems.Length; i++)
                {
                    if (!items.Contains(moreItems[i]))
                    {
                        Add(moreItems[i]);
                    }
                }
            }
        }

        public void AddUnique(IEnumerable<T> items)
        {
            foreach (T item in items)
            {
                if (!this.items.Contains(item))
                {
                    Add(item);
                }
            }
        }

        public void Insert(int index, T item)
        {
            ValidateNullAndNullsAreIllegal(item);
            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            items.Insert(index, item);
            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Add(index, oldValue));
            }
        }

        public void InsertRange(int index, IEnumerable<T> items)
        {
            if (items == null)
            {
                throw new ArgumentNullException("items");
            }

            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            List<int> indexes = new List<int>();
            int current = index;
            foreach (T item in items)
            {
                ValidateNullAndNullsAreIllegal(item);
                this.items.Insert(current, item);
                indexes.Add(current);
                current++;
            }

            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Add(indexes, oldValue));
            }
        }

        public void InsertUnique(int index, T item, T[] moreItems)
        {
            if (!items.Contains(item))
            {
                Insert(index, item);
                index++;
            }

            if (moreItems != null)
            {
                for (int i = 0; i < moreItems.Length; i++)
                {
                    if (!items.Contains(moreItems[i]))
                    {
                        Insert(index, moreItems[i]);
                        index++;
                    }
                }
            }
        }

        public void InsertUnique(int index, IEnumerable<T> items)
        {
            foreach (T item in items)
            {
                if (!this.items.Contains(item))
                {
                    Insert(index, item);
                    index++;
                }
            }
        }

        public void Swap(int aIndex, int bIndex)
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            T item = items[aIndex];
            items[aIndex] = items[bIndex];
            items[bIndex] = item;
            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Update(new List<int> { aIndex, bIndex }, oldValue));
            }
        }

        public void Swap(Predicate<T> aFindFirst, Predicate<T> bFindFirst)
        {
            int aIndex = items.FindIndex(aFindFirst);
            int bIndex = items.FindIndex(bFindFirst);
            if (aIndex < 0 || bIndex < 0)
            {
                return;
            }

            Swap(aIndex, bIndex);
        }

        public void Update(int index, T item)
        {
            SetItem(index, item);
        }

        public void Update(int index, Action<T> updater)
        {
            Update(index, delegate (T item)
            {
                updater(item);
                return item;
            });
        }

        public void Update(int index, Func<T, T> updater)
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            T before = ResolveOldItem(index);
            List<T> oldValue = ResolveOldValueIfNeeded();
            if (EditSection(EditType.Update, delegate
            {
                T after = updater(items[index]);
                items[index] = after;
                return AreDifferByChangesPolicy(before, after);
            }) && IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Update(index, oldValue));
            }
        }

        public void Update(Predicate<T> match, Action<T> updater)
        {
            Update(match, delegate (T item)
            {
                updater(item);
                return item;
            });
        }

        public void Update(Predicate<T> match, Func<T, T> updater)
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            List<int> indexes = new List<int>();
            if (EditSection(EditType.Update, delegate
            {
                for (int i = 0; i < items.Count; i++)
                {
                    if (!match(items[i]))
                    {
                        continue;
                    }

                    T before = items[i];
                    T after = updater(before);
                    if (AreDifferByChangesPolicy(before, after))
                    {
                        items[i] = after;
                        indexes.Add(i);
                    }
                }

                return indexes.Count > 0;
            }) && IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Update(indexes, oldValue));
            }
        }

        public void UpdateAll(Action<T> updater)
        {
            UpdateAll(delegate (T item)
            {
                updater(item);
                return item;
            });
        }

        public void UpdateAll(Func<T, T> updater)
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            List<int> indexes = new List<int>();
            if (EditSection(EditType.Update, delegate
            {
                for (int i = 0; i < items.Count; i++)
                {
                    T before = items[i];
                    T after = updater(before);
                    if (AreDifferByChangesPolicy(before, after))
                    {
                        items[i] = after;
                        indexes.Add(i);
                    }
                }

                return indexes.Count > 0;
            }) && IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Update(indexes, oldValue));
            }
        }

        public void UpdateAll(Predicate<T> match, Func<T, T> updater)
        {
            Update(match, updater);
        }

        public void Edit(IEnumerable<T> newValue)
        {
            Edit(delegate (List<T> list)
            {
                return newValue;
            });
        }

        public void Edit(Action<List<T>> editor)
        {
            Edit(delegate (List<T> list)
            {
                editor(list);
                return list;
            });
        }

        public void Edit(Func<List<T>, IEnumerable<T>> editor)
        {
            ValidateCallStackChanging();
            List<T> oldValue = ResolveOldValueIfNeeded();
            List<T> forEdit = ResolveOldValue();
            if (EditSection(EditType.Edit, delegate
            {
                IEnumerable<T> edited = editor(forEdit);
                if (edited == null)
                {
                    return false;
                }

                items = new List<T>(edited);
                return true;
            }) && IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Edit(oldValue));
            }
        }

        public void ForceUpdate()
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.ForceUpdate(ResolveOldValueIfNeeded()));
            }
        }

        public bool Remove(T item)
        {
            int index = items.IndexOf(item);
            if (index < 0)
            {
                return false;
            }

            RemoveAt(index);
            return true;
        }

        public void RemoveAt(int index)
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            items.RemoveAt(index);
            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Remove(index, oldValue));
            }
        }

        public void RemoveAll(Predicate<T> match)
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            List<int> indexes = new List<int>();
            for (int i = items.Count - 1; i >= 0; i--)
            {
                if (match(items[i]))
                {
                    indexes.Add(i);
                    items.RemoveAt(i);
                }
            }

            indexes.Reverse();
            if (indexes.Count > 0 && IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Remove(indexes, oldValue));
            }
        }

        public void Clear()
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            List<T> oldValue = ResolveOldValueIfNeeded();
            List<int> indexes = new List<int>();
            for (int i = 0; i < items.Count; i++)
            {
                indexes.Add(i);
            }

            items.Clear();
            if (indexes.Count > 0 && IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Remove(indexes, oldValue));
            }
        }

        public virtual object Clone()
        {
            return Clone(true);
        }

        public virtual object Clone(bool withTakeOverHandler)
        {
            return Clone(withTakeOverHandler, false);
        }

        public virtual object Clone(bool withTakeOverHandler, bool withCopyItem)
        {
            return new BindableList<T>(this, withTakeOverHandler, withCopyItem);
        }

        protected static bool IsCompatibleObject(object value)
        {
            return value is T || (value == null && default(T) == null);
        }

        protected static void ValidateNullAndNullsAreIllegal(object value)
        {
            if (value == null && default(T) != null)
            {
                throw new ArgumentNullException("value");
            }
        }

        protected virtual void ValidateNotEditting()
        {
            if (Editting)
            {
                throw new InvalidOperationException(string.Format("Still Editting. type: {0}", editType));
            }
        }

        protected virtual void ValidateCallStackChanging()
        {
            if (Rule != BindableRules.NotAllowCallStackChanging)
            {
                return;
            }

            if (dispatcher.IsDispatching)
            {
                throw new InvalidOperationException("A value cannot be changed while dispatching data.");
            }
        }

        protected bool IsDispatchable()
        {
            if (Editting)
            {
                return false;
            }

            if (!dispatcher.IsDispatching)
            {
                return true;
            }

            return Rule != BindableRules.ThroughCallStackChanging;
        }

        protected bool AreDifferByChangesPolicy(T before, T after)
        {
            if (changesPolicy != null)
            {
                return changesPolicy(before, after);
            }

            return true;
        }

        protected virtual void SetItem(int index, T item)
        {
            ValidateNotEditting();
            T before = ResolveOldItem(index);
            List<T> oldValue = ResolveOldValueIfNeeded();
            items[index] = item;
            if (AreDifferByChangesPolicy(before, item) && IsDispatchable())
            {
                dispatcher.Dispatch(this, ListChangedEventArgs<T>.Update(index, oldValue));
            }
        }

        protected virtual List<T> ResolveOldValueIfNeeded()
        {
            if (!IsDispatchable())
            {
                return items;
            }

            if (!OldValueEnabled)
            {
                return items;
            }

            return ResolveOldValue();
        }

        protected virtual List<T> ResolveOldValue()
        {
            if (items.Count < 1)
            {
                return new List<T>();
            }

            List<T> result = new List<T>(items.Count);
            for (int i = 0; i < items.Count; i++)
            {
                T item = items[i];
                if (item is ICloneable cloneable)
                {
                    item = (T)cloneable.Clone();
                }

                result.Add(item);
            }

            return result;
        }

        protected virtual T ResolveOldItem(int index)
        {
            T item = items[index];
            if (item is ICloneable cloneable)
            {
                return (T)cloneable.Clone();
            }

            return item;
        }

        protected bool EditSection(EditType type, Func<bool> section)
        {
            if (type == EditType.None)
            {
                throw new ArgumentException("unexpected parameter", "type");
            }

            editType = type;
            try
            {
                return section();
            }
            finally
            {
                editType = EditType.None;
            }
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return items.GetEnumerator();
        }

        void ICollection.CopyTo(Array array, int index)
        {
            ((ICollection)items).CopyTo(array, index);
        }

        int IList.Add(object value)
        {
            ValidateNullAndNullsAreIllegal(value);
            int index = items.Count;
            Add((T)value);
            return index;
        }

        bool IList.Contains(object value)
        {
            return IsCompatibleObject(value) && Contains((T)value);
        }

        int IList.IndexOf(object value)
        {
            return IsCompatibleObject(value) ? IndexOf((T)value) : -1;
        }

        void IList.Insert(int index, object value)
        {
            ValidateNullAndNullsAreIllegal(value);
            Insert(index, (T)value);
        }

        void IList.Remove(object value)
        {
            if (IsCompatibleObject(value))
            {
                Remove((T)value);
            }
        }

        static BindableList()
        {
            DefaultChangesPolicy = delegate (T x, T y)
            {
                return !EqualityComparer<T>.Default.Equals(x, y);
            };
        }
    }
}
