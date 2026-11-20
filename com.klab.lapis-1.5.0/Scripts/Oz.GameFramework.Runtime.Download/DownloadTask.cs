// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Download.dll
//  Oz.GameFramework.Runtime.Download.DownloadTask
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.IO;
using UnityEngine;

namespace Oz.GameFramework.Runtime.Download
{
    /// <summary>单个下载任务：URL、保存路径、临时文件、校验与重试次数。</summary>
    internal class DownloadTask : Task, ICacheable
    {
        private int m_AutoRetryTimes;

        public Uri Uri { get; private set; }
        public string UriString { get; private set; }
        public string SavePath { get; private set; }
        public string TempPath { get; private set; }
        public ulong Size { get; private set; }
        public string CheckSum { get; private set; }
        public float Timeout { get; private set; }
        public object UserData { get; private set; }
        public bool IsAutoRetry { get; private set; }

        /// <summary>剩余自动重试次数不为 0 即可重试。</summary>
        // RVA: 0x2E9AEAC
        public bool AutoRetry
        {
            get { return m_AutoRetryTimes != 0; }
        }

        // RVA: 0x2E9AFC4
        public DownloadTask()
        {
        }

        /// <summary>
        /// 初始化任务：分配自增句柄，为 URL 追加随机 query（绕过 CDN 缓存），
        /// 临时文件名取 URL 绝对路径的 SHA1。
        /// </summary>
        // RVA: 0x2E9A7B4
        public void Initialize(string uriString, string savePath, ulong size, float timeout, string checkSum,
            object userData, int retryTimes)
        {
            s_TaskHandle++;
            Handle = s_TaskHandle;

            UriString = uriString;
            Uri = MakeRandomQueryUri(uriString);
            SavePath = savePath;
            TempPath = Path.ChangeExtension(
                Path.Combine(Application.persistentDataPath, CryptoUtility.CalcStringHash(Uri.AbsolutePath)),
                ".temp");
            Size = size;
            CheckSum = checkSum;
            Timeout = timeout;
            UserData = userData;
            m_AutoRetryTimes = retryTimes;
            IsAutoRetry = false;
        }

        /// <summary>归还到缓存池前清空全部状态。</summary>
        // RVA: 0x2E9AC78
        public void Reset()
        {
            Handle = TaskHandle.Invaild;
            Uri = null;
            SavePath = string.Empty;
            Timeout = 0f;
            TempPath = string.Empty;
            Size = 0;
            UserData = null;
            m_AutoRetryTimes = 0;
            IsAutoRetry = false;
            CheckSum = string.Empty;
        }

        // RVA: 0x2E9AEBC
        public void ReduceRetryTimes()
        {
            IsAutoRetry = true;
            m_AutoRetryTimes--;
        }

        /// <summary>在 query 后追加 GUID，避免 CDN 命中旧缓存。</summary>
        // RVA: 0x2E9B02C
        private Uri MakeRandomQueryUri(string uri)
        {
            UriBuilder builder = new UriBuilder(uri);
            builder.Query = builder.Query + Guid.NewGuid().ToString();
            return builder.Uri;
        }
    }
}
