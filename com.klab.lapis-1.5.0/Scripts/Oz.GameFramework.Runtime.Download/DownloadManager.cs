// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Download.dll
//  Oz.GameFramework.Runtime.Download.DownloadManager
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//
//  下载总控：4 个 DownloadExecutor + 任务池 + 任务处理器；对外暴露 Request/Cancel
//  与 4 个静态事件。
// =============================================================================

using System;
using UnityEngine;

namespace Oz.GameFramework.Runtime.Download
{
    /// <summary>下载管理器（由 Launcher 装配）。</summary>
    public class DownloadManager : MonoBehaviour
    {
        private static int MAX_AUTO_RETRY_PER_TASK;
        private static Action<TaskHandle, object, ulong> onDownloadProgress;
        private static Action<TaskHandle, object, ulong> onDownloadResume;
        private static Action<TaskHandle, object> onDownloadSuccess;
        private static Action<DownloadFailureArg> onDownloadFailure;
        private static Processor<DownloadTask> m_TaskProcessor;
        private static SpawnPool<DownloadTask> m_TaskPool;

        public static event Action<TaskHandle, object, ulong> OnDownloadProgress
        {
            add { onDownloadProgress += value; }
            remove { onDownloadProgress -= value; }
        }

        public static event Action<TaskHandle, object, ulong> OnDownloadResume
        {
            add { onDownloadResume += value; }
            remove { onDownloadResume -= value; }
        }

        public static event Action<TaskHandle, object> OnDownloadSuccess
        {
            add { onDownloadSuccess += value; }
            remove { onDownloadSuccess -= value; }
        }

        public static event Action<DownloadFailureArg> OnDownloadFailure
        {
            add { onDownloadFailure += value; }
            remove { onDownloadFailure -= value; }
        }

        /// <summary>创建处理器与任务池，并装配 4 个下载执行器。</summary>
        // RVA: 0x2E9A334
        protected void Awake()
        {
            m_TaskProcessor = new Processor<DownloadTask>();
            m_TaskPool = new SpawnPool<DownloadTask>();

            for (int i = 0; i < 4; i++)
            {
                DownloadExecutor executor = new DownloadExecutor();
                executor.onDownloadProgress += OnProgress;
                executor.onDownloadResume += OnResume;
                executor.onDownloadSuccess += OnSuccess;
                executor.onDownloadFailure += OnFailure;
                m_TaskProcessor.AddExecutor(executor);
            }
        }

        // RVA: 0x2E9A590
        private void Update()
        {
            m_TaskProcessor.Update();
        }

        // RVA: 0x2E9A60C
        protected void OnDestroy()
        {
            m_TaskProcessor.ClearTask();
            m_TaskPool.Clear();
        }

        /// <summary>提交下载任务，返回任务句柄。</summary>
        // RVA: 0x2E9A6A4
        public static TaskHandle Request(string uri, string savePath, ulong size, float timeout, string checkSum,
            object userData)
        {
            DownloadTask task = m_TaskPool.Spawn();
            task.Initialize(uri, savePath, size, timeout, checkSum, userData, MAX_AUTO_RETRY_PER_TASK);
            m_TaskProcessor.AddTask(task, false);
            return task.Handle;
        }

        // RVA: 0x2E9A944
        public static void Cancel(TaskHandle handle)
        {
            m_TaskProcessor.RemoveTask(handle);
        }

        // RVA: 0x2E9A9C8
        public static void Cancel()
        {
            m_TaskProcessor.ClearTask();
        }

        // RVA: 0x2E9AA44
        private void OnProgress(DownloadTask task, ulong receivedLength)
        {
            if (onDownloadProgress != null)
            {
                onDownloadProgress(task.Handle, task.UserData, receivedLength);
            }
        }

        /// <summary>仅在非自动重试的续传时上报。</summary>
        // RVA: 0x2E9AAF0
        private void OnResume(DownloadTask task, ulong receivedLength)
        {
            if (!task.IsAutoRetry && onDownloadResume != null)
            {
                onDownloadResume(task.Handle, task.UserData, receivedLength);
            }
        }

        // RVA: 0x2E9ABA4
        private void OnSuccess(DownloadTask task)
        {
            TaskHandle handle = task.Handle;
            object userData = task.UserData;
            task.Reset();
            m_TaskPool.Recycle(task);

            if (onDownloadSuccess != null)
            {
                onDownloadSuccess(handle, userData);
            }
        }

        /// <summary>
        /// 失败处理：仍有自动重试次数且不是校验失败时，减一次并插回队首重试；
        /// 否则回收任务并抛出 <see cref="DownloadFailureArg"/>。
        /// </summary>
        // RVA: 0x2E9AD08
        private void OnFailure(DownloadTask task, string error)
        {
            if (task.AutoRetry && error != "Check hash failed")
            {
                task.ReduceRetryTimes();
                m_TaskProcessor.AddTask(task, true);
                return;
            }

            DownloadFailureArg arg = new DownloadFailureArg(task, error);
            task.Reset();
            m_TaskPool.Recycle(task);

            if (onDownloadFailure != null)
            {
                onDownloadFailure(arg);
            }
        }

        // RVA: 0x2E9AED4
        public DownloadManager()
        {
        }

        // RVA: 0x2E9AEDC
        static DownloadManager()
        {
            MAX_AUTO_RETRY_PER_TASK = 3;
        }
    }
}
