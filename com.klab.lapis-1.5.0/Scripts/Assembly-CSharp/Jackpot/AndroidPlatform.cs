// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.AndroidPlatform
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Text;
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
    internal class AndroidPlatform
    {
        private static AndroidJavaObject resemaraObject;
        private static AndroidJavaClass bridge;
        private const string BundleIdentifierKey = "Jackpot.Android.BundleIdentifier";
        private const string BundleVersionKey = "Jackpot.Android.BundleVersion";
        private const string PersistentDirectoryPathKey = "Jackpot.Android.PersistentDirectoryPath";
        private const string InternalPersistentDirectoryPathKey = "Jackpot.Android.InternalPersistentDirectoryPath";
        private const string ExternalPersistentDirectoryPathKey = "Jackpot.Android.ExternalPersistentDirectoryPath";
        private const string CacheDirectoryPathKey = "Jackpot.Android.CacheDirectoryPath";

        // RVA: 0x1764974
        [DllImport("__Internal", CallingConvention = CallingConvention.Cdecl)]
        private static extern bool _KJACore_AssetStateLogAvailable();

        // RVA: 0x17649F0
        [DllImport("__Internal", CallingConvention = CallingConvention.Cdecl)]
        private static extern void _KJACore_AssetStateLogSubscribe(out bool output, out bool err);

        // RVA: 0x1764AA8
        [DllImport("__Internal", CallingConvention = CallingConvention.Cdecl)]
        private static extern void _KJACore_AssetStateLogGenerate(StringBuilder buf, int bufsize, string seed);

        // RVA: 0x1764B7C
        [DllImport("__Internal", CallingConvention = CallingConvention.Cdecl)]
        private static extern void _KJACore_AssetStateLogGenerateV2(StringBuilder buf, int bufsize, string seed);

        // RVA: 0x1764C50
        public static string GetBundleIdentifier()
        {
                        string text = ApplicationCache.Instance.Get<string>(BundleIdentifierKey, string.Empty);
                        if (string.IsNullOrEmpty(text))
                        {
                            MainThreadDispatcher.SendAndWait(delegate
                            {
                                AndroidUtility.UsingPackageInfo(delegate(AndroidJavaObject packageInfo)
                                {
                                    text = packageInfo.Get<string>("packageName");
                                });
                                ApplicationCache.Instance.Set<string>(BundleIdentifierKey, text);
                            });
                        }

                        return text;
        }

        // RVA: 0x1764F80
        public static string GetBundleVersion()
        {
                        string text = ApplicationCache.Instance.Get<string>(BundleVersionKey, string.Empty);
                        if (string.IsNullOrEmpty(text))
                        {
                            MainThreadDispatcher.SendAndWait(delegate
                            {
                                AndroidUtility.UsingPackageInfo(delegate(AndroidJavaObject packageInfo)
                                {
                                    text = packageInfo.Get<string>("versionName");
                                });
                                ApplicationCache.Instance.Set<string>(BundleVersionKey, text);
                            });
                        }

                        return text;
        }

        // RVA: 0x17650AC
        public static void Log(string message, string tag = "")
        {
                        if (string.IsNullOrEmpty(tag))
                        {
                            tag = GetBundleIdentifier();
                        }

                        UsingLog(delegate(AndroidJavaClass log)
                        {
                            log.CallStatic<int>("d", tag, message);
                        });
        }

        // RVA: 0x1765244
        public static void Log(LoggerReport report)
        {
                        UsingLog(delegate(AndroidJavaClass log)
                        {
                            log.CallStatic<int>("d", report.CallerName, report.ToString());
                        });
        }

        // RVA: 0x17652FC
        public static long GetDiskFreeSpace()
        {
                        long diskFreeSpace = 0L;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                Interlocked.Exchange(ref diskFreeSpace, androidJavaClass.CallStatic<long>("getDiskFreeSpace", Array.Empty<object>()));
                            }
                        });
                        return diskFreeSpace;
        }

        // RVA: 0x17653C4
        public static string GetPersistentDirectoryPath(string suffix = "")
        {
                        string text = ApplicationCache.Instance.Get<string>(PersistentDirectoryPathKey, string.Empty);
                        if (string.IsNullOrEmpty(text))
                        {
                            MainThreadDispatcher.SendAndWait(delegate
                            {
                                text = GetExternalPersistentDirectoryPath();
                                if (string.IsNullOrEmpty(text) || !IsWritable(text))
                                {
                                    text = GetInternalPersistentDirectoryPath();
                                }

                                text += "/files";
                                ApplicationCache.Instance.Set<string>(PersistentDirectoryPathKey, text);
                            });
                        }

                        suffix = (suffix ?? string.Empty).Trim().Trim('/');
                        if (suffix.Length >= 1)
                        {
                            text = text + "/" + suffix;
                        }

                        CreateDirectoryIfNeeded(text);
                        return text;
        }

        // RVA: 0x1765630
        public static string GetInternalPersistentDirectoryPath()
        {
                        string text = ApplicationCache.Instance.Get<string>(InternalPersistentDirectoryPathKey, string.Empty);
                        if (string.IsNullOrEmpty(text))
                        {
                            MainThreadDispatcher.SendAndWait(delegate
                            {
                                using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                                {
                                    text = androidJavaClass.CallStatic<string>("getInternalPersistentDirectoryPath");
                                    ApplicationCache.Instance.Set<string>(InternalPersistentDirectoryPathKey, text);
                                }
                            });
                        }

                        return text;
        }

        // RVA: 0x176575C
        public static string GetExternalPersistentDirectoryPath()
        {
                        string text = ApplicationCache.Instance.Get<string>(ExternalPersistentDirectoryPathKey, string.Empty);
                        if (string.IsNullOrEmpty(text))
                        {
                            MainThreadDispatcher.SendAndWait(delegate
                            {
                                using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                                {
                                    text = androidJavaClass.CallStatic<string>("getExternalPersistentDirectoryPath");
                                    ApplicationCache.Instance.Set<string>(ExternalPersistentDirectoryPathKey, text);
                                }
                            });
                        }

                        return text;
        }

        // RVA: 0x1765888
        public static string GetCacheDirectoryPath(string suffix = "")
        {
                        string text = ApplicationCache.Instance.Get<string>(CacheDirectoryPathKey, string.Empty);
                        if (string.IsNullOrEmpty(text))
                        {
                            MainThreadDispatcher.SendAndWait(delegate
                            {
                                using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                                {
                                    text = androidJavaClass.CallStatic<string>("getCacheDirectory") + "/files";
                                    ApplicationCache.Instance.Set<string>(CacheDirectoryPathKey, text);
                                }
                            });
                        }

                        suffix = (suffix ?? string.Empty).Trim().Trim('/');
                        if (suffix.Length >= 1)
                        {
                            text = text + "/" + suffix;
                        }

                        CreateDirectoryIfNeeded(text);
                        return text;
        }

        // RVA: 0x1765A64
        public static string GetLocaleIdentifier()
        {
                        string text = string.Empty;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                text = androidJavaClass.CallStatic<string>("getDefaultLocaleString");
                            }
                        });
                        return text;
        }

        // RVA: 0x1765B40
        public static string GetLocaleCountryCode()
        {
                        string text = string.Empty;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                text = androidJavaClass.CallStatic<string>("getDefaultLocaleCountry");
                            }
                        });
                        return text;
        }

        // RVA: 0x1765C1C
        public static string GetLocaleLanguageCode()
        {
                        string text = string.Empty;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                text = androidJavaClass.CallStatic<string>("getDefaultLocaleLanguage");
                            }
                        });
                        return text;
        }

        // RVA: 0x1765CF8
        public static string GetDeviceTimeZone()
        {
                        string text = string.Empty;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                text = androidJavaClass.CallStatic<string>("getDeviceTimeZone");
                            }
                        });
                        return text;
        }

        // RVA: 0x1765DD4
        public static bool IsIos()
        {
                        return false;
        }

        // RVA: 0x1765DDC
        public static bool IsAndroid()
        {
                        return true;
        }

        // RVA: 0x1765DE4
        public static bool IsEditor()
        {
                        return false;
        }

        // RVA: 0x1765DEC
        public static Version GetOSVersion()
        {
                        string versionString = string.Empty;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                versionString = androidJavaClass.CallStatic<string>("getOsVersion");
                            }
                        });
                        return Version.Of(versionString);
        }

        // RVA: 0x1765ECC
        public static double GetUsedMemory()
        {
                        long num = 0L;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                num = androidJavaClass.CallStatic<long>("getUsedMemory", Array.Empty<object>());
                            }
                        });
                        return (double)num / 1024.0;
        }

        // RVA: 0x1765FA4
        public static double GetFreeMemory()
        {
                        long num = 0L;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                num = androidJavaClass.CallStatic<long>("getFreeMemory", Array.Empty<object>());
                            }
                        });
                        return (double)num / 1024.0;
        }

        // RVA: 0x176607C
        public static double GetTotalMemory()
        {
                        long num = 0L;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                num = androidJavaClass.CallStatic<long>("getTotalMemory", Array.Empty<object>());
                            }
                        });
                        return (double)num / 1024.0;
        }

        // RVA: 0x1766154
        public static void LoadResemaraDetectionIdentifier(Action<string> action)
        {
                        using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                        {
                            AndroidPlatformListener androidPlatformListener = new AndroidPlatformListener();
                            androidPlatformListener.OnLoadResemaraDetectionIdentifierComplete += action;
                            resemaraObject = androidJavaClass.CallStatic<AndroidJavaObject>("getResemaraDetectionId", androidPlatformListener);
                        }
        }

        // RVA: 0x176644C
        public static bool IsRooted()
        {
                        bool flag = false;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            flag = _KJACore_AssetStateLogAvailable();
                        });
                        return flag;
        }

        // RVA: 0x1766514
        public static bool IsDebuggerAttached()
        {
                        return IsUsbDebuggable() || SubscribeAssetStateLog();
        }

        // RVA: 0x1766538
        public static bool IsUsbDebuggable()
        {
                        bool flag = false;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaObject androidJavaObject = new AndroidJavaObject("android.os.Debug", Array.Empty<object>()))
                            {
                                flag = androidJavaObject.CallStatic<bool>("isDebuggerConnected", Array.Empty<object>());
                            }
                        });
                        return flag;
        }

        // RVA: 0x17666C0
        public static bool IsEmulator()
        {
                        return GetInvalidDeviceProperties().Count > 0;
        }

        // RVA: 0x17668D0
        public static bool IsWritable(string path)
        {
                        bool flag = false;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaObject androidJavaObject = new AndroidJavaObject("com.klab.jackpot.UnityBridge", Array.Empty<object>()))
                            {
                                flag = androidJavaObject.CallStatic<bool>("isWritable", new object[1] { path });
                            }
                        });
                        return flag;
        }

        // RVA: 0x176677C
        public static ICollection<SimpleAnalysisEntry> GetInvalidDeviceProperties()
        {
                        ILogger logger = Logger.Get(typeof(AndroidPlatform));
                        List<SimpleAnalysisEntry> list = new List<SimpleAnalysisEntry>();
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaObject androidJavaObject = new AndroidJavaObject("android.os.Build", Array.Empty<object>()))
                            {
                                string text = androidJavaObject.GetStatic<string>("BRAND");
                                if (text == "generic" || text == "generic_x86")
                                {
                                    logger.Info("Emulator detected from BRAND: {0}", new object[1] { text });
                                    list.Add(new SimpleAnalysisEntry("BRAND", text, false));
                                }

                                text = androidJavaObject.GetStatic<string>("DEVICE");
                                if (text == "generic" || text == "generic_x86" || text == "vbox86p")
                                {
                                    logger.Info("Emulator detected from for DEVICE: {0}", new object[1] { text });
                                    list.Add(new SimpleAnalysisEntry("DEVICE", text, false));
                                }

                                text = androidJavaObject.GetStatic<string>("FINGERPRINT");
                                if (text.StartsWith("generic"))
                                {
                                    logger.Info("Emulator detected from FINGERPRINT: {0}", new object[1] { text });
                                    list.Add(new SimpleAnalysisEntry("FINGERPRINT", text, false));
                                }

                                text = androidJavaObject.GetStatic<string>("HARDWARE");
                                if (text == "goldfish" || text == "vbox86")
                                {
                                    logger.Info("Emulator detected from HARDWARE: {0}", new object[1] { text });
                                    list.Add(new SimpleAnalysisEntry("HARDWARE", text, false));
                                }

                                text = androidJavaObject.GetStatic<string>("MANUFACTURER");
                                if (text == "unknown" || text == "Genymotion")
                                {
                                    logger.Info("Emulator detected from MANUFACTURER: {0}", new object[1] { text });
                                    list.Add(new SimpleAnalysisEntry("MANUFACTURER", text, false));
                                }

                                text = androidJavaObject.GetStatic<string>("MODEL");
                                if (text == "sdk" || text == "google_sdk" || text == "Emulator" || text == "Android SDK built for x86")
                                {
                                    logger.Info("Emulator detected from MODEL: {0}", new object[1] { text });
                                    list.Add(new SimpleAnalysisEntry("MODEL", text, false));
                                }

                                text = androidJavaObject.GetStatic<string>("PRODUCT");
                                if (text == "sdk" || text == "google_sdk" || text == "sdk_x86" || text == "vbox86p")
                                {
                                    logger.Info("Emulator detected from PRODUCT: {0}", new object[1] { text });
                                    list.Add(new SimpleAnalysisEntry("PRODUCT", text, false));
                                }
                            }
                        });
                        return list;
        }

        // RVA: 0x17665F8
        public static bool SubscribeAssetStateLog()
        {
                        bool flag = false;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            bool output = false;
                            bool err = false;
                            _KJACore_AssetStateLogSubscribe(out output, out err);
                            if (!err)
                            {
                                flag = output;
                            }
                        });
                        return flag;
        }

        // RVA: 0x17669B0
        public static string GenerateAssetStateLog(string seed)
        {
                        StringBuilder stringBuilder = new StringBuilder(1024);
                        _KJACore_AssetStateLogGenerateV2(stringBuilder, stringBuilder.Capacity, seed);
                        return stringBuilder.ToString();
        }

        // RVA: 0x1766A40
        public static BatteryStatusKind GetBatteryStatus()
        {
                        return (BatteryStatusKind)Enum.ToObject(typeof(BatteryStatusKind), CallStatic<int>("getBatteryStatus"));
        }

        // RVA: 0x1766B44
        public static int GetBatteryLevel()
        {
                        return CallStatic<int>("getBatteryLevel");
        }

        // RVA: 0x1766B98
        public static float GetBatteryTemperature()
        {
                        return CallStatic<float>("getBatteryTemperature");
        }

        // RVA: 0x1766BEC
        public static int GetBatteryVoltage()
        {
                        return CallStatic<int>("getBatteryVoltage");
        }

        // RVA: 0x1766C40
        public static int GetThermalState()
        {
                        return -1;
        }

        // RVA: 0x1766C48
        public static int GetMaximumFramesPerSecond()
        {
                        return -1;
        }

        // RVA: 0x1766C50
        public static void ShowToastMessage(string message, bool isLong)
        {
                        MainThreadDispatcher.Post(delegate
                        {
                            CallStatic<AndroidJavaObject>("showToastMessage", new object[2] { message, isLong });
                        });
        }

        // RVA: 0x1766D28
        public static bool LaunchApp(string urlScheme, string packageName)
        {
                        bool flag = false;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.UnityBridge"))
                            {
                                flag = androidJavaClass.CallStatic<bool>("LaunchApp", urlScheme, packageName);
                            }
                        });
                        return flag;
        }

        // RVA: 0x1766E04
        public static bool StoreReview()
        {
                        return false;
        }

        // RVA: 0x1766E0C
        private static AndroidJavaClass GetNativeBridge()
        {
                        if (bridge == null)
                        {
                            MainThreadDispatcher.SendAndWait(delegate
                            {
                                bridge = new AndroidJavaClass("com.klab.jackpot.UnityBridge");
                            });
                        }

                        return bridge;
        }

        // RVA: 0x17655A0
        private static void CreateDirectoryIfNeeded(string directoryPath)
        {
                        if (!new DirectoryInfo(directoryPath).Exists)
                        {
                            Directory.CreateDirectory(directoryPath);
                        }
        }

        // RVA: 0x1765178
        private static void UsingLog(Action<AndroidJavaClass> callback)
        {
                        if (callback == null)
                        {
                            return;
                        }

                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("android.util.Log"))
                            {
                                callback(androidJavaClass);
                            }
                        });
        }

        // RVA: 0x1766F30
        private static void CallStatic(string method)
        {
                        CallStatic<AndroidJavaObject>(method);
        }

        // RVA: 0x1766F38
        private static void CallStatic(string method, object[] args)
        {
                        using (JniAttachSection jniAttachSection = new JniAttachSection())
                        {
                            if (args != null)
                            {
                                GetNativeBridge().CallStatic(method, args);
                            }
                            else
                            {
                                GetNativeBridge().CallStatic(method);
                            }
                        }
        }

        private static T CallStatic<T>(string method)
        {
            return CallStatic<T>(method, null);
        }

        private static T CallStatic<T>(string method, object[] args)
        {
            using (JniAttachSection jniAttachSection = new JniAttachSection())
            {
                if (args == null)
                {
                    return GetNativeBridge().CallStatic<T>(method);
                }

                return GetNativeBridge().CallStatic<T>(method, args);
            }
        }

        // RVA: 0x1767128
        public AndroidPlatform()
        {
        }

        public class AndroidPlatformListener : AndroidJavaProxy
        {
            private Action<string> OnLoadResemaraDetectionIdentifierComplete;

            public AndroidPlatformListener()
                : base("com.klab.jackpot.Listener")
            {
            }

            public void add_OnLoadResemaraDetectionIdentifierComplete(Action<string> value)
            {
                Action<string> action;
                Action<string> action2;
                do
                {
                    action = OnLoadResemaraDetectionIdentifierComplete;
                    action2 = (Action<string>)Delegate.Combine(action, value);
                }
                while (Interlocked.CompareExchange(ref OnLoadResemaraDetectionIdentifierComplete, action2, action) != action);
            }

            public void remove_OnLoadResemaraDetectionIdentifierComplete(Action<string> value)
            {
                Action<string> action;
                Action<string> action2;
                do
                {
                    action = OnLoadResemaraDetectionIdentifierComplete;
                    action2 = (Action<string>)Delegate.Remove(action, value);
                }
                while (Interlocked.CompareExchange(ref OnLoadResemaraDetectionIdentifierComplete, action2, action) != action);
            }

            public void onReceived(string id, int kind)
            {
                if (kind == 0)
                {
                    MainThreadDispatcher.Post(delegate
                    {
                        if (OnLoadResemaraDetectionIdentifierComplete != null)
                        {
                            OnLoadResemaraDetectionIdentifierComplete(id);
                        }
                    });
                }
                else if (kind >= 1 && kind <= 5)
                {
                    MainThreadDispatcher.Post(delegate
                    {
                        if (OnLoadResemaraDetectionIdentifierComplete != null)
                        {
                            OnLoadResemaraDetectionIdentifierComplete("");
                        }
                    });
                }

                resemaraObject = null;
            }
        }
    }
}
