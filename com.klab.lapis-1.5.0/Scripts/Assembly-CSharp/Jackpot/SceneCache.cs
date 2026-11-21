// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.SceneCache
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
    public class SceneCache : MonoBehaviour, IMemory
    {
        private static readonly object lifecycleLock;
        private static SceneCache instance;
        private static bool isAlive;
        private IMemory memory;
        public static IMemory Instance { get { return instance; } }
        public static bool IsAlive { get { return isAlive; } }

        // RVA: 0x1EA12C8
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

        // RVA: 0x1EA13C0
        public bool Contains(string key)
        {
                        return memory.Contains(key);
        }

        // RVA: 0x1EA1484
        public bool ContainsKey(string key)
        {
                        return memory.ContainsKey(key);
        }

        public void Set<TValue>(string key, TValue value)
        {
            memory.Set<TValue>(key, value);
        }

        // RVA: 0x1EA1548
        public void Remove(string key)
        {
                        memory.Remove(key);
        }

        // RVA: 0x1EA160C
        public void RemoveAll()
        {
                        memory.RemoveAll();
        }

        // RVA: 0x1EA16C0
        public SceneCache()
        {
        }

        // RVA: 0x1EA16C8
        static SceneCache()
        {
                        lifecycleLock = new object();
        }
    }
}
