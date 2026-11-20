// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.VersionControl
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

namespace Oz.GameKit.Version
{
    public class VersionControl
    {
        public static bool hasVerUpdate;
        private Action onFetchVersionBegin;
        private Action onFetchVersionSuccess;
        private Action onFetchVersionFailed;
        private Action<Action<bool>> onUpdateApplication;
        private Action<ulong, Action<bool>> onSelectVersion;
        private Action onCheckExtractBegin;
        private Action<bool> onCheckExtractSuccess;
        private Action onCheckExtractSkip;
        private Action<StateCheckExtract.FailedReason> onCheckExtractFailed;
        private Action onExtractBegin;
        private Action<string> onExtractError;
        private Action onExtractSuccess;
        private Action<float> onExtractProgress;
        private Action onCheckUpdateBegin;
        private Action<long> onCheckUpdateSuccess;
        private Action<bool> onCheckUpdateSkip;
        private Action<StateCheckUpdate.FailedReason> onCheckUpdateFailed;
        private Action onUpdateBegin;
        private Action<string> onUpdateError;
        private Action onUpdateSuccess;
        private Action onUpdateFailed;
        private Action<ulong> onUpdateChangeCarrierDataNetwork;
        private Action<ulong, ulong> onUpdateProgress;
        private Action<ulong> onUpdateSpeed;
        private Action onCleanResourceBegin;
        private Action onCleanSuccess;
        private Action onComplete;
        private StateMachine<eProcedure, eCommand> m_Procedure;
        public static List<string> CdnDomains { get; set; }
        public static List<string> ServerListURLs { get; set; }
        public static string ResVersion { get; set; }
        public static string StrVersion { get; }
        public static string NoticeKey { get; set; }
        public static PatchInfo PatchInfo { get; set; }
        public static IPackageManifest Manifest { get; set; }
        internal List<IPackageInfo> ExtractList { get; set; }
        internal List<IPackageInfo> UpdateList { get; set; }
        internal List<IPackageInfo> DeleteList { get; set; }

        // RVA: 0x18917CC
        public static List<string> get_CdnDomains()
        {
            return CdnDomains;
        }

        // RVA: 0x1891834
        private static void set_CdnDomains(List<string> value)
        {
            CdnDomains = value;
        }

        // RVA: 0x18918A0
        public static List<string> get_ServerListURLs()
        {
            return ServerListURLs;
        }

        // RVA: 0x1891908
        private static void set_ServerListURLs(List<string> value)
        {
            ServerListURLs = value;
        }

        // RVA: 0x1891974
        public static string get_ResVersion()
        {
            return ResVersion;
        }

        // RVA: 0x18919DC
        private static void set_ResVersion(string value)
        {
            ResVersion = value;
        }

        // RVA: 0x1891A48
        public static string get_StrVersion()
        {
            // 伪代码中类型判定符号被 Hex-Rays 误标为 PackageManifest，
            // 但实际读取的是 0x20 偏移（VersionManifestKc.resVersion）
            if (Manifest != null && Manifest is VersionManifestKc version)
            {
                return version.resVersion;
            }
            return "0";
        }

        // RVA: 0x1891B98
        public static string get_NoticeKey()
        {
            return NoticeKey;
        }

        // RVA: 0x1891C00
        private static void set_NoticeKey(string value)
        {
            NoticeKey = value;
        }

        // RVA: 0x1891C6C
        public static PatchInfo get_PatchInfo()
        {
            return PatchInfo;
        }

        // RVA: 0x1891CD4
        private static void set_PatchInfo(PatchInfo value)
        {
            PatchInfo = value;
        }

        // RVA: 0x1891D40
        public static IPackageManifest get_Manifest()
        {
            return Manifest;
        }

        // RVA: 0x1891DA8
        private static void set_Manifest(IPackageManifest value)
        {
            Manifest = value;
        }

        // RVA: 0x1891E14
        internal List<IPackageInfo> get_ExtractList()
        {
            return ExtractList;
        }

        // RVA: 0x1891E1C
        private void set_ExtractList(List<IPackageInfo> value)
        {
            ExtractList = value;
        }

        // RVA: 0x1891E24
        internal List<IPackageInfo> get_UpdateList()
        {
            return UpdateList;
        }

        // RVA: 0x1891E2C
        private void set_UpdateList(List<IPackageInfo> value)
        {
            UpdateList = value;
        }

        // RVA: 0x1891E34
        internal List<IPackageInfo> get_DeleteList()
        {
            return DeleteList;
        }

        // RVA: 0x1891E3C
        private void set_DeleteList(List<IPackageInfo> value)
        {
            DeleteList = value;
        }

        // RVA: 0x188C970
        public void add_onFetchVersionBegin(Action value)
        {
            Action current;
            do
            {
                current = onFetchVersionBegin;
            }
            while (current != Interlocked.CompareExchange(ref onFetchVersionBegin, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188EA20
        public void remove_onFetchVersionBegin(Action value)
        {
            Action current;
            do
            {
                current = onFetchVersionBegin;
            }
            while (current != Interlocked.CompareExchange(ref onFetchVersionBegin, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CA14
        public void add_onFetchVersionSuccess(Action value)
        {
            Action current;
            do
            {
                current = onFetchVersionSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onFetchVersionSuccess, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188EAC4
        public void remove_onFetchVersionSuccess(Action value)
        {
            Action current;
            do
            {
                current = onFetchVersionSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onFetchVersionSuccess, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CAB8
        public void add_onFetchVersionFailed(Action value)
        {
            Action current;
            do
            {
                current = onFetchVersionFailed;
            }
            while (current != Interlocked.CompareExchange(ref onFetchVersionFailed, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188EB68
        public void remove_onFetchVersionFailed(Action value)
        {
            Action current;
            do
            {
                current = onFetchVersionFailed;
            }
            while (current != Interlocked.CompareExchange(ref onFetchVersionFailed, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CB5C
        public void add_onUpdateApplication(Action<Action<bool>> value)
        {
            Action<Action<bool>> current;
            do
            {
                current = onUpdateApplication;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateApplication, (Action<Action<bool>>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x1891E44
        public void remove_onUpdateApplication(Action<Action<bool>> value)
        {
            Action<Action<bool>> current;
            do
            {
                current = onUpdateApplication;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateApplication, (Action<Action<bool>>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CC00
        public void add_onSelectVersion(Action<ulong, Action<bool>> value)
        {
            Action<ulong, Action<bool>> current;
            do
            {
                current = onSelectVersion;
            }
            while (current != Interlocked.CompareExchange(ref onSelectVersion, (Action<ulong, Action<bool>>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188EC0C
        public void remove_onSelectVersion(Action<ulong, Action<bool>> value)
        {
            Action<ulong, Action<bool>> current;
            do
            {
                current = onSelectVersion;
            }
            while (current != Interlocked.CompareExchange(ref onSelectVersion, (Action<ulong, Action<bool>>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CCA4
        public void add_onCheckExtractBegin(Action value)
        {
            Action current;
            do
            {
                current = onCheckExtractBegin;
            }
            while (current != Interlocked.CompareExchange(ref onCheckExtractBegin, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188ECB0
        public void remove_onCheckExtractBegin(Action value)
        {
            Action current;
            do
            {
                current = onCheckExtractBegin;
            }
            while (current != Interlocked.CompareExchange(ref onCheckExtractBegin, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CD48
        public void add_onCheckExtractSuccess(Action<bool> value)
        {
            Action<bool> current;
            do
            {
                current = onCheckExtractSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onCheckExtractSuccess, (Action<bool>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188ED54
        public void remove_onCheckExtractSuccess(Action<bool> value)
        {
            Action<bool> current;
            do
            {
                current = onCheckExtractSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onCheckExtractSuccess, (Action<bool>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CDEC
        public void add_onCheckExtractSkip(Action value)
        {
            Action current;
            do
            {
                current = onCheckExtractSkip;
            }
            while (current != Interlocked.CompareExchange(ref onCheckExtractSkip, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x1891EE8
        public void remove_onCheckExtractSkip(Action value)
        {
            Action current;
            do
            {
                current = onCheckExtractSkip;
            }
            while (current != Interlocked.CompareExchange(ref onCheckExtractSkip, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CE90
        public void add_onCheckExtractFailed(Action<StateCheckExtract.FailedReason> value)
        {
            Action<StateCheckExtract.FailedReason> current;
            do
            {
                current = onCheckExtractFailed;
            }
            while (current != Interlocked.CompareExchange(ref onCheckExtractFailed, (Action<StateCheckExtract.FailedReason>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188EDF8
        public void remove_onCheckExtractFailed(Action<StateCheckExtract.FailedReason> value)
        {
            Action<StateCheckExtract.FailedReason> current;
            do
            {
                current = onCheckExtractFailed;
            }
            while (current != Interlocked.CompareExchange(ref onCheckExtractFailed, (Action<StateCheckExtract.FailedReason>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CF34
        public void add_onExtractBegin(Action value)
        {
            Action current;
            do
            {
                current = onExtractBegin;
            }
            while (current != Interlocked.CompareExchange(ref onExtractBegin, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188EE9C
        public void remove_onExtractBegin(Action value)
        {
            Action current;
            do
            {
                current = onExtractBegin;
            }
            while (current != Interlocked.CompareExchange(ref onExtractBegin, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D07C
        public void add_onExtractError(Action<string> value)
        {
            Action<string> current;
            do
            {
                current = onExtractError;
            }
            while (current != Interlocked.CompareExchange(ref onExtractError, (Action<string>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188EFE4
        public void remove_onExtractError(Action<string> value)
        {
            Action<string> current;
            do
            {
                current = onExtractError;
            }
            while (current != Interlocked.CompareExchange(ref onExtractError, (Action<string>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188CFD8
        public void add_onExtractSuccess(Action value)
        {
            Action current;
            do
            {
                current = onExtractSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onExtractSuccess, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188EF40
        public void remove_onExtractSuccess(Action value)
        {
            Action current;
            do
            {
                current = onExtractSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onExtractSuccess, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D120
        public void add_onExtractProgress(Action<float> value)
        {
            Action<float> current;
            do
            {
                current = onExtractProgress;
            }
            while (current != Interlocked.CompareExchange(ref onExtractProgress, (Action<float>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F088
        public void remove_onExtractProgress(Action<float> value)
        {
            Action<float> current;
            do
            {
                current = onExtractProgress;
            }
            while (current != Interlocked.CompareExchange(ref onExtractProgress, (Action<float>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D1C4
        public void add_onCheckUpdateBegin(Action value)
        {
            Action current;
            do
            {
                current = onCheckUpdateBegin;
            }
            while (current != Interlocked.CompareExchange(ref onCheckUpdateBegin, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F12C
        public void remove_onCheckUpdateBegin(Action value)
        {
            Action current;
            do
            {
                current = onCheckUpdateBegin;
            }
            while (current != Interlocked.CompareExchange(ref onCheckUpdateBegin, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D268
        public void add_onCheckUpdateSuccess(Action<long> value)
        {
            Action<long> current;
            do
            {
                current = onCheckUpdateSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onCheckUpdateSuccess, (Action<long>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F1D0
        public void remove_onCheckUpdateSuccess(Action<long> value)
        {
            Action<long> current;
            do
            {
                current = onCheckUpdateSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onCheckUpdateSuccess, (Action<long>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D30C
        public void add_onCheckUpdateSkip(Action<bool> value)
        {
            Action<bool> current;
            do
            {
                current = onCheckUpdateSkip;
            }
            while (current != Interlocked.CompareExchange(ref onCheckUpdateSkip, (Action<bool>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F274
        public void remove_onCheckUpdateSkip(Action<bool> value)
        {
            Action<bool> current;
            do
            {
                current = onCheckUpdateSkip;
            }
            while (current != Interlocked.CompareExchange(ref onCheckUpdateSkip, (Action<bool>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D3B0
        public void add_onCheckUpdateFailed(Action<StateCheckUpdate.FailedReason> value)
        {
            Action<StateCheckUpdate.FailedReason> current;
            do
            {
                current = onCheckUpdateFailed;
            }
            while (current != Interlocked.CompareExchange(ref onCheckUpdateFailed, (Action<StateCheckUpdate.FailedReason>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F318
        public void remove_onCheckUpdateFailed(Action<StateCheckUpdate.FailedReason> value)
        {
            Action<StateCheckUpdate.FailedReason> current;
            do
            {
                current = onCheckUpdateFailed;
            }
            while (current != Interlocked.CompareExchange(ref onCheckUpdateFailed, (Action<StateCheckUpdate.FailedReason>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D454
        public void add_onUpdateBegin(Action value)
        {
            Action current;
            do
            {
                current = onUpdateBegin;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateBegin, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F3BC
        public void remove_onUpdateBegin(Action value)
        {
            Action current;
            do
            {
                current = onUpdateBegin;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateBegin, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D59C
        public void add_onUpdateError(Action<string> value)
        {
            Action<string> current;
            do
            {
                current = onUpdateError;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateError, (Action<string>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F504
        public void remove_onUpdateError(Action<string> value)
        {
            Action<string> current;
            do
            {
                current = onUpdateError;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateError, (Action<string>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D4F8
        public void add_onUpdateSuccess(Action value)
        {
            Action current;
            do
            {
                current = onUpdateSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateSuccess, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F460
        public void remove_onUpdateSuccess(Action value)
        {
            Action current;
            do
            {
                current = onUpdateSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateSuccess, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D640
        public void add_onUpdateFailed(Action value)
        {
            Action current;
            do
            {
                current = onUpdateFailed;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateFailed, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F5A8
        public void remove_onUpdateFailed(Action value)
        {
            Action current;
            do
            {
                current = onUpdateFailed;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateFailed, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D82C
        public void add_onUpdateChangeCarrierDataNetwork(Action<ulong> value)
        {
            Action<ulong> current;
            do
            {
                current = onUpdateChangeCarrierDataNetwork;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateChangeCarrierDataNetwork, (Action<ulong>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x1891F8C
        public void remove_onUpdateChangeCarrierDataNetwork(Action<ulong> value)
        {
            Action<ulong> current;
            do
            {
                current = onUpdateChangeCarrierDataNetwork;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateChangeCarrierDataNetwork, (Action<ulong>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D6E4
        public void add_onUpdateProgress(Action<ulong, ulong> value)
        {
            Action<ulong, ulong> current;
            do
            {
                current = onUpdateProgress;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateProgress, (Action<ulong, ulong>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F64C
        public void remove_onUpdateProgress(Action<ulong, ulong> value)
        {
            Action<ulong, ulong> current;
            do
            {
                current = onUpdateProgress;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateProgress, (Action<ulong, ulong>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D788
        public void add_onUpdateSpeed(Action<ulong> value)
        {
            Action<ulong> current;
            do
            {
                current = onUpdateSpeed;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateSpeed, (Action<ulong>)Delegate.Combine(current, value), current));
        }

        // RVA: 0x188F6F0
        public void remove_onUpdateSpeed(Action<ulong> value)
        {
            Action<ulong> current;
            do
            {
                current = onUpdateSpeed;
            }
            while (current != Interlocked.CompareExchange(ref onUpdateSpeed, (Action<ulong>)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D8D0
        public void add_onCleanResourceBegin(Action value)
        {
            Action current;
            do
            {
                current = onCleanResourceBegin;
            }
            while (current != Interlocked.CompareExchange(ref onCleanResourceBegin, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x1892030
        public void remove_onCleanResourceBegin(Action value)
        {
            Action current;
            do
            {
                current = onCleanResourceBegin;
            }
            while (current != Interlocked.CompareExchange(ref onCleanResourceBegin, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188D974
        public void add_onCleanSuccess(Action value)
        {
            Action current;
            do
            {
                current = onCleanSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onCleanSuccess, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x18920D4
        public void remove_onCleanSuccess(Action value)
        {
            Action current;
            do
            {
                current = onCleanSuccess;
            }
            while (current != Interlocked.CompareExchange(ref onCleanSuccess, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x188BA34
        public void add_onComplete(Action value)
        {
            Action current;
            do
            {
                current = onComplete;
            }
            while (current != Interlocked.CompareExchange(ref onComplete, (Action)Delegate.Combine(current, value), current));
        }

        // RVA: 0x1892178
        public void remove_onComplete(Action value)
        {
            Action current;
            do
            {
                current = onComplete;
            }
            while (current != Interlocked.CompareExchange(ref onComplete, (Action)Delegate.Remove(current, value), current));
        }

        // RVA: 0x18875CC
        internal void OnBeginFetchVersion()
        {
            if (onFetchVersionBegin != null)
            {
                onFetchVersionBegin();
            }
        }

        // RVA: 0x189221C
        internal void OnFetchPlatformInfoSuccess(PlatformInfo platformInfo)
        {
            CdnDomains = platformInfo.cdn_list;
            ServerListURLs = platformInfo.server_list;
        }

        // RVA: 0x1887A90
        internal void OnFetchVersionSuccess(string resVer)
        {
            ResVersion = resVer;
            if (onFetchVersionSuccess != null)
            {
                onFetchVersionSuccess();
            }
        }

        // RVA: 0x1892324
        internal void OnUpdateApplication(VersionManifestKc version)
        {
            if (onUpdateApplication == null)
            {
                return;
            }

            onUpdateApplication(update =>
            {
                if (update && version != null)
                {
                    Debug.LogWarning("open url " + version.appUrl);
                    Application.OpenURL(version.appUrl);
                    return;
                }
                if (OzSDKManager.Instance != null)
                {
                    OzSDKManager.Instance.Quit();
                }
            });
        }

        // RVA: 0x1887A2C
        internal void OnFetchVersionFailed()
        {
            if (onFetchVersionFailed != null)
            {
                onFetchVersionFailed();
            }
        }

        // RVA: 0x18825E4
        internal void OnBeginCheckExtract()
        {
            if (onCheckExtractBegin != null)
            {
                onCheckExtractBegin();
            }
        }

        // RVA: 0x1883284
        internal void OnCheckExtractSkip(IPackageManifest manifest, List<IPackageInfo> extractList)
        {
            Manifest = manifest;
            ExtractList = extractList;

            if (onCheckExtractSkip != null)
            {
                onCheckExtractSkip();
            }
        }

        // RVA: 0x1883368
        internal void OnCheckExtractComplete(IPackageManifest manifest, List<IPackageInfo> extractList)
        {
            Manifest = manifest;
            ExtractList = extractList;

            if (onCheckExtractSuccess != null)
            {
                onCheckExtractSuccess(extractList.Count > 0);
            }
        }

        // RVA: 0x1883210
        internal void OnCheckExtractFailed(StateCheckExtract.FailedReason error)
        {
            if (onCheckExtractFailed != null)
            {
                onCheckExtractFailed(error);
            }
        }

        // RVA: 0x1886730
        internal void OnBeginExtract()
        {
            if (onExtractBegin != null)
            {
                onExtractBegin();
            }
        }

        // RVA: 0x1886C58
        internal void OnExtractError(string error)
        {
            if (onExtractError != null)
            {
                onExtractError(error);
            }
        }

        // RVA: 0x18874F0
        internal void OnExtractSuccess()
        {
            if (onExtractSuccess != null)
            {
                onExtractSuccess();
            }
        }

        // RVA: 0x1886D20
        internal void OnExtractProgress(float progress)
        {
            if (onExtractProgress != null)
            {
                onExtractProgress(progress);
            }
        }

        // RVA: 0x188370C
        internal void OnBeginCheckUpdate()
        {
            if (onCheckUpdateBegin != null)
            {
                onCheckUpdateBegin();
            }
        }

        // RVA: 0x18850DC
        internal void OnCheckUpdateComplete(
            IPackageManifest manifestOnCdn,
            List<IPackageInfo> updateList,
            List<IPackageInfo> deleteList)
        {
            Manifest = manifestOnCdn;
            UpdateList = updateList;
            DeleteList = deleteList;

            if (updateList.Count < 1)
            {
                if (onCheckUpdateSkip != null)
                {
                    onCheckUpdateSkip(deleteList.Count > 0);
                }
                return;
            }

            if (onCheckUpdateSuccess != null)
            {
                onCheckUpdateSuccess(updateList.Sum(info => (long)info.Size));
            }
        }

        // RVA: 0x1883CBC
        internal void OnCheckUpdateError(StateCheckUpdate.FailedReason error)
        {
            if (onCheckUpdateFailed != null)
            {
                onCheckUpdateFailed(error);
            }
        }

        // RVA: 0x1888168
        internal void OnBeginUpdate()
        {
            if (onUpdateBegin != null)
            {
                onUpdateBegin();
            }
        }

        // RVA: 0x1888384
        internal void OnUpdateError(string error)
        {
            if (onUpdateError != null)
            {
                onUpdateError(error);
            }
        }

        // RVA: 0x1889928
        internal void OnUpdateFailure()
        {
            if (onUpdateFailed != null)
            {
                onUpdateFailed();
            }
        }

        // RVA: 0x188993C
        internal void OnUpdateChangeCarrierDataNetwork(ulong size)
        {
            if (onUpdateChangeCarrierDataNetwork != null)
            {
                onUpdateChangeCarrierDataNetwork(size);
            }
        }

        // RVA: 0x1889914
        internal void OnUpdateSuccess()
        {
            if (onUpdateSuccess != null)
            {
                onUpdateSuccess();
            }
        }

        // RVA: 0x18881A8
        internal void OnUpdateProgress(ulong receivedBytes, ulong totalBytes)
        {
            if (onUpdateProgress != null)
            {
                onUpdateProgress(receivedBytes, totalBytes);
            }
        }

        // RVA: 0x1888270
        internal void OnUpdateSpeed(ulong receivedBytesPerSecond)
        {
            if (onUpdateSpeed != null)
            {
                onUpdateSpeed(receivedBytesPerSecond);
            }
        }

        // RVA: 0x1886034
        internal void OnBeginClearResource()
        {
            if (onCleanResourceBegin != null)
            {
                onCleanResourceBegin();
            }
        }

        // RVA: 0x18863AC
        internal void OnCleanSuccess()
        {
            if (onCleanSuccess != null)
            {
                onCleanSuccess();
            }
        }

        // RVA: 0x18864B0
        internal void OnComplete()
        {
            if (onComplete != null)
            {
                onComplete();
            }

            if (ExtractList != null)
            {
                ExtractList.Clear();
            }
            ExtractList = null;

            if (UpdateList != null)
            {
                UpdateList.Clear();
            }
            UpdateList = null;

            if (DeleteList != null)
            {
                DeleteList.Clear();
            }
            DeleteList = null;
        }
        // RVA: 0x188DA18
        public void Begin()
        {
            CdnDomains = AppConst.CdnDomains;
            ServerListURLs = AppConst.ServerListURLs;
            NoticeKey = "off";
            PatchInfo = new PatchInfo { version = 0, path = string.Empty };

            State<eProcedure>[] states = new State<eProcedure>[8];
            states[1] = new StateCheckExtractKc(this);
            states[2] = new StateExtractResources(this);
            states[0] = new StateFetchVersion(this);
            states[3] = new StateCheckUpdateKc(this);
            states[4] = new StateUpdateResourcesKc(this);
            states[5] = new StateCleanResources(this);
            states[6] = new StateComplete(this);
            states[7] = new StateQuit(this);

            m_Procedure = new StateMachine<eProcedure, eCommand>(states);

            if (!AppConst.AssetBundleMode)
            {
                m_Procedure.Begin(eProcedure.Complete);
                return;
            }

            m_Procedure.AddTransition(eProcedure.CheckExtract, eProcedure.ExtractResources, eCommand.Success);
            m_Procedure.AddTransition(eProcedure.CheckExtract, eProcedure.FetchVersion, eCommand.Failed);
            m_Procedure.AddTransition(eProcedure.CheckExtract, eProcedure.CheckExtract, eCommand.Retry);

            m_Procedure.AddTransition(eProcedure.ExtractResources, eProcedure.FetchVersion, eCommand.Success);
            m_Procedure.AddTransition(eProcedure.ExtractResources, eProcedure.CheckExtract, eCommand.Retry);

            m_Procedure.AddTransition(eProcedure.FetchVersion, eProcedure.Complete, eCommand.Skip);
            m_Procedure.AddTransition(eProcedure.FetchVersion, eProcedure.CheckUpdate, eCommand.Success);
            m_Procedure.AddTransition(eProcedure.FetchVersion, eProcedure.FetchVersion, eCommand.Retry);
            m_Procedure.AddTransition(eProcedure.FetchVersion, eProcedure.Quit, eCommand.Cancel);

            m_Procedure.AddTransition(eProcedure.CheckUpdate, eProcedure.UpdateResources, eCommand.Success);
            m_Procedure.AddTransition(eProcedure.CheckUpdate, eProcedure.CleanResources, eCommand.SkipToDelete);
            m_Procedure.AddTransition(eProcedure.CheckUpdate, eProcedure.Complete, eCommand.Skip);
            m_Procedure.AddTransition(eProcedure.CheckUpdate, eProcedure.FetchVersion, eCommand.Retry);
            m_Procedure.AddTransition(eProcedure.CheckUpdate, eProcedure.Quit, eCommand.Cancel);

            m_Procedure.AddTransition(eProcedure.UpdateResources, eProcedure.CleanResources, eCommand.Success);
            m_Procedure.AddTransition(eProcedure.UpdateResources, eProcedure.UpdateResources, eCommand.Retry);
            m_Procedure.AddTransition(eProcedure.UpdateResources, eProcedure.Quit, eCommand.Cancel);

            m_Procedure.AddTransition(eProcedure.CleanResources, eProcedure.Complete, eCommand.Success);

            m_Procedure.Begin(eProcedure.CheckExtract);
        }

        // RVA: 0x188E24C
        public void Update()
        {
            if (m_Procedure != null)
            {
                m_Procedure.Update();
            }
        }

        // RVA: 0x18923F0
        public void End()
        {
            if (m_Procedure != null)
            {
                m_Procedure.End();
            }
            m_Procedure = null;
        }

        // RVA: 0x188F9D8
        public void Trigger(eCommand command)
        {
            if (m_Procedure != null)
            {
                m_Procedure.Trigger(command);
            }
        }

        // RVA: 0x189244C
        public static bool IsVersionWrong(string cndVersion)
        {
            int appMajor = int.Parse(Application.version.Split('.')[0]);
            return appMajor < int.Parse(cndVersion.Split('.')[0]);
        }

        // RVA: 0x1892564
        public VersionControl()
        {
        }

        // RVA: 0x189256C
        static VersionControl()
        {
        }
    }
}
