// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.PlayerPrefsChangedEventArgs
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
    public class PlayerPrefsChangedEventArgs : EventArgs
    {
        public PlayerPrefsChangedEventKind Kind { get; private set; }
        public string Key { get; private set; }
        public Type ValueType { get; private set; }
        public int OldIntValue { get; private set; }
        public int NewIntValue { get; private set; }
        public float OldFloatValue { get; private set; }
        public float NewFloatValue { get; private set; }
        public string OldStringValue { get; private set; }
        public string NewStringValue { get; private set; }


















        // RVA: 0x1E9F77C
        public static PlayerPrefsChangedEventArgs Update(string key, int oldValue, int newValue)
        {
                        return new PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind.Update, key, oldValue, newValue);
        }

        // RVA: 0x1E9F8CC
        public static PlayerPrefsChangedEventArgs Update(string key, float oldValue, float newValue)
        {
                        return new PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind.Update, key, oldValue, newValue);
        }

        // RVA: 0x1E9FA1C
        public static PlayerPrefsChangedEventArgs Update(string key, string oldValue, string newValue)
        {
                        return new PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind.Update, key, oldValue, newValue);
        }

        // RVA: 0x1E9FB6C
        public static PlayerPrefsChangedEventArgs Delete(string key)
        {
                        return new PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind.Delete, key);
        }

        // RVA: 0x1E9FC90
        public static PlayerPrefsChangedEventArgs Delete(string key, int oldValue)
        {
                        return new PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind.Delete, key, oldValue, 0);
        }

        // RVA: 0x1E9FD08
        public static PlayerPrefsChangedEventArgs Delete(string key, float oldValue)
        {
                        return new PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind.Delete, key, oldValue, 0f);
        }

        // RVA: 0x1E9FD80
        public static PlayerPrefsChangedEventArgs Delete(string key, string oldValue)
        {
                        return new PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind.Delete, key, oldValue, null);
        }

        // RVA: 0x1E9FE00
        public static PlayerPrefsChangedEventArgs DeleteAll()
        {
                        return new PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind.DeleteAll);
        }

        // RVA: 0x1E9FE5C
        private PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind kind)
        {
                        Kind = kind;
                        ValueType = typeof(void);
        }

        // RVA: 0x1E9FBD0
        private PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind kind, string key)
        {
                        Kind = kind;
                        Key = key;
                        ValueType = typeof(void);
        }

        // RVA: 0x1E9F7F8
        private PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind kind, string key, int oldValue, int newValue)
        {
                        Kind = kind;
                        Key = key;
                        ValueType = typeof(int);
                        OldIntValue = oldValue;
                        NewIntValue = newValue;
        }

        // RVA: 0x1E9F948
        private PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind kind, string key, float oldValue, float newValue)
        {
                        Kind = kind;
                        Key = key;
                        ValueType = typeof(float);
                        OldFloatValue = oldValue;
                        NewFloatValue = newValue;
        }

        // RVA: 0x1E9FA98
        private PlayerPrefsChangedEventArgs(PlayerPrefsChangedEventKind kind, string key, string oldValue, string newValue)
        {
                        Kind = kind;
                        Key = key;
                        ValueType = typeof(string);
                        OldStringValue = oldValue;
                        NewStringValue = newValue;
        }
    }
}
