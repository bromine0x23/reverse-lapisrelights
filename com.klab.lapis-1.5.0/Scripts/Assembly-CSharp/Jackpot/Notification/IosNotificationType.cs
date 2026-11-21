// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Notification.IosNotificationType
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
    public class IosNotificationType : Enumeration
    {
        public static readonly IosNotificationType None;
        public static readonly IosNotificationType Badge;
        public static readonly IosNotificationType Sound;
        public static readonly IosNotificationType Alert;

        // RVA: 0x1E9C230
        private IosNotificationType(int value, string name)
            : base(value, name)
        {
        }

        // RVA: 0x1E9C238
        public static IosNotificationType op_BitwiseAnd(IosNotificationType x, IosNotificationType y)
        {
            return new IosNotificationType(x.Value & y.Value, "NotificationType");
        }

        // RVA: 0x1E9C2C8
        public static IosNotificationType op_BitwiseOr(IosNotificationType x, IosNotificationType y)
        {
            return new IosNotificationType(x.Value | y.Value, "NotificationType");
        }

        // RVA: 0x1E9C358
        private static void .cctor()
        {
            None = new IosNotificationType(0, "None");
            Badge = new IosNotificationType(1, "Badge");
            Sound = new IosNotificationType(2, "Sound");
            Alert = new IosNotificationType(4, "Alert");
        }
    }
}
