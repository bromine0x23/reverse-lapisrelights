// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.RequestPermissionService
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

namespace Jackpot
{
    public class RequestPermissionService
    {
        public static RequestPermissionAndroid requestPermission;

        // RVA: 0x1EA0F60
        public static void LaunchGrantFlow(GrantedPermissionDelegate grantedPermission, NeedExplainPermissionDelegate needExplainPermission, DeniedPermissionDelegate deniedPermission, string permission)
        {
            if (requestPermission == null)
            {
                requestPermission = new RequestPermissionAndroid(grantedPermission, needExplainPermission, deniedPermission, permission);
                requestPermission.StartRequestPermission();
                return;
            }

            throw new PermissionException("StartRequestPermission() started.");
        }

        // RVA: 0x1EA0E44
        public static void Dispose()
        {
            if (requestPermission != null)
            {
                requestPermission.Dispose();
            }

            requestPermission = null;
        }

        // RVA: 0x1EA1054
        public RequestPermissionService()
        {
        }
    }
}
