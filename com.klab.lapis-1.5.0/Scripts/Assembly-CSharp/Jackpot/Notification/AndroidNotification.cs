// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Notification.AndroidNotification
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

namespace Jackpot.Notification
{
    public class AndroidNotification
    {

        // RVA: 0x1E9B0D0
        public static bool IsEnabledByUser()
        {
                        bool result = true;
                        MainThreadDispatcher.SendAndWait(delegate
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.notification.UnityBridge"))
                            {
                                result = androidJavaClass.CallStatic<bool>("isEnabledNotificationByUser", new object[0]);
                            }
                        });
                        return result;
        }

        // RVA: 0x1E9B19C
        public static void RegisterNotification(IosNotificationType types)
        {
        }

        // RVA: 0x1E9B1A0
        public static bool SetLocalNotification(int id, string title, string msg, DateTime fireDate, int badge, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
                        int afterSeconds = 0;
                        if (fireDate.CompareTo(DateTime.Now) >= 1)
                        {
                            afterSeconds = (int)Math.Ceiling((fireDate - DateTime.Now).TotalSeconds);
                        }

                        if (userInfo == null)
                        {
                            userInfo = new Dictionary<string, string>();
                        }

                        string[] array = new List<string>(userInfo.Keys).ToArray();
                        string[] array2 = new List<string>(userInfo.Values).ToArray();
                        try
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.notification.UnityBridge"))
                            {
                                object[] args = new object[]
                                {
                                    id,
                                    title,
                                    msg,
                                    afterSeconds,
                                    soundName,
                                    attachmentName,
                                    array,
                                    array2
                                };
                                return androidJavaClass.CallStatic<bool>("setLocalNotification", args);
                            }
                        }
                        catch
                        {
                            return false;
                        }
        }

        // RVA: 0x1E9B738
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes, int badge, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
                        int num = ConvertFirstDayOfTheWeekSunday(dayOfWeek);
                        if (userInfo == null)
                        {
                            userInfo = new Dictionary<string, string>();
                        }

                        string[] array = new List<string>(userInfo.Keys).ToArray();
                        string[] array2 = new List<string>(userInfo.Values).ToArray();
                        try
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.notification.UnityBridge"))
                            {
                                object[] args = new object[]
                                {
                                    id,
                                    title,
                                    msg,
                                    num,
                                    hour,
                                    minutes,
                                    soundName,
                                    attachmentName,
                                    array,
                                    array2
                                };
                                return androidJavaClass.CallStatic<bool>("setLocalNotificationRepeatable", args);
                            }
                        }
                        catch
                        {
                            return false;
                        }
        }

        // RVA: 0x1E9BCCC
        public static void CancelLocalNotification(int id)
        {
                        try
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.notification.UnityBridge"))
                            {
                                androidJavaClass.CallStatic("cancelLocalNotification", new object[]
                                {
                                    id
                                });
                            }
                        }
                        catch
                        {
                        }
        }

        // RVA: 0x1E9BE78
        public static void CancelAllLocalNotifications()
        {
                        try
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.klab.jackpot.notification.UnityBridge"))
                            {
                                androidJavaClass.CallStatic("cancelAllLocalNotifications", new object[0]);
                            }
                        }
                        catch
                        {
                        }
        }

        // RVA: 0x1E9BCC4
        private static int ConvertFirstDayOfTheWeekSunday(DayOfWeek dayOfWeek)
        {
                        return (int)(dayOfWeek + 1);
        }

        // RVA: 0x1E9C02C
        public AndroidNotification()
        {
        }
    }
}
