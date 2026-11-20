// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateExtractResources
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using System.IO;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Download;
using Oz.Utility;
using UnityEngine;

namespace Oz.GameKit.Version
{
    /// <summary>
    /// 解压内嵌资源：订阅下载事件，把 ExtractList 中的包交给 DownloadManager
    /// 解压，并按已接收字节数上报进度。
    /// </summary>
    public class StateExtractResources : State<eProcedure>
    {
        private VersionControl m_VersionControl;
        private ulong m_TotalExtractBytes;
        private ulong m_ReceivedBytes;
        private HashSet<TaskHandle> m_TaskHandles;

        // RVA: 0x1886554
        public StateExtractResources(VersionControl versionControl) : base(eProcedure.ExtractResources)
        {
            m_VersionControl = versionControl;
            m_TaskHandles = new HashSet<TaskHandle>();
        }

        // RVA: 0x18865E4
        public override void Enter(eProcedure previousState)
        {
            if (m_VersionControl.onExtractBegin != null)
            {
                m_VersionControl.onExtractBegin();
            }

            DownloadManager.onDownloadSuccess += OnExtractSuccess;
            DownloadManager.onDownloadProgress += OnExtractProgress;
            DownloadManager.onDownloadFailure += OnExtractError;

            Extract(m_VersionControl.ExtractList);
        }

        // RVA: 0x18872D8
        public override void Exit(eProcedure nextState)
        {
            DownloadManager.onDownloadSuccess -= OnExtractSuccess;
            DownloadManager.onDownloadProgress -= OnExtractProgress;
            DownloadManager.onDownloadFailure -= OnExtractError;

            foreach (TaskHandle handle in m_TaskHandles)
            {
                DownloadManager.Cancel(handle);
            }
            m_TaskHandles.Clear();
        }

        /// <summary>按累计接收字节 / 总字节上报进度；总字节为 0 时进度恒为 0。</summary>
        // RVA: 0x1886CCC
        private void OnExtractProgress(TaskHandle handle, object userData, ulong dataLength)
        {
            m_ReceivedBytes += dataLength;

            float progress = 0f;
            if (m_TotalExtractBytes != 0)
            {
                progress = (float)m_ReceivedBytes / (float)m_TotalExtractBytes;
            }
            m_VersionControl.OnExtractProgress(progress);
        }

        /// <summary>为 ExtractList 中的每个包发起解压任务，并累计总字节数。</summary>
        // RVA: 0x1886744
        private void Extract(List<IPackageInfo> extractList)
        {
            if (extractList.Count < 1)
            {
                OnExtractComplete();
                return;
            }

            for (int i = 0; i < extractList.Count; i++)
            {
                IPackageInfo info = extractList[i];
                string srcPath = Path.Combine(PathUtility.GetStreamingAssetsURI(), info.GetFilePath());
                string dstPath = Path.Combine(PathUtility.GetPersistentDataPath(), info.GetFilePath());

                m_TaskHandles.Add(DownloadManager.Request(srcPath, dstPath, info.Size, 3f, info.Hash, info));
                m_TotalExtractBytes += info.Size;
            }
        }
        // RVA: 0x1886AFC
        private void OnExtractError(DownloadFailureArg arg)
        {
            foreach (TaskHandle handle in m_TaskHandles)
            {
                DownloadManager.Cancel(handle);
            }
            m_TaskHandles.Clear();

            m_VersionControl.OnExtractError(arg.Error);
        }
        // RVA: 0x1886D94
        private void OnExtractSuccess(TaskHandle handle, object userData)
        {
            if (userData is IPackageInfo info)
            {
                string filePath = Path.Combine(PathUtility.GetPersistentDataPath(), info.GetFilePath());
                File.WriteAllText(filePath + ".hash", info.Hash);
            }

            m_TaskHandles.Remove(handle);
            if (m_TaskHandles.Count == 0)
            {
                OnExtractComplete();
            }
        }
        // RVA: 0x1886F84
        private void OnExtractComplete()
        {
            using (Stream stream = File.Open(
                Path.Combine(PathUtility.GetPersistentDataPath(), "manifest.xml"), FileMode.Create))
            {
                PackageManifest.Serializer.WriteToStream(VersionControl.Manifest, stream);
            }

            using (File.Create(Path.Combine(PathUtility.GetPersistentDataPath(), "forceupdate")))
            {
            }

            VersionControl.ExtractList.Clear();

            if (m_VersionControl.onExtractSuccess != null)
            {
                m_VersionControl.onExtractSuccess();
            }
        }
    }
}
