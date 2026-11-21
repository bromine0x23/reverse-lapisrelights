// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Notification.EditorNotification
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
    public class EditorNotification
    {

        // RVA: 0x1E9C200
        public static bool IsEnabledByUser()
        {
            return true;
        }

        // RVA: 0x1E9C208
        public static void RegisterNotification(IosNotificationType types)
        {
        }

        // RVA: 0x1E9C20C
        public static void SetApplicationIconBadgeNumber(int number)
        {
        }

        // RVA: 0x1E9C210
        public static bool SetLocalNotification(int id, string title, string msg, DateTime fireDate, int badge, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
            return true;
        }

        // RVA: 0x1E9C218
        public static bool SetLocalNotificationRepeatable(int id, string title, string msg, DayOfWeek dayOfWeek, int hour, int minutes, int badge, string soundName, string attachmentName, Dictionary<string, string> userInfo)
        {
            return true;
        }

        // RVA: 0x1E9C220
        public static void CancelLocalNotification(int id)
        {
        }

        // RVA: 0x1E9C224
        public static void CancelAllLocalNotifications()
        {
        }

        // RVA: 0x1E9C228
        public EditorNotification()
        {
        }
    }
}
