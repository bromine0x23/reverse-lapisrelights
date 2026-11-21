// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Platform
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
    public class Platform
    {

        // RVA: 0x1E9ED9C
        public static string GetBundleIdentifier()
        {
                        return AndroidPlatform.GetBundleIdentifier();
        }

        // RVA: 0x1E9EDA4
        public static string GetBundleVersion()
        {
                        return AndroidPlatform.GetBundleVersion();
        }

        // RVA: 0x1E9EDAC
        public static void Log(string message, string tag = "")
        {
                        AndroidPlatform.Log(message, tag);
        }

        // RVA: 0x1E9EDB4
        public static void Log(LoggerReport report)
        {
                        AndroidPlatform.Log(report);
        }

        // RVA: 0x1E9EDBC
        public static long GetDiskFreeSpace()
        {
                        return AndroidPlatform.GetDiskFreeSpace();
        }

        // RVA: 0x1E9EDC4
        public static string GetPersistentDirectoryPath(string suffix = "")
        {
                        return AndroidPlatform.GetPersistentDirectoryPath(suffix);
        }

        // RVA: 0x1E9EDCC
        public static string GetInternalPersistentDirectoryPath()
        {
                        return AndroidPlatform.GetInternalPersistentDirectoryPath();
        }

        // RVA: 0x1E9EDD4
        public static string GetExternalPersistentDirectoryPath()
        {
                        return AndroidPlatform.GetExternalPersistentDirectoryPath();
        }

        // RVA: 0x1E9EDDC
        public static string GetCacheDirectoryPath(string suffix = "")
        {
                        return AndroidPlatform.GetCacheDirectoryPath(suffix);
        }

        // RVA: 0x1E9EDE4
        public static string GetLocaleIdentifier()
        {
                        return AndroidPlatform.GetLocaleIdentifier();
        }

        // RVA: 0x1E9EDEC
        public static string GetLocaleCountryCode()
        {
                        return AndroidPlatform.GetLocaleCountryCode();
        }

        // RVA: 0x1E9EDF4
        public static string GetLocaleLanguageCode()
        {
                        return AndroidPlatform.GetLocaleLanguageCode();
        }

        // RVA: 0x1E9EDFC
        public static string GetDeviceTimeZone()
        {
                        return AndroidPlatform.GetDeviceTimeZone();
        }

        // RVA: 0x1E9EE04
        public static bool IsIos()
        {
                        return AndroidPlatform.IsIos();
        }

        // RVA: 0x1E9EE0C
        public static bool IsAndroid()
        {
                        return AndroidPlatform.IsAndroid();
        }

        // RVA: 0x1E9EE14
        public static bool IsEditor()
        {
                        return AndroidPlatform.IsEditor();
        }

        // RVA: 0x1E9EE1C
        public static Version GetOSVersion()
        {
                        return AndroidPlatform.GetOSVersion();
        }

        // RVA: 0x1E9EE24
        public static double GetUsedMemory()
        {
                        return AndroidPlatform.GetUsedMemory();
        }

        // RVA: 0x1E9EE2C
        public static double GetFreeMemory()
        {
                        return AndroidPlatform.GetFreeMemory();
        }

        // RVA: 0x1E9EE34
        public static double GetTotalMemory()
        {
                        return AndroidPlatform.GetTotalMemory();
        }

        // RVA: 0x1E9EE3C
        public static void LoadResemaraDetectionIdentifier(Action<string> onLoad)
        {
                        AndroidPlatform.LoadResemaraDetectionIdentifier(onLoad);
        }

        // RVA: 0x1E9EE44
        public static bool IsRooted()
        {
                        return AndroidPlatform.IsRooted();
        }

        // RVA: 0x1E9EE4C
        [Obsolete]
        public static bool IsDebuggerAttached()
        {
                        return AndroidPlatform.IsDebuggerAttached();
        }

        // RVA: 0x1E9EE54
        public static bool IsUsbDebuggable()
        {
                        return AndroidPlatform.IsUsbDebuggable();
        }

        // RVA: 0x1E9EE5C
        public static bool IsEmulator()
        {
                        return AndroidPlatform.IsEmulator();
        }

        // RVA: 0x1E9EE64
        public static bool IsWritable(string path)
        {
                        return AndroidPlatform.IsWritable(path);
        }

        // RVA: 0x1E9EE6C
        public static ICollection<SimpleAnalysisEntry> GetInvalidDeviceProperties()
        {
                        return AndroidPlatform.GetInvalidDeviceProperties();
        }

        // RVA: 0x1E9EE74
        public static bool SubscribeAssetStateLog()
        {
                        return AndroidPlatform.SubscribeAssetStateLog();
        }

        // RVA: 0x1E9EE7C
        public static string GenerateAssetStateLog(string seed)
        {
                        return AndroidPlatform.GenerateAssetStateLog(seed);
        }

        // RVA: 0x1E9EE84
        public static BatteryStatusKind GetBatteryStatus()
        {
                        return AndroidPlatform.GetBatteryStatus();
        }

        // RVA: 0x1E9EE8C
        public static int GetBatteryLevel()
        {
                        return AndroidPlatform.GetBatteryLevel();
        }

        // RVA: 0x1E9EE94
        public static float GetBatteryTemperature()
        {
                        return AndroidPlatform.GetBatteryTemperature();
        }

        // RVA: 0x1E9EE9C
        public static int GetBatteryVoltage()
        {
                        return AndroidPlatform.GetBatteryVoltage();
        }

        // RVA: 0x1E9EEA4
        public static bool LaunchApp(string urlScheme, string appIdOrPackageName)
        {
                        return AndroidPlatform.LaunchApp(urlScheme, appIdOrPackageName);
        }

        // RVA: 0x1E9EEAC
        public static bool StoreReview()
        {
                        return AndroidPlatform.StoreReview();
        }

        // RVA: 0x1E9EEB4
        public static int GetThermalState()
        {
                        return AndroidPlatform.GetThermalState();
        }

        // RVA: 0x1E9EEBC
        public static int GetMaximumFramesPerSecond()
        {
                        return AndroidPlatform.GetMaximumFramesPerSecond();
        }

        // RVA: 0x1E9EEC4
        public static void ShowToastMessage(string message)
        {
                        AndroidPlatform.ShowToastMessage(message);
        }

        // RVA: 0x1E9EED0
        public static void ShowToastMessage(string message, bool isLong)
        {
                        AndroidPlatform.ShowToastMessage(message, isLong);
        }

        // RVA: 0x1E9EEDC
        public static void RequestAtt()
        {
        }

        // RVA: 0x1E9EEE0
        public Platform()
        {
        }
    }
}
