// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.IMemory
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
    public interface IMemory
    {
        public abstract TValue Get<TValue>(string key);
        public abstract TValue Get<TValue>(string key, TValue defaultValue);
        public abstract bool TryGet<TValue>(string key, out TValue value);
        public abstract bool Contains(string key);
        public abstract bool ContainsKey(string key);
        public abstract void Set<TValue>(string key, TValue value);
        public abstract void Remove(string key);
        public abstract void RemoveAll();
    }
}
