// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.BindableDictionary
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;

namespace Jackpot
{
    [Serializable]
    public class BindableDictionary<TKey, TValue> : IDictionary<TKey, TValue>, ICollection<KeyValuePair<TKey, TValue>>, IEnumerable<KeyValuePair<TKey, TValue>>, IEnumerable, IDictionary, ICollection
    {
        protected enum EditType
        {
            None,
            Update,
            Remove,
            Edit
        }

        private static readonly Func<TValue, TValue, bool> DefaultChangesPolicy;
        private Dictionary<TKey, TValue> entries;
        private EventDispatcher<DictionaryChangedEventArgs<TKey, TValue>> dispatcher;
        private Func<TValue, TValue, bool> changesPolicy;
        private EditType editType;

        public int Count { get { return entries.Count; } }
        public TValue this[TKey key]
        {
            get
            {
                ValidateContainsKey(key);
                return entries[key];
            }
            set
            {
                SetEntry(key, value);
            }
        }
        public BindableRules Rule { get; private set; }
        public bool OldValueEnabled { get; private set; }
        public bool Editting { get { return editType != EditType.None; } }
        public Dictionary<TKey, TValue>.KeyCollection Keys { get { return entries.Keys; } }
        public Dictionary<TKey, TValue>.ValueCollection Values { get { return entries.Values; } }

        int ICollection.Count { get { return Count; } }
        bool ICollection.IsSynchronized { get { return false; } }
        object ICollection.SyncRoot { get { return this; } }
        bool IDictionary.IsFixedSize { get { return false; } }
        bool IDictionary.IsReadOnly { get { return false; } }
        bool ICollection<KeyValuePair<TKey, TValue>>.IsReadOnly { get { return false; } }
        object IDictionary.this[object key]
        {
            get
            {
                ValidateObjectEnableAsKey(key);
                return this[(TKey)key];
            }
            set
            {
                ValidateObjectEnableAsKey(key);
                ValidateObjectEnableAsValue(value);
                this[(TKey)key] = (TValue)value;
            }
        }
        ICollection IDictionary.Keys { get { return entries.Keys; } }
        ICollection<TKey> IDictionary<TKey, TValue>.Keys { get { return entries.Keys; } }
        ICollection IDictionary.Values { get { return entries.Values; } }
        ICollection<TValue> IDictionary<TKey, TValue>.Values { get { return entries.Values; } }

        private static void ValidateNotNullKey(TKey key)
        {
            if (key == null)
            {
                throw new ArgumentNullException("key");
            }
        }

        private static void ValidateObjectEnableAsKey(object key)
        {
            if (key == null)
            {
                throw new ArgumentNullException("key");
            }

            if (key is TKey)
            {
                return;
            }

            throw new ArgumentException("not of type: " + typeof(TKey), "key");
        }

        private static void ValidateObjectEnableAsValue(object value)
        {
            if (value is TValue)
            {
                return;
            }

            throw new ArgumentException("not of type: " + typeof(TValue), "value");
        }

        public BindableDictionary()
            : this(new Dictionary<TKey, TValue>())
        {
        }

        public BindableDictionary(IDictionary<TKey, TValue> dictionary)
            : this(dictionary, BindableRules.NotAllowCallStackChanging)
        {
        }

        public BindableDictionary(BindableRules rule)
            : this(null, rule)
        {
        }

        public BindableDictionary(bool oldValueEnabled)
            : this(null, oldValueEnabled)
        {
        }

        public BindableDictionary(IDictionary<TKey, TValue> dictionary, BindableRules rule)
            : this(dictionary, rule, false)
        {
        }

        public BindableDictionary(IDictionary<TKey, TValue> dictionary, bool oldValueEnabled)
            : this(dictionary, BindableRules.NotAllowCallStackChanging, oldValueEnabled)
        {
        }

        public BindableDictionary(IDictionary<TKey, TValue> dictionary, BindableRules rule, bool oldValueEnabled)
        {
            entries = ((dictionary != null) ? new Dictionary<TKey, TValue>(dictionary) : new Dictionary<TKey, TValue>());
            Rule = rule;
            OldValueEnabled = oldValueEnabled;
            dispatcher = new EventDispatcher<DictionaryChangedEventArgs<TKey, TValue>>();
            changesPolicy = DefaultChangesPolicy;
            editType = EditType.None;
        }

        public BindableDictionary(BindableDictionary<TKey, TValue> that)
            : this(that, true)
        {
        }

        public BindableDictionary(BindableDictionary<TKey, TValue> that, bool withTakeOverHandler)
            : this(that, withTakeOverHandler, false)
        {
        }

        public BindableDictionary(BindableDictionary<TKey, TValue> that, bool withTakeOverHandler, bool withCopyItem)
        {
            if (that == null)
            {
                throw new ArgumentNullException("that");
            }

            entries = (withCopyItem ? that.ResolveCurrentEntries() : new Dictionary<TKey, TValue>(that.entries));
            Rule = that.Rule;
            OldValueEnabled = that.OldValueEnabled;
            dispatcher = (withTakeOverHandler ? new EventDispatcher<DictionaryChangedEventArgs<TKey, TValue>>(that.dispatcher) : new EventDispatcher<DictionaryChangedEventArgs<TKey, TValue>>());
            changesPolicy = that.changesPolicy;
            editType = EditType.None;
        }

        public void Bind(EventHandler<DictionaryChangedEventArgs<TKey, TValue>> handler)
        {
            dispatcher.AddHandler(handler, false);
        }

        public void Bind(object target, EventHandler<DictionaryChangedEventArgs<TKey, TValue>> handler)
        {
            dispatcher.AddHandler(target, handler, false);
        }

        public void BindOnce(EventHandler<DictionaryChangedEventArgs<TKey, TValue>> handler)
        {
            dispatcher.AddHandler(handler, true);
        }

        public void BindOnce(object target, EventHandler<DictionaryChangedEventArgs<TKey, TValue>> handler)
        {
            dispatcher.AddHandler(target, handler, true);
        }

        public bool IsBinding()
        {
            return !dispatcher.HandlerIsEmpty;
        }

        public bool IsBinding(EventHandler<DictionaryChangedEventArgs<TKey, TValue>> handler)
        {
            return dispatcher.ContainsHandler(handler, false);
        }

        public bool IsBindingOnce()
        {
            return !dispatcher.OnceHandlerIsEmpty;
        }

        public bool IsBindingOnce(EventHandler<DictionaryChangedEventArgs<TKey, TValue>> handler)
        {
            return dispatcher.ContainsHandler(handler, true);
        }

        public void UnBindAll()
        {
            dispatcher.RemoveAllHandlers();
        }

        public void UnBind(EventHandler<DictionaryChangedEventArgs<TKey, TValue>> handler)
        {
            dispatcher.RemoveHandler(handler);
        }

        public void SetChangesPolicy(Func<TValue, TValue, bool> policy)
        {
            changesPolicy = policy;
        }

        public bool IsEmpty()
        {
            return entries.Count < 1;
        }

        public bool ContainsKey(TKey key)
        {
            ValidateNotNullKey(key);
            return entries.ContainsKey(key);
        }

        public bool ContainsValue(TValue value)
        {
            return entries.ContainsValue(value);
        }

        public void ForEach(Action<TKey, TValue> iterator)
        {
            if (iterator == null)
            {
                throw new ArgumentNullException("iterator");
            }

            foreach (KeyValuePair<TKey, TValue> item in ResolveCurrentEntries())
            {
                iterator(item.Key, item.Value);
            }
        }

        public Dictionary<TKey, TValue> Filter(Func<TKey, TValue, bool> match)
        {
            Dictionary<TKey, TValue> result = new Dictionary<TKey, TValue>();
            ForEach(delegate (TKey key, TValue value)
            {
                if (match(key, value))
                {
                    result.Add(key, value);
                }
            });
            return result;
        }

        public List<TKey> MatchKeys(Func<TKey, TValue, bool> match)
        {
            if (match == null)
            {
                throw new ArgumentNullException("match");
            }

            return new List<TKey>(Filter(match).Keys);
        }

        public void Add(TKey key, TValue value)
        {
            ValidateNotNullKey(key);
            ValidateCallStackChanging();
            ValidateNotEditting();
            Dictionary<TKey, TValue> oldValue = ResolveCurrentEntriesIfNeeded();
            entries.Add(key, value);
            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.Add(key, oldValue));
            }
        }

        public void Add(IDictionary<TKey, TValue> dictionary)
        {
            if (dictionary == null)
            {
                throw new ArgumentNullException("dictionary");
            }

            ValidateCallStackChanging();
            ValidateNotEditting();
            Dictionary<TKey, TValue> oldValue = ResolveCurrentEntriesIfNeeded();
            List<TKey> keys = new List<TKey>(dictionary.Keys);
            foreach (KeyValuePair<TKey, TValue> item in dictionary)
            {
                entries.Add(item.Key, item.Value);
            }

            if (keys.Count >= 1 && IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.Add(keys, oldValue));
            }
        }

        public void Update(TKey key, TValue value)
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            TValue before = ResolveCurrentValue(key);
            Dictionary<TKey, TValue> oldValue = ResolveCurrentEntriesIfNeeded();
            entries[key] = value;
            if (AreDifferByChangesPolicy(before, value) && IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.Update(key, oldValue));
            }
        }

        public void Update(TKey key, Action<TValue> updater)
        {
            Update(key, delegate (TValue value)
            {
                updater(value);
                return value;
            });
        }

        public void Update(TKey key, Func<TValue, TValue> updater)
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            TValue forUpdate = ResolveCurrentValue(key);
            Dictionary<TKey, TValue> oldValue = ResolveCurrentEntriesIfNeeded();
            TValue before = entries[key];
            if (EditSection(EditType.Update, delegate
            {
                TValue updated = updater(forUpdate);
                entries[key] = updated;
                return AreDifferByChangesPolicy(before, updated);
            }) && IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.Update(key, oldValue));
            }
        }

        public void UpdateAll(Func<TKey, TValue, bool> match, Func<TValue, TValue> updater)
        {
            if (match == null)
            {
                throw new ArgumentNullException("match");
            }

            if (updater == null)
            {
                throw new ArgumentNullException("updater");
            }

            ValidateCallStackChanging();
            ValidateNotEditting();
            Dictionary<TKey, TValue> oldValue = ResolveCurrentEntriesIfNeeded();
            List<TKey> changes = null;
            if (EditSection(EditType.Update, delegate
            {
                changes = MatchKeys(delegate (TKey key, TValue value)
                {
                    if (!match(key, value))
                    {
                        return false;
                    }

                    TValue updated = updater(value);
                    entries[key] = updated;
                    return AreDifferByChangesPolicy(value, updated);
                });
                return changes.Count > 0;
            }) && IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.Update(changes, oldValue));
            }
        }

        public void Edit(IDictionary<TKey, TValue> alternate)
        {
            Edit(delegate (IDictionary<TKey, TValue> dictionary)
            {
                return alternate;
            });
        }

        public void Edit(Action<IDictionary<TKey, TValue>> editor)
        {
            Edit(delegate (IDictionary<TKey, TValue> dictionary)
            {
                editor(dictionary);
                return dictionary;
            });
        }

        public void Edit(Func<IDictionary<TKey, TValue>, IDictionary<TKey, TValue>> editor)
        {
            ValidateCallStackChanging();
            Dictionary<TKey, TValue> oldValue = ResolveCurrentEntriesIfNeeded();
            Dictionary<TKey, TValue> forEdit = ResolveCurrentEntries();
            if (EditSection(EditType.Edit, delegate
            {
                IDictionary<TKey, TValue> edited = editor(forEdit);
                if (edited == null)
                {
                    return false;
                }

                entries = new Dictionary<TKey, TValue>(edited);
                return true;
            }) && IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.Edit(oldValue));
            }
        }

        public void ForceUpdate()
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.ForceUpdate(ResolveCurrentEntriesIfNeeded()));
            }
        }

        public bool Remove(TKey key, TKey[] more)
        {
            ValidateNotNullKey(key);
            ValidateCallStackChanging();
            ValidateNotEditting();
            Dictionary<TKey, TValue> oldValue = ResolveCurrentEntriesIfNeeded();
            List<TKey> keys = new List<TKey>();
            keys.Add(key);
            if (more != null && more.Length != 0)
            {
                keys.AddRange(more);
            }

            List<TKey> removed = new List<TKey>();
            foreach (TKey item in keys)
            {
                if (entries.Remove(item))
                {
                    removed.Add(item);
                }
            }

            if (removed.Count < 1)
            {
                return false;
            }

            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.Remove(removed, oldValue));
            }

            return true;
        }

        public bool Remove(Func<TKey, TValue, bool> match)
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            Dictionary<TKey, TValue> oldValue = ResolveCurrentEntriesIfNeeded();
            List<TKey> removed = MatchKeys(delegate (TKey key, TValue value)
            {
                return match(key, value) && entries.Remove(key);
            });
            if (removed.Count < 1)
            {
                return false;
            }

            if (IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.Remove(removed, oldValue));
            }

            return true;
        }

        public void Clear()
        {
            ValidateCallStackChanging();
            ValidateNotEditting();
            Dictionary<TKey, TValue> oldValue = ResolveCurrentEntriesIfNeeded();
            List<TKey> keys = new List<TKey>(entries.Keys);
            entries.Clear();
            if (keys.Count >= 1 && IsDispatchable())
            {
                dispatcher.Dispatch(this, DictionaryChangedEventArgs<TKey, TValue>.Remove(keys, oldValue));
            }
        }

        protected virtual void ValidateContainsKey(TKey key)
        {
            ValidateNotNullKey(key);
            if (!entries.ContainsKey(key))
            {
                throw new KeyNotFoundException();
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

        protected virtual void ValidateNotEditting()
        {
            if (Editting)
            {
                throw new InvalidOperationException(string.Format("Still Editting. type: {0}", editType));
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

        protected bool AreDifferByChangesPolicy(TValue before, TValue after)
        {
            if (changesPolicy != null)
            {
                return changesPolicy(before, after);
            }

            return true;
        }

        protected virtual Dictionary<TKey, TValue> ResolveCurrentEntriesIfNeeded()
        {
            if (!IsDispatchable())
            {
                return entries;
            }

            if (!OldValueEnabled)
            {
                return entries;
            }

            return ResolveCurrentEntries();
        }

        protected virtual Dictionary<TKey, TValue> ResolveCurrentEntries()
        {
            if (entries.Count < 1)
            {
                return new Dictionary<TKey, TValue>(entries);
            }

            Dictionary<TKey, TValue> result = new Dictionary<TKey, TValue>();
            foreach (KeyValuePair<TKey, TValue> item in entries)
            {
                TValue value = item.Value;
                if (value is ICloneable cloneable)
                {
                    value = (TValue)cloneable.Clone();
                }

                result.Add(item.Key, value);
            }

            return result;
        }

        protected virtual TValue ResolveCurrentValue(TKey key)
        {
            ValidateContainsKey(key);
            TValue value = entries[key];
            if (value is ICloneable cloneable)
            {
                return (TValue)cloneable.Clone();
            }

            return value;
        }

        protected virtual void SetEntry(TKey key, TValue value)
        {
            if (ContainsKey(key))
            {
                Update(key, value);
            }
            else
            {
                Add(key, value);
            }
        }

        protected virtual bool EditSection(EditType type, Func<bool> section)
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

        void ICollection<KeyValuePair<TKey, TValue>>.Add(KeyValuePair<TKey, TValue> item)
        {
            Add(item.Key, item.Value);
        }

        void IDictionary.Add(object key, object value)
        {
            ValidateObjectEnableAsKey(key);
            ValidateObjectEnableAsValue(value);
            Add((TKey)key, (TValue)value);
        }

        void IDictionary<TKey, TValue>.Add(TKey key, TValue value)
        {
            Add(key, value);
        }

        void IDictionary.Clear()
        {
            Clear();
        }

        void ICollection<KeyValuePair<TKey, TValue>>.Clear()
        {
            Clear();
        }

        bool IDictionary.Contains(object key)
        {
            ValidateObjectEnableAsKey(key);
            return ContainsKey((TKey)key);
        }

        bool ICollection<KeyValuePair<TKey, TValue>>.Contains(KeyValuePair<TKey, TValue> item)
        {
            return ((ICollection<KeyValuePair<TKey, TValue>>)entries).Contains(item);
        }

        bool IDictionary<TKey, TValue>.ContainsKey(TKey key)
        {
            return ContainsKey(key);
        }

        void ICollection.CopyTo(Array array, int index)
        {
            ((ICollection)entries).CopyTo(array, index);
        }

        void ICollection<KeyValuePair<TKey, TValue>>.CopyTo(KeyValuePair<TKey, TValue>[] array, int index)
        {
            ((ICollection<KeyValuePair<TKey, TValue>>)entries).CopyTo(array, index);
        }

        public Dictionary<TKey, TValue>.Enumerator GetEnumerator()
        {
            return entries.GetEnumerator();
        }

        IDictionaryEnumerator IDictionary.GetEnumerator()
        {
            return ((IDictionary)entries).GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return entries.GetEnumerator();
        }

        IEnumerator<KeyValuePair<TKey, TValue>> IEnumerable<KeyValuePair<TKey, TValue>>.GetEnumerator()
        {
            return entries.GetEnumerator();
        }

        bool ICollection<KeyValuePair<TKey, TValue>>.Remove(KeyValuePair<TKey, TValue> item)
        {
            return Remove(item.Key, Array.Empty<TKey>());
        }

        void IDictionary.Remove(object key)
        {
            ValidateObjectEnableAsKey(key);
            Remove((TKey)key, Array.Empty<TKey>());
        }

        bool IDictionary<TKey, TValue>.Remove(TKey key)
        {
            return Remove(key, Array.Empty<TKey>());
        }

        bool IDictionary<TKey, TValue>.TryGetValue(TKey key, out TValue value)
        {
            return entries.TryGetValue(key, out value);
        }

        static BindableDictionary()
        {
        }
    }
}
