// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  JackpotExamples.LocalNotificationTest
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace JackpotExamples
{
    public class LocalNotificationTest : MonoBehaviour
    {
        private string attachmentName;
        private readonly ILogger logger;
        private Dictionary<string, string> userInfo;

        // RVA: 0x16BE750
        private void Start()
        {
                        GuiLogHandler.Instance.StartLog(true);
                        GuiLogHandler.Instance.Show();
                        InitializeNotification();
                        logger.Debug("InitializeNotification");
        }

        // RVA: 0x16BEA04
        private void OnGUI()
        {
                        if (GUI.Button(new Rect(10f, 10f, 450f, 100f), "10秒後に通知"))
                        {
                            Notification.SetLocalNotification(1000, "test", "これは通知テストです。", 10);
                            logger.Debug("It Notifies after 10 seconds");
                        }

                        if (GUI.Button(new Rect(465f, 10f, 450f, 100f), "通知をキャンセル"))
                        {
                            Notification.CancelLocalNotification(1000);
                            logger.Debug("Cancel Simple Notifications");
                        }

                        if (GUI.Button(new Rect(10f, 115f, 450f, 100f), "１分後から１週間おきに通知"))
                        {
                            DateTime dateTime = DateTime.Now.AddMinutes(1.0);
                            Notification.SetLocalNotificationRepeatable(1001, "RepeatableTest", "繰り返し通知テスト", dateTime.DayOfWeek, dateTime.Hour, dateTime.Minute, userInfo);
                            logger.Debug(string.Concat("It Notifies on ", dateTime.DayOfWeek, " at ", dateTime.Hour, ":", dateTime.Minute));
                        }

                        if (GUI.Button(new Rect(465f, 115f, 450f, 100f), "繰り返し通知をキャンセル"))
                        {
                            Notification.CancelLocalNotification(1001);
                            logger.Debug("Cancel Repeatable Notifications");
                        }

                        if (GUI.Button(new Rect(10f, 220f, 450f, 100f), "10秒後に画像付き通知"))
                        {
                            Notification.SetLocalNotification(1002, "PictureTest", "画像付き通知テスト", 10, null, attachmentName);
                            logger.Debug("It Picture Notifies after 10 seconds");
                        }

                        if (GUI.Button(new Rect(465f, 220f, 450f, 100f), "画像付き通知をキャンセル"))
                        {
                            Notification.CancelLocalNotification(1002);
                            logger.Debug("Cancel Picture Notifications");
                        }

                        if (GUI.Button(new Rect(10f, 350f, 450f, 100f), "全通知をキャンセル"))
                        {
                            Notification.CancelAllLocalNotifications();
                            logger.Debug("Cancel All Notifications");
                        }

                        if (GUI.Button(new Rect(10f, 480f, 450f, 100f), "通知許可承認を確認"))
                        {
                            bool flag = Notification.IsEnabledByUser();
                            logger.Debug("notification enable :" + flag.ToString());
                        }
        }

        // RVA: 0x16BE864
        private void InitializeNotification()
        {
                        if (Application.platform == RuntimePlatform.IPhonePlayer)
                        {
                            LoadImageIos();
                        }
                        else if (Application.platform == RuntimePlatform.Android)
                        {
                            LoadImageAndroid();
                        }

                        NotificationReceiver.Instance.LaunchedWithNotification += delegate(string message, Dictionary<string, string> userInfo)
                        {
                            NotificationMessageExample notificationMessageExample = new NotificationMessageExample();
                            JsonUtility.FromJsonOverwrite(message, notificationMessageExample);
                            logger.Info("Launched With Notification:{0}", new object[1] { notificationMessageExample });
                        };
                        NotificationReceiver.Instance.ReceiveNotification += delegate(string message, Dictionary<string, string> userInfo)
                        {
                            NotificationMessageExample notificationMessageExample = new NotificationMessageExample();
                            JsonUtility.FromJsonOverwrite(message, notificationMessageExample);
                            logger.Info("Receive Notification:{0}", new object[1] { notificationMessageExample });
                        };
                        NotificationReceiver.Instance.Register(IosNotificationType.Badge | IosNotificationType.Sound | IosNotificationType.Alert);
        }

        // RVA: 0x16BF488
        private void LoadImageIos()
        {
                        string text = Application.streamingAssetsPath + "/Jackpot/Jackpot.Social.Invitation/320px-Kepler11_public-domain.png";
                        if (File.Exists(text))
                        {
                            attachmentName = text;
                        }
                        else
                        {
                            StartCoroutine(LoadImage(text));
                        }
        }

        // RVA: 0x16BF51C
        private void LoadImageAndroid()
        {
                        string text = Application.temporaryCachePath + "/Jackpot/Jackpot.Social.Invitation/320px-Kepler11_public-domain.png";
                        if (File.Exists(text))
                        {
                            attachmentName = text;
                        }
                        else
                        {
                            StartCoroutine(LoadImage(text));
                        }
        }

        // RVA: 0x16BF5B0
        [IteratorStateMachine]
        private IEnumerator LoadImage(string path)
        {
                        WWW www = new WWW("jar:file://" + Application.dataPath + "!/assets/Jackpot/Jackpot.Social.Invitation/320px-Kepler11_public-domain.png");
                        yield return www;
                        string directoryName = Path.GetDirectoryName(path);
                        if (!Directory.Exists(directoryName))
                        {
                            Directory.CreateDirectory(directoryName);
                        }

                        using (FileStream fileStream = new FileStream(path, FileMode.Create, FileAccess.Write))
                        {
                            fileStream.Write(www.bytes, 0, www.bytes.Length);
                        }

                        attachmentName = path;
        }

        // RVA: 0x16BF658
        public LocalNotificationTest()
        {
                        logger = Logger.Get<LocalNotificationTest>();
                        userInfo = new Dictionary<string, string>
                        {
                            { "custom_key_01", "aka" },
                            { "custom_key_02", "ao" },
                            { "custom_key_03", "ki" },
                            { "custom_key_04", "midori" },
                            { "custom_key_05", "momo" }
                        };
        }
    }
}
