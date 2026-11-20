// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateUpdateResourcesKc
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Download：空列表直接回调 onUpdateSuccess；UseSecrityAsset 时经 gRPC
//        取签名地址（回调 OnAssetUrlsResponse），否则直接入队 DownloadManager.Request。
// =============================================================================

using System.Collections.Generic;
using System.IO;
using System.Linq;
using ICSharpCode.SharpZipLib.Zip.Compression.Streams;
using Kc.Config;
using Oz.Framework.NetworkModule;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Download;
using Oz.Utility;
using UnityEngine;

namespace Oz.GameKit.Version
{
    public class StateUpdateResourcesKc : StateUpdateResources
    {
        // RVA: 0x188A3FC
        public StateUpdateResourcesKc(VersionControl versionControl)
            : base(versionControl)
        {
        }

        // RVA: 0x188A400
        private byte[] DeflateDeCompress(byte[] sourceByte)
        {
            MemoryStream input = new MemoryStream(sourceByte);
            MemoryStream output = new MemoryStream();

            using (InflaterInputStream inflater = new InflaterInputStream(input))
            {
                inflater.CopyTo(output);
            }

            byte[] result = output.ToArray();
            input.Close();
            output.Close();
            return result;
        }

        // RVA: 0x188A5B4
        public override void Download(List<IPackageInfo> updateList)
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

        // RVA: 0x188AFF0
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
    }
}
