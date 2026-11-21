// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Notification.NotificationReceiver
//  来源：libil2cpp.so (ARM64) 反汇编 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

namespace Jackpot.Notification
{
    public class NotificationReceiver : MonoBehaviour
    {
        public delegate void LaunchedWithNotificationDelegate(string message, Dictionary<string, string> userInfo);

        public delegate void ReceiveNotificationDelegate(string message, Dictionary<string, string> userInfo);

        private static readonly ILogger logger;
        private LaunchedWithNotificationDelegate LaunchedWithNotification;
        private ReceiveNotificationDelegate ReceiveNotification;
        private static NotificationReceiver instance;

        public static NotificationReceiver Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new GameObject("NotificationReceiver").AddComponent<NotificationReceiver>();
                    UnityEngine.Object.DontDestroyOnLoad(instance);
                }

                return instance;
            }
        }

        // RVA: 0x1E9CBA4
        public void add_LaunchedWithNotification(LaunchedWithNotificationDelegate value)
        {
            LaunchedWithNotificationDelegate launchedWithNotificationDelegate;
            LaunchedWithNotificationDelegate value2;
            do
            {
                launchedWithNotificationDelegate = LaunchedWithNotification;
                value2 = (LaunchedWithNotificationDelegate)Delegate.Combine(launchedWithNotificationDelegate, value);
            }
            while (Interlocked.CompareExchange(ref LaunchedWithNotification, value2, launchedWithNotificationDelegate) != launchedWithNotificationDelegate);
        }

        // RVA: 0x1E9CC48
        public void remove_LaunchedWithNotification(LaunchedWithNotificationDelegate value)
        {
            LaunchedWithNotificationDelegate launchedWithNotificationDelegate;
            LaunchedWithNotificationDelegate value2;
            do
            {
                launchedWithNotificationDelegate = LaunchedWithNotification;
                value2 = (LaunchedWithNotificationDelegate)Delegate.Remove(launchedWithNotificationDelegate, value);
            }
            while (Interlocked.CompareExchange(ref LaunchedWithNotification, value2, launchedWithNotificationDelegate) != launchedWithNotificationDelegate);
        }

        // RVA: 0x1E9CCEC
        public void add_ReceiveNotification(ReceiveNotificationDelegate value)
        {
            ReceiveNotificationDelegate receiveNotificationDelegate;
            ReceiveNotificationDelegate value2;
            do
            {
                receiveNotificationDelegate = ReceiveNotification;
                value2 = (ReceiveNotificationDelegate)Delegate.Combine(receiveNotificationDelegate, value);
            }
            while (Interlocked.CompareExchange(ref ReceiveNotification, value2, receiveNotificationDelegate) != receiveNotificationDelegate);
        }

        // RVA: 0x1E9CD90
        public void remove_ReceiveNotification(ReceiveNotificationDelegate value)
        {
            ReceiveNotificationDelegate receiveNotificationDelegate;
            ReceiveNotificationDelegate value2;
            do
            {
                receiveNotificationDelegate = ReceiveNotification;
                value2 = (ReceiveNotificationDelegate)Delegate.Remove(receiveNotificationDelegate, value);
            }
            while (Interlocked.CompareExchange(ref ReceiveNotification, value2, receiveNotificationDelegate) != receiveNotificationDelegate);
        }

        // RVA: 0x1E9CE34
        public static NotificationReceiver get_Instance()
        {
            return Instance;
        }

        // RVA: 0x1E9CF9C
        public void Register(IosNotificationType types)
        {
            if (LaunchedWithNotification == null && ReceiveNotification == null)
            {
                throw new InvalidOperationException();
            }
        }

        // RVA: 0x1E9D01C
        private void OnLaunchedWithNotification(string message)
        {
            logger.Info("OnLaunchedWithNotification:" + message);
            LaunchedWithNotificationDelegate launchedWithNotification = LaunchedWithNotification;
            if (launchedWithNotification != null)
            {
                launchedWithNotification(message, GetUserInfoDic(message));
            }
        }

        // RVA: 0x1E9D760
        private void OnReceiveNotification(string message)
        {
            logger.Info("OnReceiveNotification:" + message);
            ReceiveNotificationDelegate receiveNotification = ReceiveNotification;
            if (receiveNotification != null)
            {
                receiveNotification(message, GetUserInfoDic(message));
            }
        }

        // RVA: 0x1E9D150
        private Dictionary<string, string> GetUserInfoDic(string json)
        {
            Dictionary<string, string> dictionary = new Dictionary<string, string>();
            if (string.IsNullOrEmpty(json))
            {
                return dictionary;
            }

            json = json.Replace("\"", "");
            int num = json.IndexOf("user_info");
            if (num < 1)
            {
                return dictionary;
            }

            int num2 = num + "user_info:{".Length;
            int num3 = json.IndexOf("}", num2);
            string text = json.Substring(num2, num3 - num2);
            string[] array = text.Split(new char[]
            {
                ','
            });
            for (int i = 0; i < array.Length; i++)
            {
                string[] array2 = array[i].Split(new char[]
                {
                    ':'
                });
                if (array2.Length >= 2)
                {
                    dictionary[array2[0]] = array2[1];
                }
            }

            return dictionary;
        }

        // RVA: 0x1E9DC7C
        public NotificationReceiver()
        {
        }

        // RVA: 0x1E9DC84
        static NotificationReceiver()
        {
            logger = Logger.Get("NotificationReceiver");
        }
    }
}
