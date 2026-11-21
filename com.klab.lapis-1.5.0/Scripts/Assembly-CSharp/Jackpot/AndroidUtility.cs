// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.AndroidUtility
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
    public static class AndroidUtility
    {

        // RVA: 0x176B7F4
        public static void UsingUnityPlayerActivity(Action<AndroidJavaObject> callback)
        {
                        if (callback == null)
                        {
                            return;
                        }

                        using (JniAttachSection jniAttachSection = new JniAttachSection())
                        {
                            using (AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                            {
                                using (AndroidJavaObject androidJavaObject = androidJavaClass.GetStatic<AndroidJavaObject>("currentActivity"))
                                {
                                    callback(androidJavaObject);
                                }
                            }
                        }
        }

        // RVA: 0x176BAB4
        public static void UsingApplicationContext(Action<AndroidJavaObject> callback)
        {
                        UsingUnityPlayerActivity(delegate(AndroidJavaObject activity)
                        {
                            using (AndroidJavaObject androidJavaObject = activity.Call<AndroidJavaObject>("getApplicationContext"))
                            {
                                callback(androidJavaObject);
                            }
                        });
        }

        // RVA: 0x17672E4
        public static void UsingPackageInfo(Action<AndroidJavaObject> callback)
        {
                        UsingUnityPlayerActivity(delegate(AndroidJavaObject activity)
                        {
                            using (AndroidJavaObject androidJavaObject = activity.Call<AndroidJavaObject>("getApplicationContext"))
                            {
                                callback(androidJavaObject);
                            }
                        });
        }

        // RVA: 0x176BB74
        public static AndroidJavaObject DictionaryToHashMap(Dictionary<string, string> dict)
        {
                        using (JniAttachSection jniAttachSection = new JniAttachSection())
                        {
                            AndroidJavaObject androidJavaObject = new AndroidJavaObject("java.util.HashMap");
                            IntPtr methodID = AndroidJNIHelper.GetMethodID(androidJavaObject.GetRawClass(), "put", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
                            foreach (KeyValuePair<string, string> item in dict)
                            {
                                using (AndroidJavaObject androidJavaObject2 = new AndroidJavaObject("java.lang.String", item.Key))
                                {
                                    using (AndroidJavaObject androidJavaObject3 = new AndroidJavaObject("java.lang.String", item.Value))
                                    {
                                        AndroidJNI.CallObjectMethod(androidJavaObject.GetRawObject(), methodID, AndroidJNIHelper.CreateJNIArgArray(new object[]
                                        {
                                            androidJavaObject2,
                                            androidJavaObject3
                                        }));
                                    }
                                }
                            }

                            return androidJavaObject;
                        }
        }
    }
}
