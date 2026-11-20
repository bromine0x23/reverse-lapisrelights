// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Utility.CinemachineUtil
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using Cinemachine;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Utility
{
    public static class CinemachineUtil
    {

        // RVA: 0x13E1364
        public static void SetFollowTarget(GameObject virtualCameraGameObject, GameObject target)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                virtualCamera.Follow = target.transform;
            }
        }

        // RVA: 0x13E1440
        public static void SetLookAtTarget(GameObject virtualCameraGameObject, GameObject target)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                virtualCamera.LookAt = target.transform;
            }
        }

        // RVA: 0x13E151C
        public static void SetDollyCameraPathPosition(GameObject virtualCameraGameObject, float value)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                CinemachineTrackedDolly dolly = virtualCamera.GetCinemachineComponent<CinemachineTrackedDolly>();
                if (dolly != null)
                {
                    dolly.m_PathPosition = value;
                }
            }
        }

        // RVA: 0x13E1614
        public static void MoveDollyCamera(GameObject virtualCameraGameObject, float value)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                CinemachineTrackedDolly dolly = virtualCamera.GetCinemachineComponent<CinemachineTrackedDolly>();
                if (dolly != null)
                {
                    dolly.m_PathPosition = Mathf.Clamp(
                        dolly.m_PathPosition + value, dolly.m_Path.MinPos, dolly.m_Path.MaxPos);
                }
            }
        }

        // RVA: 0x13E177C
        public static void SetScreenX(GameObject virtualCameraGameObject, float x)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                CinemachineComposer composer = virtualCamera.GetCinemachineComponent<CinemachineComposer>();
                if (composer != null)
                {
                    composer.m_ScreenX = x;
                }
            }
        }

        // RVA: 0x13E1840
        public static void SetScreenY(GameObject virtualCameraGameObject, float y)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                CinemachineComposer composer = virtualCamera.GetCinemachineComponent<CinemachineComposer>();
                if (composer != null)
                {
                    composer.m_ScreenY = y;
                }
            }
        }

        // RVA: 0x13E1904
        public static void SetFieldOfView(GameObject virtualCameraGameObject, float dis)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                virtualCamera.m_Lens.FieldOfView = dis;
            }
        }

        // RVA: 0x13E19B0
        public static void SetDeadZoneWidth(GameObject virtualCameraGameObject, float w)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                CinemachineComposer composer = virtualCamera.GetCinemachineComponent<CinemachineComposer>();
                if (composer != null)
                {
                    composer.m_DeadZoneWidth = w;
                }
            }
        }

        // RVA: 0x13E1A74
        public static void SetDeadZoneHeight(GameObject virtualCameraGameObject, float h)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                CinemachineComposer composer = virtualCamera.GetCinemachineComponent<CinemachineComposer>();
                if (composer != null)
                {
                    composer.m_DeadZoneHeight = h;
                }
            }
        }

        // RVA: 0x13E1B38
        public static void SetPriority(GameObject virtualCameraGameObject, int val)
        {
            CinemachineVirtualCamera virtualCamera = virtualCameraGameObject.GetComponent<CinemachineVirtualCamera>();
            if (virtualCamera != null)
            {
                virtualCamera.m_Priority = val;
            }
        }

        // RVA: 0x13E1BE4
        public static void ResetTargetGroup(GameObject targetGroupGameObject)
        {
            CinemachineTargetGroup targetGroup = targetGroupGameObject.GetComponent<CinemachineTargetGroup>();
            if (targetGroup != null)
            {
                for (int i = 0; i < targetGroup.m_Targets.Length; i++)
                {
                    targetGroup.m_Targets[i].target = null;
                }
            }
        }

        // RVA: 0x13E1CC4
        public static void SetTargetGroup(GameObject targetGroupGameObject, int index, Transform target)
        {
            CinemachineTargetGroup targetGroup = targetGroupGameObject.GetComponent<CinemachineTargetGroup>();
            if (targetGroup != null)
            {
                targetGroup.m_Targets[index].target = target;
            }
        }

        // RVA: 0x13E1D98
        public static void AddTargetGroupMember(
            GameObject targetGroupGameObject,
            Transform target,
            float weight = 1,
            float radius = 0)
        {
            CinemachineTargetGroup targetGroup = targetGroupGameObject.GetComponent<CinemachineTargetGroup>();
            if (targetGroup != null)
            {
                targetGroup.AddMember(target, weight, radius);
            }
        }

        // RVA: 0x13E1E78
        public static void RemoveTargetGroupMember(GameObject targetGroupGameObject, Transform target)
        {
            CinemachineTargetGroup targetGroup = targetGroupGameObject.GetComponent<CinemachineTargetGroup>();
            if (targetGroup != null)
            {
                targetGroup.RemoveMember(target);
            }
        }

        // RVA: 0x13E1F3C
        public static void ActiveCameraCullingMask(GameObject cameraGameObject, bool isOn, int layer)
        {
            Camera camera = cameraGameObject.GetComponent<Camera>();
            if (camera != null)
            {
                int layerMask = 1 << layer;
                camera.cullingMask = isOn
                    ? camera.cullingMask | layerMask
                    : camera.cullingMask & ~layerMask;
            }
        }
    }
}
