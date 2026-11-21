// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  OptionalDownload
//  来源：Il2CppDumper 元数据 + 反汇编（0x16A66F0 起）
// =============================================================================

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Kc.Config;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Download;
using Oz.GameKit.Version;
using Oz.Utility;
using UnityEngine;

/// <summary>可选资源（CDN）下载管理：分组、进度、失败重试与本地缓存校验。</summary>
public class OptionalDownload : MonoBehaviour
{
    public static OptionalDownload Instance { get; set; }
    private string m_CdnUri;
    private int m_RetryCount;
    private bool notWifiDownload;
    private HashSet<OptionalDownloadInfo> downloadDic;
    private HashSet<OptionalDownloadGroup> downloadGroup;



    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }

        if (downloadGroup == null)
        {
            downloadGroup = new HashSet<OptionalDownloadGroup>();
        }

        if (downloadDic == null)
        {
            downloadDic = new HashSet<OptionalDownloadInfo>();
        }

        m_RetryCount = 0;
    }

    private void Start()
    {
        DownloadManager.OnDownloadSuccess += OnDownloadSuccess;
        DownloadManager.OnDownloadProgress += OnDownloadProgress;
        DownloadManager.OnDownloadResume += OnDownloadResume;
        DownloadManager.OnDownloadFailure += OnDownloadError;
    }

    private void OnDestroy()
    {
        DownloadManager.OnDownloadSuccess -= OnDownloadSuccess;
        DownloadManager.OnDownloadProgress -= OnDownloadProgress;
        DownloadManager.OnDownloadResume -= OnDownloadResume;
        DownloadManager.OnDownloadFailure -= OnDownloadError;
    }

    public void Update()
    {
        if (downloadDic.Count > 0 && !notWifiDownload && !NetworkUtil.IsWifi && NetworkUtil.NetAvailable)
        {
            OnDownloadError(new DownloadFailureArg { Error = "notWifi" });
        }
    }

    public int RequestOptionalDownload(string[] bundleNames, Action<float, string> progressCallback,
        Action finishCallback, Action<string> errorCallback, bool isFirst = false)
    {
        HashSet<OptionalDownloadGroup> stopped = new HashSet<OptionalDownloadGroup>();
        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            if (group.isStop)
            {
                stopped.Add(group);
            }
        }

        foreach (OptionalDownloadGroup group in stopped)
        {
            downloadGroup.Remove(group);
        }

        notWifiDownload = !NetworkUtil.IsWifi;

        List<string> downloading = new List<string>();
        if (isFirst)
        {
            foreach (OptionalDownloadInfo info in downloadDic)
            {
                DownloadManager.Cancel(info.taskHandle);
                downloading.Add(info.name);
            }

            downloadDic.Clear();
        }

        if (VersionControl.Manifest == null)
        {
            return 0;
        }

        m_CdnUri = KcAppSetting.CDNURL;

        HashSet<string> needDown = new HashSet<string>();
        for (int i = 0; i < bundleNames.Length; i++)
        {
            if (!CheckBundleExist(bundleNames[i].ToString()))
            {
                needDown.Add(bundleNames[i].ToString());
            }
        }

        HashSet<string> finishDown = new HashSet<string>();
        List<string> allNames = new List<string>(needDown);

        foreach (string name in downloading)
        {
            if (!allNames.Contains(name))
            {
                allNames.Add(name);
            }
        }

        ulong totalSize = 0;
        foreach (string name in allNames)
        {
            IPackageInfoKc info = VersionControl.Manifest.GetPackageInfo(name) as IPackageInfoKc;

            if (Enumerable.Contains(bundleNames, name))
            {
                IPackageInfo sizeInfo;
                if (VersionControl.Manifest.TryGetPackageInfo(name, out sizeInfo))
                {
                    totalSize += sizeInfo.Size;
                }
            }

            if (CheckDownloadExit(name))
            {
                continue;
            }

            string version = info.Version;
            string downloadPath = info.GetDownloadPath(version);
            string uri = Path.Combine(m_CdnUri, downloadPath);
            string savePath = Path.Combine(
                PathUtility.GetPersistentDataPath(),
                VersionControl.Manifest.GetPackageFilePath(name));

            IPackageInfo packageInfo;
            if (!VersionControl.Manifest.TryGetPackageInfo(name, out packageInfo))
            {
                continue;
            }

            ulong size = packageInfo.Size;
            string checkSum = VersionControl.Manifest.GetPackageHash(name);
            TaskHandle handle = DownloadManager.Request(uri, savePath, size, 3f, checkSum, packageInfo);
            downloadDic.Add(new OptionalDownloadInfo(name, handle));
        }

        OptionalDownloadGroup newGroup = new OptionalDownloadGroup(
            totalSize,
            0,
            needDown,
            finishDown,
            finishCallback,
            errorCallback,
            progressCallback);
        downloadGroup.Add(newGroup);
        return newGroup.id;
    }

    public void ContinueDownload()
    {
        notWifiDownload = !NetworkUtil.IsWifi;

        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            HashSet<string> finishSet = new HashSet<string>();
            ulong downloadedSize = 0;

            foreach (string name in group.needDown)
            {
                string bundleName = name.ToString();

                if (CheckBundleExist(bundleName))
                {
                    downloadedSize += VersionControl.Manifest.GetPackageSize(bundleName);
                    finishSet.Add(name);
                    continue;
                }

                if (CheckDownloadExit(bundleName))
                {
                    continue;
                }

                IPackageInfoKc info = VersionControl.Manifest.GetPackageInfo(name) as IPackageInfoKc;
                if (info == null)
                {
                    continue;
                }

                string version = info.Version;
                string downloadPath = info.GetDownloadPath(version);
                string uri = Path.Combine(m_CdnUri, downloadPath);
                string savePath = Path.Combine(
                    PathUtility.GetPersistentDataPath(),
                    VersionControl.Manifest.GetPackageFilePath(name));

                ulong size = VersionControl.Manifest.GetPackageSize(name);
                string checkSum = VersionControl.Manifest.GetPackageHash(name);
                IPackageInfo packageInfo = VersionControl.Manifest.GetPackageInfo(name);

                TaskHandle handle = DownloadManager.Request(uri, savePath, size, 3f, checkSum, packageInfo);
                downloadDic.Add(new OptionalDownloadInfo(name, handle));
            }

            group.finishDown = finishSet;
            group.isStop = false;
            group.curDownloadSize = downloadedSize;
        }
    }

    public void CancleContinueDownload()
    {
        downloadGroup.Clear();
        downloadDic.Clear();
    }

    private void OnDownloadResume(TaskHandle handle, object userData, ulong receivedLength)
    {
        IPackageInfo packageInfo = userData as IPackageInfo;

        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            if (group.needDown.Contains(packageInfo.Name))
            {
                group.curDownloadSize += receivedLength;
                group.UpdateProgress();
            }
        }
    }

    private void OnDownloadProgress(TaskHandle handle, object userData, ulong receivedLength)
    {
        IPackageInfo packageInfo = userData as IPackageInfo;

        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            if (group.needDown.Contains(packageInfo.Name))
            {
                group.curDownloadSize += receivedLength;
                group.UpdateProgress();
            }
        }
    }

    private void OnDownloadError(DownloadFailureArg arg)
    {
        foreach (OptionalDownloadInfo info in downloadDic)
        {
            DownloadManager.Cancel(info.taskHandle);
        }

        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            group.OnError(arg.Error);
            group.isStop = true;
        }

        m_RetryCount++;
        downloadDic.Clear();
    }

    private void OnDownloadSuccess(TaskHandle handle, object userData)
    {
        IPackageInfo packageInfo = userData as IPackageInfo;

        if (packageInfo != null)
        {
            string hashPath = Path.Combine(PathUtility.GetPersistentDataPath(), packageInfo.GetFilePath()) + ".hash";
            File.WriteAllText(hashPath, packageInfo.Hash);
        }

        OptionalDownloadInfo finished = null;
        foreach (OptionalDownloadInfo info in downloadDic)
        {
            if (info.name == packageInfo.Name)
            {
                finished = info;
                break;
            }
        }

        if (finished != null)
        {
            downloadDic.Remove(finished);
        }

        List<OptionalDownloadGroup> completedGroups = new List<OptionalDownloadGroup>();
        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            if (group.needDown.Contains(packageInfo.Name))
            {
                group.finishDown.Add(packageInfo.Name);

                if (group.needDown.Count == group.finishDown.Count)
                {
                    if (group.successCallback != null)
                    {
                        group.successCallback();
                    }

                    completedGroups.Add(group);
                }
            }
        }

        foreach (OptionalDownloadGroup group in completedGroups)
        {
            downloadGroup.Remove(group);
        }

        if (downloadGroup.Count == 0)
        {
            m_RetryCount = 0;
            downloadDic.Clear();
            downloadGroup.Clear();
        }
    }

    public void CancelOptionalDownload(int id)
    {
        OptionalDownloadGroup target = null;
        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            if (group.id == id)
            {
                target = group;
                break;
            }
        }

        if (target != null)
        {
            foreach (string name in target.needDown)
            {
                OptionalDownloadInfo found = null;
                foreach (OptionalDownloadInfo info in downloadDic)
                {
                    if (info.name == name)
                    {
                        found = info;
                        break;
                    }
                }

                if (found != null)
                {
                    DownloadManager.Cancel(found.taskHandle);
                    downloadDic.Remove(found);
                }
            }

            downloadGroup.Remove(target);
        }

        if (downloadDic.Count == 0)
        {
            downloadGroup.Clear();
            downloadDic.Clear();
        }

        m_RetryCount = 0;
    }

    public void AddCallback(int groupId, Action successCallback, Action<string> errorCallback,
        Action<float, string> progressCallback)
    {
        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            if (group.id == groupId)
            {
                group.successCallback = successCallback;
                group.errorCallback = errorCallback;
                group.progressCallback = progressCallback;
            }
        }
    }

    public void RemoveCallback(int groupId)
    {
        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            if (group.id == groupId)
            {
                group.successCallback = null;
                group.errorCallback = null;
                group.progressCallback = null;
            }
        }
    }

    public bool CheckIsDownload(int groupId)
    {
        foreach (OptionalDownloadGroup group in downloadGroup)
        {
            if (group.id == groupId && !group.isStop)
            {
                return true;
            }
        }

        return false;
    }

    public string GetOptionalDownloadSize(string[] bundleNames)
    {
        HashSet<string> names = new HashSet<string>();

        for (int i = 0; i < bundleNames.Length; i++)
        {
            if (!CheckBundleExist(bundleNames[i].ToString()))
            {
                names.Add(bundleNames[i].ToString());
            }
        }

        ulong size = 0;
        foreach (string name in names)
        {
            IPackageInfo info;
            if (VersionControl.Manifest.TryGetPackageInfo(name, out info))
            {
                size += info.Size;
            }
        }

        return ByteSizeToString(size);
    }

    private string ByteSizeToString(ulong size)
    {
        if (size <= 0x3FF)
        {
            return string.Format("{0}(B)", size);
        }

        if ((size >> 20) == 0)
        {
            return string.Format("{0:F1}(KB)", size / 1024f);
        }

        return string.Format("{0:F2}(MB)", size / 1048576f);
    }

    public bool DelectExistAsset(string[] bundleNames)
    {
        if (downloadDic.Count != 0)
        {
            return false;
        }

        if (VersionControl.Manifest == null)
        {
            return true;
        }

        for (int i = 0; i < bundleNames.Length; i++)
        {
            string filePath = VersionControl.Manifest.GetPackageFilePath(bundleNames[i].ToString());
            string hashPath = Path.Combine(PathUtility.GetPersistentDataPath(), filePath) + ".hash";

            if (File.Exists(hashPath))
            {
                File.Delete(hashPath);
            }

            string path = Path.Combine(PathUtility.GetPersistentDataPath(), filePath);
            if (File.Exists(path))
            {
                File.Delete(path);
            }
        }

        return true;
    }

    public string GetOptionalAlreadyDownloadSize(string[] bundleNames)
    {
        HashSet<string> names = new HashSet<string>();

        for (int i = 0; i < bundleNames.Length; i++)
        {
            if (CheckBundleExist(bundleNames[i].ToString()))
            {
                names.Add(bundleNames[i].ToString());
            }
        }

        ulong size = 0;
        foreach (string name in names)
        {
            IPackageInfo info;
            if (VersionControl.Manifest.TryGetPackageInfo(name, out info))
            {
                size += info.Size;
            }
        }

        return ByteSizeToString(size);
    }

    public bool CheckBundleExist(string bundleName)
    {
        if (VersionControl.Manifest == null)
        {
            return false;
        }

        string filePath = VersionControl.Manifest.GetPackageFilePath(bundleName);
        string hash = VersionControl.Manifest.GetPackageHash(bundleName);
        string hashPath = Path.Combine(PathUtility.GetPersistentDataPath(), filePath) + ".hash";

        if (File.Exists(hashPath))
        {
            return File.ReadAllText(hashPath) == hash;
        }

        IPackageInfo info = VersionControl.Manifest.GetPackageInfo(bundleName);
        return info.HasFlag(ePackageFlag.local);
    }

    public bool CheckBundleExist(string[] bundleNames)
    {
        if (VersionControl.Manifest == null)
        {
            return false;
        }

        for (int i = 0; i < bundleNames.Length; i++)
        {
            string bundleName = bundleNames[i].ToString();
            string filePath = VersionControl.Manifest.GetPackageFilePath(bundleName);
            string hash = VersionControl.Manifest.GetPackageHash(bundleName);
            string path = Path.Combine(PathUtility.GetPersistentDataPath(), filePath);

            if (!File.Exists(path))
            {
                return false;
            }

            if (File.ReadAllText(path + ".hash") != hash)
            {
                return false;
            }
        }

        return true;
    }

    public bool CheckDownloadExit(string name)
    {
        foreach (OptionalDownloadInfo info in downloadDic)
        {
            if (info.name == name)
            {
                return true;
            }
        }

        return false;
    }

    public OptionalDownload()
    {
    }
}
