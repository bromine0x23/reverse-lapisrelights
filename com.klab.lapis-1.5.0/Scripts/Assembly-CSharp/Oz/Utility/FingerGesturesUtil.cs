// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.FingerGesturesUtil
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

namespace Oz.Utility
{
    public static class FingerGesturesUtil
    {

        // RVA: 0x13E2414
        public static void Disable()
        {
            FingerGestures.instance.enabled = false;
        }

        // RVA: 0x13E24C8
        public static void Enable()
        {
            FingerGestures.instance.enabled = true;
        }

        // RVA: 0x13E257C
        public static void SetScreenRaycasterCamera(GameObject cameraGameObject)
        {
            Camera camera = cameraGameObject.GetComponent<Camera>();
            if (camera != null)
            {
                SetScreenRaycasterCamera(camera);
            }
        }

        // RVA: 0x13E2624
        public static void SetScreenRaycasterCamera(Camera camera)
        {
            if (FingerGestures.instance != null)
            {
                ScreenRaycaster screenRaycaster = FingerGestures.instance.GetComponent<ScreenRaycaster>();
                if (screenRaycaster != null)
                {
                    screenRaycaster.Cameras = new List<Camera> { camera };
                }
            }
        }

        // RVA: 0x13E27A4
        public static void SetScreenRaycasterLayerMask(string str)
        {
            if (FingerGestures.instance != null)
            {
                ScreenRaycaster screenRaycaster = FingerGestures.instance.GetComponent<ScreenRaycaster>();
                if (screenRaycaster != null)
                {
                    screenRaycaster.IgnoreLayerMask =
                        str == "Nothing" ? 0 : 1 << LayerMask.NameToLayer(str);
                }
            }
        }

        // RVA: 0x13E2928
        public static int GetFingersCount()
        {
            int count = 0;
            if (FingerGestures.instance != null)
            {
                for (int i = 0; i < FingerGestures.MaxFingers; i++)
                {
                    count += FingerGestures.GetFinger(i).IsDown ? 1 : 0;
                }
            }

            return count;
        }
    }
}
