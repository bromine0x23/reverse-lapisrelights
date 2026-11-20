// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.Download.dll
//  Oz.GameFramework.Runtime.Download.DownloadFailureArg
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

namespace Oz.GameFramework.Runtime.Download
{
    /// <summary>下载失败事件参数（从失败的 <see cref="DownloadTask"/> 拷贝）。</summary>
    public struct DownloadFailureArg
    {
        public TaskHandle Handle;
        public string UriString;
        public string SavePath;
        public ulong Size;
        public string CheckSum;
        public float Timeout;
        public object UserData;
        public string Error;

        // RVA: 0x2E99B68
        internal DownloadFailureArg(DownloadTask task, string error)
        {
            Handle = task.Handle;
            UriString = task.UriString;
            SavePath = task.SavePath;
            Size = task.Size;
            CheckSum = task.CheckSum;
            Timeout = task.Timeout;
            UserData = task.UserData;
            Error = error;
        }
    }
}
