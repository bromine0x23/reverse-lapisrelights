// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.DictionaryChangedEventArgs
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot
{
    public class DictionaryChangedEventArgs<TKey, TValue> : EventArgs
    {
        private Dictionary<TKey, TValue> oldValue;
        public DictionaryChangedEventKind Kind { get; private set; }
        public List<TKey> Keys { get; private set; }
        public int Count { get { return get_Count(); } }
        public Dictionary<TKey, TValue> OldValue { get { return get_OldValue(); } }




        public int get_Count()
        {
            if (KindIsAnyOf(DictionaryChangedEventKind.ForceUpdate, new DictionaryChangedEventKind[1] { DictionaryChangedEventKind.Edit }))
            {
                return -1;
            }

            return Keys.Count;
        }

        public Dictionary<TKey, TValue> get_OldValue()
        {
            if (oldValue == null)
            {
                throw new InvalidOperationException("Missing OldValue. Did you set BindableDictionary`1 OldValueEnabled to true?");
            }

            return oldValue;
        }

        public static DictionaryChangedEventArgs<TKey, TValue> ForceUpdate(Dictionary<TKey, TValue> oldValue)
        {
            return new DictionaryChangedEventArgs<TKey, TValue>(DictionaryChangedEventKind.ForceUpdate, null, oldValue);
        }

        public static DictionaryChangedEventArgs<TKey, TValue> Update(TKey key, Dictionary<TKey, TValue> oldValue)
        {
            return new DictionaryChangedEventArgs<TKey, TValue>(DictionaryChangedEventKind.Update, new List<TKey> { key }, oldValue);
        }

        public static DictionaryChangedEventArgs<TKey, TValue> Update(List<TKey> keys, Dictionary<TKey, TValue> oldValue)
        {
            return new DictionaryChangedEventArgs<TKey, TValue>(DictionaryChangedEventKind.Update, keys, oldValue);
        }

        public static DictionaryChangedEventArgs<TKey, TValue> Add(TKey key, Dictionary<TKey, TValue> oldValue)
        {
            return new DictionaryChangedEventArgs<TKey, TValue>(DictionaryChangedEventKind.Add, new List<TKey> { key }, oldValue);
        }

        public static DictionaryChangedEventArgs<TKey, TValue> Add(List<TKey> keys, Dictionary<TKey, TValue> oldValue)
        {
            return new DictionaryChangedEventArgs<TKey, TValue>(DictionaryChangedEventKind.Add, keys, oldValue);
        }

        public static DictionaryChangedEventArgs<TKey, TValue> Remove(TKey key, Dictionary<TKey, TValue> oldValue)
        {
            return new DictionaryChangedEventArgs<TKey, TValue>(DictionaryChangedEventKind.Remove, new List<TKey> { key }, oldValue);
        }

        public static DictionaryChangedEventArgs<TKey, TValue> Remove(List<TKey> keys, Dictionary<TKey, TValue> oldValue)
        {
            return new DictionaryChangedEventArgs<TKey, TValue>(DictionaryChangedEventKind.Remove, keys, oldValue);
        }

        public static DictionaryChangedEventArgs<TKey, TValue> Edit(Dictionary<TKey, TValue> oldValue)
        {
            return new DictionaryChangedEventArgs<TKey, TValue>(DictionaryChangedEventKind.Edit, null, oldValue);
        }

        private DictionaryChangedEventArgs(DictionaryChangedEventKind kind, List<TKey> keys, Dictionary<TKey, TValue> oldValue)
        {
            Kind = kind;
            Keys = keys;
            this.oldValue = oldValue;
        }

        public bool KindIsAnyOf(DictionaryChangedEventKind kind, DictionaryChangedEventKind[] more)
        {
            if (Kind == kind)
            {
                return true;
            }

            if (more == null)
            {
                return false;
            }

            for (int i = 0; i < more.Length; i++)
            {
                if (Kind == more[i])
                {
                    return true;
                }
            }

            return false;
        }
    }
}
