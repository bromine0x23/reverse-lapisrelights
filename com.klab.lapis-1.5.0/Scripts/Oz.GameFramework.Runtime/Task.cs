// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.Task
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

namespace Oz.GameFramework.Runtime
{
    /// <summary>带任务句柄的基类（句柄用于取消/查询下载任务）。</summary>
    public class Task
    {
        protected static TaskHandle s_TaskHandle;

        public TaskHandle Handle { get; protected set; }

        // RVA: 0x2E937F0
        public Task()
        {
        }

        // RVA: 0x2E937F8
        static Task()
        {
            s_TaskHandle = default(TaskHandle);
        }
    }
}
