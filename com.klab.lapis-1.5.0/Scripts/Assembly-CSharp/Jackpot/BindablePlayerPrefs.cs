// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.BindablePlayerPrefs
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
    public sealed class BindablePlayerPrefs
    {
        public static readonly float defaultTolerance;
        private static EventDispatcher<PlayerPrefsChangedEventArgs> dispatcher;
        private static Func<int, int, bool> intValueChangesPolicy;
        private static Func<float, float, bool> floatValueChangesPolicy;
        private static Func<string, string, bool> stringValueChangesPolicy;
        private static float tolerance;
        public static BindableRules Rule { get; set; }
        // RVA: 0x1785550
        public static bool DefaultIntValueChangesPolicy(int oldValue, int newValue)
        {
                        return oldValue != newValue;
        }

        // RVA: 0x178555C
        public static bool DefaultFloatValueChangesPolicy(float oldValue, float newValue)
        {
                        return !IsNearlyEquals(oldValue, newValue);
        }

        // RVA: 0x1785688
        public static bool DefaultStringValueChangesPolicy(string oldValue, string newValue)
        {
                        return oldValue != newValue;
        }



        // RVA: 0x1785764
        public static void Bind(EventHandler<PlayerPrefsChangedEventArgs> handler)
        {
                        dispatcher.AddHandler(handler, false);
        }

        // RVA: 0x17857EC
        public static void Bind(object target, EventHandler<PlayerPrefsChangedEventArgs> handler)
        {
                        dispatcher.AddHandler(target, handler, false);
        }

        // RVA: 0x1785884
        public static void BindOnce(EventHandler<PlayerPrefsChangedEventArgs> handler)
        {
                        dispatcher.AddHandler(handler, true);
        }

        // RVA: 0x178590C
        public static void BindOnce(object target, EventHandler<PlayerPrefsChangedEventArgs> handler)
        {
                        dispatcher.AddHandler(target, handler, true);
        }

        // RVA: 0x17859A4
        public static bool IsBinding()
        {
                        return !dispatcher.HandlerIsEmpty;
        }

        // RVA: 0x1785A2C
        public static bool IsBinding(EventHandler<PlayerPrefsChangedEventArgs> handler)
        {
                        return dispatcher.ContainsHandler(handler, false);
        }

        // RVA: 0x1785AB4
        public static bool IsBindingOnce()
        {
                        return !dispatcher.OnceHandlerIsEmpty;
        }

        // RVA: 0x1785B3C
        public static bool IsBindingOnce(EventHandler<PlayerPrefsChangedEventArgs> handler)
        {
                        return dispatcher.ContainsHandler(handler, true);
        }

        // RVA: 0x1785BC4
        public static void UnBind(EventHandler<PlayerPrefsChangedEventArgs> handler)
        {
                        dispatcher.RemoveHandler(handler);
        }

        // RVA: 0x1785C48
        public static void UnBindAll()
        {
                        dispatcher.RemoveAllHandlers();
        }

        // RVA: 0x1785CC4
        public static void SetIntValueChangesPolicy(Func<int, int, bool> policy)
        {
                        intValueChangesPolicy = policy;
        }

        // RVA: 0x1785D30
        public static void SetFloatValueChangesPolicy(Func<float, float, bool> policy)
        {
                        floatValueChangesPolicy = policy;
        }

        // RVA: 0x1785D9C
        public static void SetStringValueChangesPolicy(Func<string, string, bool> policy)
        {
                        stringValueChangesPolicy = policy;
        }

        // RVA: 0x1785E08
        public static void SetFloatValueTolerance(float newTolerance)
        {
                        tolerance = Math.Abs(newTolerance);
        }

        // RVA: 0x1785EA0
        public static bool HasKey(string key)
        {
                        return PlayerPrefs.HasKey(key);
        }

        // RVA: 0x1785EA8
        public static int GetInt(string key)
        {
                        return PlayerPrefs.GetInt(key);
        }

        // RVA: 0x1785EB0
        public static void SetInt(string key, int value)
        {
                        ValidateCallStackChanging();
                        ValidateKey(key);
                        ValidateValueType(key, PlayerPrefsValueType.Int);
                        int oldValue = PlayerPrefs.GetInt(key);
                        PlayerPrefs.SetInt(key, value);
                        if (intValueChangesPolicy != null && !intValueChangesPolicy(oldValue, value))
                        {
                            return;
                        }

                        if (IsDispatchable())
                        {
                            dispatcher.Dispatch(PlayerPrefsChangedEventArgs.Update(key, oldValue, value));
                        }
        }

        // RVA: 0x17864D4
        public static float GetFloat(string key)
        {
                        return PlayerPrefs.GetFloat(key);
        }

        // RVA: 0x17864DC
        public static void SetFloat(string key, float value)
        {
                        ValidateCallStackChanging();
                        ValidateKey(key);
                        ValidateValueType(key, PlayerPrefsValueType.Float);
                        float oldValue = PlayerPrefs.GetFloat(key);
                        PlayerPrefs.SetFloat(key, value);
                        if (floatValueChangesPolicy != null && !floatValueChangesPolicy(oldValue, value))
                        {
                            return;
                        }

                        if (IsDispatchable())
                        {
                            dispatcher.Dispatch(PlayerPrefsChangedEventArgs.Update(key, oldValue, value));
                        }
        }

        // RVA: 0x1786658
        public static string GetString(string key)
        {
                        return PlayerPrefs.GetString(key);
        }

        // RVA: 0x1786660
        public static void SetString(string key, string value)
        {
                        ValidateCallStackChanging();
                        ValidateKey(key);
                        ValidateValueType(key, PlayerPrefsValueType.String);
                        string oldValue = PlayerPrefs.GetString(key);
                        PlayerPrefs.SetString(key, value);
                        if (stringValueChangesPolicy != null && !stringValueChangesPolicy(oldValue, value))
                        {
                            return;
                        }

                        if (IsDispatchable())
                        {
                            dispatcher.Dispatch(PlayerPrefsChangedEventArgs.Update(key, oldValue, value));
                        }
        }

        // RVA: 0x17867DC
        public static void DeleteKey(string key)
        {
                        if (!PlayerPrefs.HasKey(key))
                        {
                            return;
                        }

                        ValidateCallStackChanging();
                        PlayerPrefsChangedEventArgs eventArgs = TryCreateRemoveEvent(key);
                        PlayerPrefs.DeleteKey(key);
                        if (IsDispatchable())
                        {
                            dispatcher.Dispatch(eventArgs);
                        }
        }

        // RVA: 0x1786A1C
        public static void DeleteAll()
        {
                        ValidateCallStackChanging();
                        PlayerPrefs.DeleteAll();
                        if (IsDispatchable())
                        {
                            dispatcher.Dispatch(PlayerPrefsChangedEventArgs.DeleteAll());
                        }
        }

        // RVA: 0x1786AE0
        public static void Save()
        {
                        PlayerPrefs.Save();
        }

        // RVA: 0x17855DC
        private static bool IsNearlyEquals(float a, float b)
        {
                        return Math.Abs(Math.Abs(a) - Math.Abs(b)) < tolerance;
        }

        // RVA: 0x178614C
        private static void ValidateKey(string key)
        {
                        if (key == null)
                        {
                            throw new ArgumentNullException("key");
                        }

                        if (string.IsNullOrEmpty(key))
                        {
                            throw new ArgumentException("key must not be empty");
                        }
        }

        // RVA: 0x178602C
        private static void ValidateCallStackChanging()
        {
                        if (Rule == BindableRules.NotAllowCallStackChanging && dispatcher.IsDispatching)
                        {
                            throw new InvalidOperationException("A value cannot be changed while dispatching data.");
                        }
        }

        // RVA: 0x1786208
        private static void ValidateValueType(string key, PlayerPrefsValueType type)
        {
                        if (!PlayerPrefs.HasKey(key))
                        {
                            return;
                        }

                        int num = PlayerPrefs.GetInt(key);
                        float num2 = PlayerPrefs.GetFloat(key);
                        string text = PlayerPrefs.GetString(key);
                        switch (type)
                        {
                            case PlayerPrefsValueType.Int:
                                if (text.Length > 0 || !IsNearlyEquals(0f, num2))
                                {
                                    throw new InvalidOperationException("Already different type value set");
                                }

                                break;
                            case PlayerPrefsValueType.Float:
                                if (num != 0 || text.Length > 0)
                                {
                                    throw new InvalidOperationException("Already different type value set");
                                }

                                break;
                            case PlayerPrefsValueType.String:
                                if (num != 0 || !IsNearlyEquals(0f, num2))
                                {
                                    throw new InvalidOperationException("Already different type value set");
                                }

                                break;
                        }
        }

        // RVA: 0x1786380
        private static bool IsDispatchable()
        {
                        if (!dispatcher.IsDispatching)
                        {
                            return true;
                        }

                        if (Rule == BindableRules.NotAllowCallStackChanging)
                        {
                            return false;
                        }

                        return Rule != BindableRules.ThroughCallStackChanging;
        }

        // RVA: 0x17868DC
        private static PlayerPrefsChangedEventArgs TryCreateRemoveEvent(string key)
        {
                        int num = PlayerPrefs.GetInt(key);
                        float num2 = PlayerPrefs.GetFloat(key);
                        string text = PlayerPrefs.GetString(key);
                        if (text.Length >= 1)
                        {
                            return PlayerPrefsChangedEventArgs.Delete(key, text);
                        }

                        if (IsNearlyEquals(0f, num2))
                        {
                            if (num != 0)
                            {
                                return PlayerPrefsChangedEventArgs.Delete(key, num);
                            }

                            return PlayerPrefsChangedEventArgs.Delete(key);
                        }

                        return PlayerPrefsChangedEventArgs.Delete(key, num2);
        }

        // RVA: 0x1786AE8
        public BindablePlayerPrefs()
        {
        }

        // RVA: 0x1786AF0
        static BindablePlayerPrefs()
        {
                        defaultTolerance = 1E-05f;
                        dispatcher = new EventDispatcher<PlayerPrefsChangedEventArgs>();
                        intValueChangesPolicy = DefaultIntValueChangesPolicy;
                        floatValueChangesPolicy = DefaultFloatValueChangesPolicy;
                        stringValueChangesPolicy = DefaultStringValueChangesPolicy;
                        tolerance = defaultTolerance;
        }
    }
}
