// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Download.dll
//  Oz.GameFramework.Runtime.Download.DownloadExecutor
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//
//  单个下载任务的执行器：UnityWebRequest 流式接收 → 写临时文件 → 校验 → 移动到目标路径。
// =============================================================================

using System;
using System.IO;
using UnityEngine.Networking;

namespace Oz.GameFramework.Runtime.Download
{
    /// <summary>下载执行器（一次处理一个 <see cref="DownloadTask"/>）。</summary>
    internal class DownloadExecutor : IExecutor<DownloadTask>
    {
        private readonly byte[] m_PreallocatedBuffer;
        private readonly int m_FlushThreshold;
        private FileStream m_FileStream;
        private UnityWebRequest m_UnityWebRequest;
        private int m_FlushSize;
        private float m_LastReceiveTime;
        private bool m_IsResume;

        public bool IsDone { get; private set; }

        public DownloadTask Task { get; private set; }

        public event Action<DownloadTask, ulong> onDownloadProgress;
        public event Action<DownloadTask, ulong> onDownloadResume;
        public event Action<DownloadTask> onDownloadSuccess;
        public event Action<DownloadTask, string> onDownloadFailure;

        // RVA: 0x2E98CD8
        public DownloadExecutor()
        {
            m_PreallocatedBuffer = new byte[1024 * 1024];
            m_FlushThreshold = 1024 * 1024;
            Reset();
        }

        // RVA: 0x2E98D48
        public void Reset()
        {
            if (m_UnityWebRequest != null)
            {
                m_UnityWebRequest.Abort();
                m_UnityWebRequest.Dispose();
                m_UnityWebRequest = null;
            }
            if (m_FileStream != null)
            {
                m_FileStream.Close();
                m_FileStream = null;
            }
            Task = null;
            m_IsResume = false;
            IsDone = false;
            m_FlushSize = 0;
            m_LastReceiveTime = 0f;
        }

        /// <summary>
        /// 发起下载：http(s) 且已有临时文件时按 Range 续传；
        /// 临时文件已达目标长度则清空重下。
        /// </summary>
        // RVA: 0x2E98DB4
        public void Start(DownloadTask task)
        {
            IsDone = false;
            Task = task;

            m_UnityWebRequest = UnityWebRequest.Get(task.Uri);
            if (m_UnityWebRequest == null)
            {
                OnError("Start failed");
                return;
            }

            m_FileStream = new FileStream(task.TempPath, FileMode.Append, FileAccess.ReadWrite);

            string scheme = task.Uri.Scheme;
            if (scheme == Uri.UriSchemeHttp || scheme == Uri.UriSchemeHttps)
            {
                if (task.Size != 0)
                {
                    long length = m_FileStream.Length;
                    if (length >= (long)task.Size)
                    {
                        m_FileStream.Seek(0, SeekOrigin.Begin);
                        m_FileStream.SetLength(0);
                    }
                    else if (length != 0)
                    {
                        m_IsResume = true;
                        m_FileStream.Seek(0, SeekOrigin.End);
                        m_UnityWebRequest.SetRequestHeader("Range",
                            string.Format("bytes={0}-{1}", length, task.Size));
                        if (onDownloadResume != null)
                        {
                            onDownloadResume(task, (ulong)length);
                        }
                    }
                }
            }

            m_UnityWebRequest.downloadHandler = new DownloadHandler(this);
            m_UnityWebRequest.disposeDownloadHandlerOnDispose = true;
            m_UnityWebRequest.SendWebRequest();
            m_LastReceiveTime = UnityEngine.Time.realtimeSinceStartup;
        }

        /// <summary>每帧检查完成 / 错误 / 超时。</summary>
        // RVA: 0x2E992D8
        public void Update(float realtimeSinceStartup)
        {
            if (m_UnityWebRequest != null && m_UnityWebRequest.isDone)
            {
                if (!m_UnityWebRequest.isNetworkError && !m_UnityWebRequest.isHttpError
                    && string.IsNullOrEmpty(m_UnityWebRequest.error))
                {
                    OnDownloadComplete();
                    return;
                }
                if (m_UnityWebRequest != null)
                {
                    OnError(m_UnityWebRequest.error);
                    return;
                }
            }

            if (Task != null && realtimeSinceStartup - m_LastReceiveTime > Task.Timeout)
            {
                OnError("Timeout");
            }
        }

        // RVA: 0x2E99578
        private void CreateDirectory(string filePath)
        {
            string directory = Path.GetDirectoryName(filePath);
            if (!Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }
        }

        /// <summary>目标已存在则替换，否则移动（先确保目录存在）。</summary>
        // RVA: 0x2E996AC
        private bool MoveOrReplace(string srcPath, string destPath)
        {
            if (File.Exists(srcPath))
            {
                if (File.Exists(destPath))
                {
                    File.Replace(srcPath, destPath, null);
                }
                else
                {
                    CreateDirectory(destPath);
                    File.Move(srcPath, destPath);
                }
            }
            return true;
        }

        // RVA: 0x2E997FC
        private bool Delete(string path)
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
            return true;
        }

        /// <summary>写入分片；累计超过阈值（1MB）时 flush。</summary>
        // RVA: 0x2E99900
        private bool WriteData(byte[] data, int dataLength)
        {
            if (m_FileStream != null)
            {
                m_FileStream.Write(data, 0, dataLength);
                m_FlushSize += dataLength;
                if (m_FlushSize >= m_FlushThreshold)
                {
                    m_FileStream.Flush();
                    m_FlushSize = 0;
                }
                return true;
            }
            return false;
        }

        /// <summary>接收回调：写盘成功则上报进度，失败则删除临时文件并报错。</summary>
        // RVA: 0x2E99A58
        private bool OnReceiveData(byte[] data, int dataLength)
        {
            m_LastReceiveTime = UnityEngine.Time.realtimeSinceStartup;
            if (WriteData(data, dataLength))
            {
                if (onDownloadProgress != null)
                {
                    onDownloadProgress(Task, (ulong)dataLength);
                }
                return true;
            }

            Delete(Task.TempPath);
            if (onDownloadFailure != null)
            {
                onDownloadFailure(Task, "IO error");
            }
            IsDone = true;
            return false;
        }

        // RVA: 0x2E991E8
        private void OnError(string error)
        {
            if (m_UnityWebRequest != null)
            {
                m_UnityWebRequest.Abort();
                m_UnityWebRequest.Dispose();
                m_UnityWebRequest = null;
            }
            if (m_FileStream != null)
            {
                m_FileStream.Close();
                m_FileStream = null;
            }
            if (onDownloadFailure != null)
            {
                onDownloadFailure(Task, error);
            }
            IsDone = true;
        }

        /// <summary>
        /// 下载完成：关闭流，按需校验 SHA1，移动到目标路径并回调成功。
        /// 校验仅在「有 CheckSum 且 m_IsResume」时进行。
        /// </summary>
        // RVA: 0x2E993E8
        private void OnDownloadComplete()
        {
            if (m_UnityWebRequest != null)
            {
                m_UnityWebRequest.Abort();
                m_UnityWebRequest.Dispose();
                m_UnityWebRequest = null;
            }
            if (m_FileStream != null)
            {
                m_FileStream.Close();
                m_FileStream = null;
            }

            DownloadTask task = Task;
            bool verified = string.IsNullOrEmpty(task.CheckSum) || !m_IsResume;
            if (!verified)
            {
                string hash = CryptoUtility.CalcFileHash(task.TempPath);
                if (string.Compare(task.CheckSum, hash, true) != 0)
                {
                    Delete(task.TempPath);
                    if (onDownloadFailure != null)
                    {
                        onDownloadFailure(Task, "Check hash failed");
                    }
                    IsDone = true;
                    return;
                }
            }

            if (MoveOrReplace(task.TempPath, task.SavePath))
            {
                if (onDownloadSuccess != null)
                {
                    onDownloadSuccess(Task);
                }
            }
            else if (onDownloadFailure != null)
            {
                onDownloadFailure(Task, "IO error");
            }
            IsDone = true;
        }

        /// <summary>把 UnityWebRequest 的接收回调转接到执行器。</summary>
        private class DownloadHandler : UnityEngine.Networking.DownloadHandlerScript
        {
            private DownloadExecutor m_DownloadExectuor;

            // RVA: 0x2E992A0
            public DownloadHandler(DownloadExecutor exectuor)
                : base(exectuor.m_PreallocatedBuffer)
            {
                m_DownloadExectuor = exectuor;
            }

            // RVA: 0x2E99B38
            protected override bool ReceiveData(byte[] data, int dataLength)
            {
                if (data == null || data.Length < 1)
                {
                    return false;
                }
                return m_DownloadExectuor.OnReceiveData(data, dataLength);
            }
        }
    }
}
