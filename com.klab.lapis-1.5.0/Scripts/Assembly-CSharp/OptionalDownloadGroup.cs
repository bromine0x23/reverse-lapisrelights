// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  OptionalDownloadGroup
//  来源：Il2CppDumper 元数据 + 反汇编（0x16A8090 起）
// =============================================================================

using System;
using System.Collections.Generic;

/// <summary>一次可选资源下载请求的分组状态与回调。</summary>
public class OptionalDownloadGroup
{
    private static int totalId;

    public int id;
    public HashSet<string> needDown;
    public HashSet<string> finishDown;
    public ulong curDownloadSize;
    public ulong totalSize;
    public Action successCallback;
    public Action<string> errorCallback;
    public Action<float, string> progressCallback;
    public bool isStop;

    public OptionalDownloadGroup(ulong totalSize, ulong curDownloadSize,
        HashSet<string> needDown, HashSet<string> finishDown,
        Action successCallback, Action<string> errorCallback,
        Action<float, string> progressCallback)
    {
        id = ++totalId;
        this.curDownloadSize = curDownloadSize;
        this.totalSize = totalSize;
        this.needDown = needDown;
        this.finishDown = finishDown;
        this.successCallback = successCallback;
        this.errorCallback = errorCallback;
        this.progressCallback = progressCallback;
    }

    public void UpdateProgress()
    {
        if (progressCallback == null)
        {
            return;
        }

        ulong current = curDownloadSize > totalSize ? totalSize : curDownloadSize;
        string currentText = ByteSizeToString(current);
        string totalText = ByteSizeToString(totalSize);
        progressCallback((float)current / totalSize, currentText + "/" + totalText);
    }

    public void OnError(string errorStr)
    {
        if (errorCallback != null)
        {
            errorCallback(errorStr);
        }
    }

    public void OnSuccess()
    {
        if (successCallback != null)
        {
            successCallback();
        }
    }

    public void RemoveCallback()
    {
        successCallback = null;
        errorCallback = null;
        progressCallback = null;
    }

    public void AddCallback(Action successCallback, Action<string> errorCallback,
        Action<float, string> progressCallback)
    {
        this.successCallback = successCallback;
        this.errorCallback = errorCallback;
        this.progressCallback = progressCallback;
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
}
