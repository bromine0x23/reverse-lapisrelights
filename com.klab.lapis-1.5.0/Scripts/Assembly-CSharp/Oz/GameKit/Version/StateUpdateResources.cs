// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateUpdateResources
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Enter 订阅 DownloadManager 事件后调用 Download(UpdateList)；
//        OnUpdateSuccess 把 VersionControl.Manifest 写回持久化目录并清标记。
// =============================================================================

using System.Collections.Generic;
using System.IO;
using Oz.GameFramework.Runtime;
using Oz.Framework.NetworkModule;
using Kc.Config;
using System.Linq;
using Oz.GameFramework.Runtime.Download;
using Oz.Utility;
using UnityEngine;

namespace Oz.GameKit.Version
{
    public class StateUpdateResources : State<eProcedure>
    {
        protected VersionControl m_VersionControl;
        protected string m_CdnUri;
        protected ulong m_TotalDownloadBytes;
        protected ulong m_ReceivedBytes;
        private int m_RetryCount;
        protected HashSet<TaskHandle> m_TaskHandles;
        protected HashSet<string> m_FinishedPackageName;
        protected bool m_bNotWifiDownload;
        // RVA: 0x1887EDC
        public StateUpdateResources(VersionControl versionControl)
            : base(eProcedure.UpdateResources)
        {
            m_RetryCount = -1;
            m_TaskHandles = new HashSet<TaskHandle>();
            m_VersionControl = versionControl;
            m_FinishedPackageName = new HashSet<string>();
        }

        // RVA: 0x1887F9C
        public override void Enter(eProcedure previousState)
        {
            if (m_VersionControl.onUpdateBegin != null)
            {
                m_VersionControl.onUpdateBegin();
            }

            DownloadManager.onDownloadProgress += OnDownloadProgress;
            DownloadManager.onDownloadResume += OnDownloadResume;
            DownloadManager.onDownloadSuccess += OnDownloadSuccess;
            DownloadManager.onDownloadFailure += OnDownloadError;

            Download(m_VersionControl.UpdateList);
        }

        // RVA: 0x188817C
        private void OnDownloadResume(TaskHandle handle, object userData, ulong receivedLength)
        {
            m_ReceivedBytes += receivedLength;
            m_VersionControl.OnUpdateProgress(m_ReceivedBytes, m_TotalDownloadBytes);
        }

        // RVA: 0x1888224
        private void OnDownloadProgress(TaskHandle handle, object userData, ulong receivedLength)
        {
            m_VersionControl.OnUpdateSpeed(receivedLength);
            m_ReceivedBytes += receivedLength;
            m_VersionControl.OnUpdateProgress(m_ReceivedBytes, m_TotalDownloadBytes);
        }

        // RVA: 0x18882E4
        protected void OnDownloadError(DownloadFailureArg arg)
        {
            Debug.LogError(arg.Error);
            Debug.LogError(arg.UriString);

            m_VersionControl.OnUpdateError(arg.Error);
            OnUpdateFailure();
        }
        // RVA: 0x1888550
        protected void OnDownloadSuccess(TaskHandle handle, object userData)
        {
            IPackageInfo info = userData as IPackageInfo;
            if (info != null)
            {
                string path = Path.Combine(PathUtility.GetPersistentDataPath(), info.GetFilePath());
                File.WriteAllText(path + ".hash", info.Hash);

                string name = info.Name;
                if (name == SqlLiteSupport.MasterTableName || name == SqlLiteSupport.MasterTableLangName)
                {
                    MasterDataInfo masterData = (MasterDataInfo)info;
                    string key = name == SqlLiteSupport.MasterTableName
                        ? KlabVfs.MASTER_KEY
                        : KlabVfs.MASTER_LANG_KEY;
                    KlabVfs.Deflate(path, masterData.KeyList, key);
                }

                if (!string.IsNullOrEmpty(info.Name))
                {
                    m_FinishedPackageName.Add(info.Name);
                }
            }

            if (!m_TaskHandles.Remove(handle))
            {
                return;
            }

            if (m_TaskHandles.Count == 0)
            {
                OnUpdateSuccess();
            }
        }

        // RVA: 0x1888E14
        public override void Exit(eProcedure nextState)
        {
            DownloadManager.onDownloadSuccess -= OnDownloadSuccess;
            DownloadManager.onDownloadProgress -= OnDownloadProgress;
            DownloadManager.onDownloadResume -= OnDownloadResume;
            DownloadManager.onDownloadFailure -= OnDownloadError;
        }

        // RVA: 0x1888F68
        public override void Update()
        {
            if (m_TaskHandles.Count != 0 && !m_bNotWifiDownload && NetworkUtil.IsCarrier())
            {
                OnUpdateChangeCarrierDataNetwork();
            }
        }
        // RVA: 0x1889134
        public virtual void Download(List<IPackageInfo> updateList)
        {
            if (updateList.Count < 1)
            {
                if (m_VersionControl.onUpdateSuccess != null)
                {
                    m_VersionControl.onUpdateSuccess();
                }
                return;
            }

            m_bNotWifiDownload = NetworkUtil.IsCarrier();

            if (KcAppSetting.UseSecrityAsset)
            {
                string[] hashes = updateList.Select(t => ((IPackageInfoKc)t).ShortHash).ToArray();
                Dispatcher.Instance.AddCSharpObserver(
                    Dispatcher.EventType.GetAssetUrl,
                    new Dispatcher.CshapreMessage(this, OnAssetUrlsResponse));
                NetworkManager.GrpcGate.SendPackUrlRequest(hashes, VersionControl.ResVersion);
                return;
            }

            foreach (IPackageInfo item in updateList)
            {
                IPackageInfoKc info = item as IPackageInfoKc;
                string uri = Path.Combine(m_CdnUri, info.GetDownloadPath(info.Version)).Replace("\\", "/");
                string savePath = Path.Combine(PathUtility.GetPersistentDataPath(), item.GetFilePath());

                m_TotalDownloadBytes += info.Size;
                if (m_FinishedPackageName.Contains(info.Name))
                {
                    m_ReceivedBytes += info.Size;
                }
                else
                {
                    m_TaskHandles.Add(DownloadManager.Request(
                        uri, savePath, info.Size, 5f, info.Hash, item));
                }
            }
        }

        // RVA: 0x1889C0C
        internal void OnAssetUrlsResponse(bool success, object obj)
        {
            Dispatcher.Instance.RemoveCSharpObserver(Dispatcher.EventType.GetAssetUrl);

            if (!success)
            {
                OnDownloadError(new DownloadFailureArg { Error = "Can not Getted Download url" });
                return;
            }

            List<IPackageInfo> updateList = m_VersionControl.UpdateList;
            Dictionary<string, IPackageInfoKc> packages = updateList
                .ToDictionary(info => info.Name, info => (IPackageInfoKc)info);

            if (!(obj is Game.AssetUrlsResponse response))
            {
                return;
            }

            string hostName = response.HostName;
            Google.Protobuf.Collections.RepeatedField<Game.SignedURL> urls = response.Urls;

            for (int i = 0; i < urls.Count; i++)
            {
                Game.SignedURL signed = urls[i];
                if (!packages.ContainsKey(signed.PackHash))
                {
                    continue;
                }

                IPackageInfoKc info = packages[signed.PackHash];
                string uri = Path.Combine(hostName, info.GetDownloadPath(info.Version)).Replace("\\", "/");
                string savePath = Path.Combine(PathUtility.GetPersistentDataPath(), info.GetFilePath());

                m_TotalDownloadBytes += info.Size;
                if (m_FinishedPackageName.Contains(info.Name))
                {
                    m_ReceivedBytes += info.Size;
                }
                else
                {
                    m_TaskHandles.Add(DownloadManager.Request(
                        uri, savePath, info.Size, 5f, info.Hash, info));
                }
            }
        }

        // RVA: 0x1888BAC
        private void OnUpdateSuccess()
        {
            string manifestPath = Path.Combine(PathUtility.GetPersistentDataPath(), "manifest.xml");
            using (Stream stream = File.Open(manifestPath, FileMode.Create))
            {
                PackageManifest.Serializer.WriteToStream(VersionControl.Manifest, stream);
            }

            string forceUpdatePath = Path.Combine(PathUtility.GetPersistentDataPath(), "forceupdate");
            if (File.Exists(forceUpdatePath))
            {
                File.Delete(forceUpdatePath);
            }

            m_RetryCount = 0;
            m_FinishedPackageName.Clear();

            if (m_VersionControl.onUpdateSuccess != null)
            {
                m_VersionControl.onUpdateSuccess();
            }
        }

        // RVA: 0x18883F8
        private void OnUpdateFailure()
        {
            foreach (TaskHandle handle in m_TaskHandles)
            {
                DownloadManager.Cancel(handle);
            }
            m_TaskHandles.Clear();

            if (m_VersionControl.onUpdateFailed != null)
            {
                m_VersionControl.onUpdateFailed();
            }
        }

        // RVA: 0x1888FE0
        private void OnUpdateChangeCarrierDataNetwork()
        {
            foreach (TaskHandle handle in m_TaskHandles)
            {
                DownloadManager.Cancel(handle);
            }
            m_TaskHandles.Clear();

            m_VersionControl.OnUpdateChangeCarrierDataNetwork(m_TotalDownloadBytes - m_ReceivedBytes);
        }
    }
}
