// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Notification.Notification
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
    public class Notification
    {

        // RVA: 0x1E9C454
        public static bool SetLocalNotification(int id, string title, string msg, int afterSeconds)
        {
            return SetLocalNotification(id, title, msg, afterSeconds, (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9C45C
        public static bool SetLocalNotification(int id, string title, string msg, int afterSeconds, Dictionary<string, string> userInfo)
        {
            return SetLocalNotification(id, title, msg, afterSeconds, -1, "", "", userInfo);
        }

        // RVA: 0x1E9C5D0
        public static bool SetLocalNotification(int id, string title, string msg, DateTime fireDate)
        {
            return SetLocalNotification(id, title, msg, fireDate, (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9C5D8
        public static bool SetLocalNotification(int id, string title, string msg, DateTime fireDate, Dictionary<string, string> userInfo)
        {
            return AndroidNotification.SetLocalNotification(id, title, msg, fireDate, 0, "", "", userInfo);
        }

        // RVA: 0x1E9C670
        public static bool SetLocalNotification(int id, string title, string msg, int afterSeconds, int badge)
        {
            return SetLocalNotification(id, title, msg, afterSeconds, badge, (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9C678
        public static bool SetLocalNotification(int id, string title, string msg, int afterSeconds, int badge, Dictionary<string, string> userInfo)
        {
            return SetLocalNotification(id, title, msg, afterSeconds, badge, "", "", userInfo);
        }

        // RVA: 0x1E9C71C
        public static bool SetLocalNotification(int id, string title, string msg, DateTime fireDate, int badge)
        {
            return SetLocalNotification(id, title, msg, fireDate, badge, (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9C724
        public static bool SetLocalNotification(int id, string title, string msg, DateTime fireDate, int badge, Dictionary<string, string> userInfo)
        {
            return AndroidNotification.SetLocalNotification(id, title, msg, fireDate, badge, "", "", userInfo);
        }

        // RVA: 0x1E9C7B8
        public static bool SetLocalNotification(int id, string title, string msg, int afterSeconds, string soundName, string attachmentName)
        {
            return SetLocalNotification(id, title, msg, afterSeconds, -1, soundName, attachmentName, (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9C7E8
        public static bool SetLocalNotification(int id, string title, string msg, int afterSeconds, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
            return SetLocalNotification(id, title, msg, afterSeconds, -1, soundName, attachmentName, userInfo);
        }

        // RVA: 0x1E9C818
        public static bool SetLocalNotification(int id, string title, string msg, DateTime fireDate, string soundName, string attachmentName)
        {
            return AndroidNotification.SetLocalNotification(id, title, msg, fireDate, 0, soundName, attachmentName, (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9C844
        public static bool SetLocalNotification(int id, string title, string msg, DateTime fireDate, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
            return AndroidNotification.SetLocalNotification(id, title, msg, fireDate, 0, soundName, attachmentName, userInfo);
        }

        // RVA: 0x1E9C4F4
        public static bool SetLocalNotification(int id, string title, string msg, int afterSeconds, int badge, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
            return AndroidNotification.SetLocalNotification(id, title, msg, DateTime.Now.AddSeconds(afterSeconds), badge, soundName, attachmentName, userInfo);
        }

        // RVA: 0x1E9C66C
        public static bool SetLocalNotification(int id, string title, string msg, DateTime fireDate, int badge, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
            return AndroidNotification.SetLocalNotification(id, title, msg, fireDate, badge, soundName, attachmentName, userInfo);
        }

        // RVA: 0x1E9C870
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes)
        {
            return AndroidNotification.SetLocalNotificationRepeatable(id, title, msg, dayOfWeek, hour, minutes, 0, "", "", (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9C93C
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes, Dictionary<string, string> userInfo)
        {
            return AndroidNotification.SetLocalNotificationRepeatable(id, title, msg, dayOfWeek, hour, minutes, 0, "", "", userInfo);
        }

        // RVA: 0x1E9C9F0
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes, int badge)
        {
            return AndroidNotification.SetLocalNotificationRepeatable(id, title, msg, dayOfWeek, hour, minutes, badge, "", "", (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9CA94
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes, int badge, Dictionary<string, string> userInfo)
        {
            return AndroidNotification.SetLocalNotificationRepeatable(id, title, msg, dayOfWeek, hour, minutes, badge, "", "", userInfo);
        }

        // RVA: 0x1E9CB3C
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes, string soundName, string attachmentName)
        {
            return AndroidNotification.SetLocalNotificationRepeatable(id, title, msg, dayOfWeek, hour, minutes, 0, soundName, attachmentName, (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9CB64
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
            return AndroidNotification.SetLocalNotificationRepeatable(id, title, msg, dayOfWeek, hour, minutes, 0, soundName, attachmentName, userInfo);
        }

        // RVA: 0x1E9C914
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes, int badge, string soundName, string attachmentName)
        {
            return AndroidNotification.SetLocalNotificationRepeatable(id, title, msg, dayOfWeek, hour, minutes, badge, soundName, attachmentName, (Dictionary<string, string>)null);
        }

        // RVA: 0x1E9C9E4
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes, int badge, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
            return AndroidNotification.SetLocalNotificationRepeatable(id, title, msg, dayOfWeek, hour, minutes, badge, soundName, attachmentName, userInfo);
        }

        // RVA: 0x1E9CB90
        public static void CancelLocalNotification(int id)
        {
            AndroidNotification.CancelLocalNotification(id);
        }

        // RVA: 0x1E9CB94
        public static void CancelAllLocalNotifications()
        {
            AndroidNotification.CancelAllLocalNotifications();
        }

        // RVA: 0x1E9CB98
        public static bool IsEnabledByUser()
        {
            return AndroidNotification.IsEnabledByUser();
        }

        // RVA: 0x1E9CB9C
        public Notification()
        {
        }
    }
}
