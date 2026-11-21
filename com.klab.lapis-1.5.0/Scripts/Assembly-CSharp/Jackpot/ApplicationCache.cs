// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.ApplicationCache
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

namespace Jackpot
{
    public class ApplicationCache : MonoBehaviour, IMemory
    {
        private static ApplicationCache instance;
        private static readonly object lifecycleLock;
        private static bool isAlive;
        private IMemory memory;
        public static ApplicationCache Instance { get { return instance; } }
        public static bool IsAlive { get { return isAlive; } }

        // RVA: 0x176C868
        private void OnDestroy()
        {
                        lock (lifecycleLock)
                        {
                            instance = null;
                            isAlive = false;
                        }
        }

        public TValue Get<TValue>(string key)
        {
            return memory.Get<TValue>(key);
        }

        public TValue Get<TValue>(string key, TValue defaultValue)
        {
            return memory.Get<TValue>(key, defaultValue);
        }

        public bool TryGet<TValue>(string key, out TValue value)
        {
            return memory.TryGet<TValue>(key, out value);
        }

        // RVA: 0x176C964
        public bool Contains(string key)
        {
                        return memory.Contains(key);
        }

        // RVA: 0x176CA28
        public bool ContainsKey(string key)
        {
                        return memory.ContainsKey(key);
        }

        public void Set<TValue>(string key, TValue value)
        {
            memory.Set<TValue>(key, value);
        }

        // RVA: 0x176CAEC
        public void Remove(string key)
        {
                        memory.Remove(key);
        }

        // RVA: 0x176CBB0
        public void RemoveAll()
        {
                        memory.RemoveAll();
        }

        // RVA: 0x176CC64
        public ApplicationCache()
        {
        }

        // RVA: 0x176CC6C
        static ApplicationCache()
        {
                        lifecycleLock = new object();
        }
    }
}
