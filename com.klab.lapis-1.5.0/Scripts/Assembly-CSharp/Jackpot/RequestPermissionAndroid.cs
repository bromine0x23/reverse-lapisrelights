// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.RequestPermissionAndroid
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
    public class RequestPermissionAndroid : IDisposable
    {
        private bool disposed;
        private string permission;
        private GrantedPermissionDelegate defaultGrantedPermission;
        private NeedExplainPermissionDelegate defaultNeedExplainPermission;
        private DeniedPermissionDelegate defaultDeniedPermission;

        // RVA: 0x1EA0738
        public RequestPermissionAndroid(GrantedPermissionDelegate defaultGrantedPermission, NeedExplainPermissionDelegate defaultNeedExplainPermission, DeniedPermissionDelegate defaultDeniedPermission, string permission)
        {
                        disposed = false;
                        this.permission = permission;
            this.defaultGrantedPermission = defaultGrantedPermission;
            this.defaultNeedExplainPermission = defaultNeedExplainPermission;
            this.defaultDeniedPermission = defaultDeniedPermission;
                        AndroidRequestPermission.GrantedRequestPermission += HandleRequestPermissionGranted;
                        AndroidRequestPermission.DeniedRequestPermission += HandleRequestPermissionDenied;
                        AndroidRequestPermission.NeedExplainRequestPermission += HandleRequestPermissionNeedExplain;
        }

        // RVA: 0x1EA0874
        ~RequestPermissionAndroid()
        {
                        if (!disposed)
                        {
                            Dispose();
                        }
        }

        // RVA: 0x1EA0A10
        public void StartRequestPermission()
        {
                        AndroidRequestPermission.StartRequestPermission(permission);
        }

        // RVA: 0x1EA08E8
        public void Dispose()
        {
                        if (disposed)
                        {
                            return;
                        }

                        AndroidRequestPermission.GrantedRequestPermission -= HandleRequestPermissionGranted;
                        AndroidRequestPermission.DeniedRequestPermission -= HandleRequestPermissionDenied;
                        AndroidRequestPermission.NeedExplainRequestPermission -= HandleRequestPermissionNeedExplain;
                        AndroidRequestPermission.Finish();
                        disposed = true;
        }

        // RVA: 0x1EA0A7C
        private void HandleRequestPermissionGranted()
        {
                        RequestPermissionService.Dispose();
                        defaultGrantedPermission?.Invoke();
        }

        // RVA: 0x1EA0AB0
        private void HandleRequestPermissionDenied()
        {
                        defaultDeniedPermission?.Invoke(delegate
                        {
                            RequestPermissionService.LaunchGrantFlow(defaultGrantedPermission, defaultNeedExplainPermission, defaultDeniedPermission, permission);
                        }, deneidFinishAction);
        }

        // RVA: 0x1EA0B64
        private void HandleRequestPermissionNeedExplain(int kind, string permission)
        {
                        switch (kind)
                        {
                            case 1:
                                defaultNeedExplainPermission?.Invoke(1, NeedExplainNormalOkAction, NeedExplainCancelAction);
                                break;
                            case 2:
                                defaultNeedExplainPermission?.Invoke(2, NeedExplainAppFinishOkAction, NeedExplainCancelAction);
                                break;
                            case 3:
                                defaultNeedExplainPermission?.Invoke(3, NeedExplainOpenSettingsOkAction, NeedExplainCancelAction);
                                break;
                        }
        }

        // RVA: 0x1EA0D08
        private void NeedExplainNormalOkAction()
        {
                        AndroidRequestPermission.RequestPermission(permission);
        }

        // RVA: 0x1EA0D74
        private void NeedExplainAppFinishOkAction()
        {
                        AndroidRequestPermission.RequestPermission(permission);
        }

        // RVA: 0x1EA0DE0
        private void NeedExplainOpenSettingsOkAction()
        {
                        AndroidRequestPermission.OpenSettings();
        }

        // RVA: 0x1EA0E40
        private void NeedExplainCancelAction()
        {
                        RequestPermissionService.Dispose();
        }

        // RVA: 0x1EA0AAC
        private void deneidFinishAction()
        {
                        RequestPermissionService.Dispose();
        }

        // RVA: 0x1EA0EA8
        private void <HandleRequestPermissionDenied>b__10_0()
        {
                        defaultNeedExplainPermission?.Invoke(2, NeedExplainAppFinishOkAction, NeedExplainCancelAction);
        }
    }
}
