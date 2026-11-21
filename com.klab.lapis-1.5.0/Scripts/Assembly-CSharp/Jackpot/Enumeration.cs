// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Enumeration
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot
{
    public abstract class Enumeration : IComparable
    {
        protected const string EnumerationsCacheKey = "Jackpot.Enumeration.ValuesCache";
        protected const string DefaultValueCacheKey = "Jackpot.Enumeration.DefaultValueCache";
        private const string NameComposite = "(Composite)";
        private readonly int value;
        private readonly string name;
        private readonly bool isDefault;
        public int Value { get { return value; } }
        public string Name { get { return name; } }
        public bool IsDefault { get { return isDefault; } }
        // RVA: 0x19E7628
        protected Enumeration(int value, string name)
        {
            this.value = value;
            this.name = name;
            isDefault = false;
        }

        // RVA: 0x19E7668
        protected Enumeration(int value, string name, bool isDefault)
        {
            this.value = value;
            this.name = name;
            this.isDefault = isDefault;
        }

        public static List<TEnum> Of<TEnum>(TEnum enumeration, TEnum[] moreEnumerations)
        {
            List<TEnum> list = new List<TEnum>();
            ListExtensions.AddUnique(list, enumeration, moreEnumerations);
            return list;
        }

        public static List<TEnum> All<TEnum>()
        {
            IMemory memory = Cache(EnumerationsCacheKey);
            string key = typeof(TEnum).FullName;
            if (!memory.Contains(key))
            {
                FieldInfo[] fields = typeof(TEnum).GetFields(BindingFlags.Public | BindingFlags.Static | BindingFlags.DeclaredOnly);
                List<TEnum> list = new List<TEnum>();
                for (int i = 0; i < fields.Length; i++)
                {
                    list.Add((TEnum)fields[i].GetValue(null));
                }

                memory.Set<List<TEnum>>(key, list);
            }

            return memory.Get<List<TEnum>>(key);
        }

        public static TEnum FromValue<TEnum>(int value)
        {
            return FromValue(value, Default<TEnum>());
        }

        public static TEnum FromValue<TEnum>(int value, TEnum defaultValue)
        {
            return Parse((TEnum enumeration) => enumeration.Value == value, defaultValue);
        }

        public static TEnum FromValueStrictly<TEnum>(int value)
        {
            foreach (TEnum item in All<TEnum>())
            {
                if (item.Value == value)
                {
                    return item;
                }
            }

            throw new ArgumentException(string.Format("Failed to parse {0}. The value was {1}", typeof(TEnum).FullName, value));
        }

        public static TEnum FromValue<TEnum, TValue>(TValue value)
        {
            return FromValue(value, Default<TEnum>());
        }

        public static TEnum FromValue<TEnum, TValue>(TValue value, TEnum defaultValue)
        {
            return FromValue(value, defaultValue, (TValue a, TValue b) => EqualityComparer<TValue>.Default.Equals(a, b));
        }

        public static TEnum FromValue<TEnum, TValue>(TValue value, TEnum defaultValue, Func<TValue, TValue, bool> equalityComparer)
        {
            return Parse((TEnum enumeration) => equalityComparer(value, enumeration.Value), defaultValue);
        }

        public static TEnum FromValueStrictly<TEnum, TValue>(TValue value)
        {
            return FromValueStrictly(value, (TValue a, TValue b) => a != null && a.Equals(b));
        }

        public static TEnum FromValueStrictly<TEnum, TValue>(TValue value, Func<TValue, TValue, bool> equalityComparer)
        {
            foreach (TEnum item in All<TEnum>())
            {
                if (equalityComparer(value, item.Value))
                {
                    return item;
                }
            }

            throw new ArgumentException(string.Format("Failed to parse {0}. The value was {1}", typeof(TEnum).FullName, value));
        }

        public static TEnum FromName<TEnum>(string name)
        {
            return FromName(name, Default<TEnum>());
        }

        public static TEnum FromName<TEnum>(string name, TEnum defaultValue)
        {
            return Parse((TEnum enumeration) => name == enumeration.Name, defaultValue);
        }

        public static TEnum FromNameStrictly<TEnum>(string name)
        {
            foreach (TEnum item in All<TEnum>())
            {
                if (name == item.Name)
                {
                    return item;
                }
            }

            throw new ArgumentException(string.Format("Failed to parse {0}. The name was {1}", typeof(TEnum).FullName, name));
        }

        protected static TEnum Parse<TEnum>(Predicate<TEnum> predicate, TEnum defaultValue)
        {
            foreach (TEnum item in All<TEnum>())
            {
                if (predicate(item))
                {
                    return item;
                }
            }

            return defaultValue;
        }

        protected static TEnum Default<TEnum>()
        {
            IMemory memory = Cache(DefaultValueCacheKey);
            string key = typeof(TEnum).FullName;
            if (!memory.Contains(key))
            {
                TEnum val = default(TEnum);
                foreach (TEnum item in All<TEnum>())
                {
                    if (item.IsDefault)
                    {
                        val = item;
                        break;
                    }
                }

                if (val != null)
                {
                    memory.Set<TEnum>(key, val);
                }
            }

            return memory.Get<TEnum>(key);
        }

        // RVA: 0x19E76B0
        protected static IMemory Cache(string cacheKey)
        {
                        ApplicationCache instance = ApplicationCache.Instance;
                        if (!instance.Contains(cacheKey))
                        {
                            instance.Set(cacheKey, new Memory());
                        }

                        return instance.Get<Memory>(cacheKey);
        }

        // RVA: 0x19E7834
        public bool IsAnyOf(Enumeration enumeration, Enumeration[] moreEnumerations)
        {
                        if (enumeration != null && Equals(enumeration))
                        {
                            return true;
                        }

                        if (moreEnumerations == null)
                        {
                            return false;
                        }

                        for (int i = 0; i < moreEnumerations.Length; i++)
                        {
                            if (moreEnumerations[i] != null && Equals(moreEnumerations[i]))
                            {
                                return true;
                            }
                        }

                        return false;
        }

        // RVA: 0x19E78E0
        public override bool Equals(object that)
        {
                        if (this == that)
                        {
                            return true;
                        }

                        if (!(that is Enumeration))
                        {
                            return false;
                        }

                        int num = value;
                        if (num.Equals(((Enumeration)that).value))
                        {
                            return GetType().Equals(that.GetType());
                        }

                        return false;
        }

        // RVA: 0x19E79E4
        public virtual int CompareTo(object that)
        {
                        if (this == that)
                        {
                            return 0;
                        }

                        if (!(that is Enumeration))
                        {
                            return 1;
                        }

                        return value.CompareTo(((Enumeration)that).value);
        }

        // RVA: 0x19E7AA8
        public override int GetHashCode()
        {
                        return value.GetHashCode();
        }

        // RVA: 0x19E7AD4
        public override string ToString()
        {
                        return name;
        }

        // RVA: 0x19E7ADC
        public static int op_Implicit(Enumeration enumeration)
        {
                        return enumeration.value;
        }
    }
}
