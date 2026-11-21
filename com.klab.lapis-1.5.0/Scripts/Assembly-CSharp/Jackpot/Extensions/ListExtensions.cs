// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Extensions.ListExtensions
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
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

namespace Jackpot.Extensions
{
    public static class ListExtensions
    {

        [Extension]
        public static bool IsEmpty<T>(List<T> self)
        {
            return self.Count == 0;
        }

        [Extension]
        public static int CountBy<T>(List<T> self, Predicate<T> match)
        {
            int num = 0;
            for (int i = 0; i < self.Count; i++)
            {
                if (match(self[i]))
                {
                    num++;
                }
            }

            return num;
        }

        [Extension]
        public static List<int> FindAllIndex<T>(List<T> self, Predicate<T> match)
        {
            List<int> list = new List<int>();
            for (int i = 0; i < self.Count; i++)
            {
                if (match(self[i]))
                {
                    list.Add(i);
                }
            }

            return list;
        }

        [Extension]
        public static Tuple<List<int>, List<T>> FindAllIndexAndItem<T>(List<T> self, Predicate<T> match)
        {
            List<int> list = new List<int>();
            List<T> list2 = new List<T>();
            for (int i = 0; i < self.Count; i++)
            {
                T val = self[i];
                if (match(val))
                {
                    list.Add(i);
                    list2.Add(val);
                }
            }

            return Tuple.Create(list, list2);
        }

        [Extension]
        public static void AddUnique<T>(List<T> self, T item, T[] moreItems)
        {
            Action<T> action = delegate(T i)
            {
                if (!self.Contains(i))
                {
                    self.Add(i);
                }
            };
            action(item);
            if (moreItems == null)
            {
                return;
            }

            for (int j = 0; j < moreItems.Length; j++)
            {
                action(moreItems[j]);
            }
        }

        [Extension]
        public static bool Contains<T>(List<T> self, Predicate<T> predicate)
        {
            for (int i = 0; i < self.Count; i++)
            {
                if (predicate(self[i]))
                {
                    return true;
                }
            }

            return false;
        }

        [Extension]
        public static List<T> Filter<T>(List<T> self, Predicate<T> predicate)
        {
            List<T> list = new List<T>();
            for (int i = 0; i < self.Count; i++)
            {
                T val = self[i];
                if (predicate(val))
                {
                    list.Add(val);
                }
            }

            return list;
        }

        [Extension]
        public static List<T> Reject<T>(List<T> self, Predicate<T> predicate)
        {
            List<T> list = new List<T>();
            for (int i = 0; i < self.Count; i++)
            {
                T val = self[i];
                if (!predicate(val))
                {
                    list.Add(val);
                }
            }

            return list;
        }

        [Extension]
        public static List<T> RejectNull<T>(List<T> self)
        {
            return Filter(self, (T item) => item != null);
        }

        [Extension]
        public static List<U> Map<T, U>(List<T> self, Func<T, U> callback)
        {
            List<U> list = new List<U>();
            for (int i = 0; i < self.Count; i++)
            {
                list.Add(callback(self[i]));
            }

            return list;
        }

        [Extension]
        public static List<U> Map<T, U>(List<T> self, Func<int, T, U> callback)
        {
            List<U> list = new List<U>();
            for (int i = 0; i < self.Count; i++)
            {
                list.Add(callback(i, self[i]));
            }

            return list;
        }

        [Extension]
        public static List<U> FlatMap<T, U>(List<T> self, Func<T, IEnumerable<U>> callback)
        {
            List<U> list = new List<U>();
            for (int i = 0; i < self.Count; i++)
            {
                list.AddRange(callback(self[i]));
            }

            return list;
        }

        [Extension]
        public static List<U> FlatMap<T, U>(List<T> self, Func<int, T, IEnumerable<U>> callback)
        {
            List<U> list = new List<U>();
            for (int i = 0; i < self.Count; i++)
            {
                list.AddRange(callback(i, self[i]));
            }

            return list;
        }
    }
}
