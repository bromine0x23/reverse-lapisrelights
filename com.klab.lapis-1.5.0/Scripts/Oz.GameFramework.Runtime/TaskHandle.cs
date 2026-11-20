// =============================================================================
//  Lapis Re:Lights 1.5.0 — Oz.GameFramework.Runtime.dll
//  Oz.GameFramework.Runtime.TaskHandle
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;

namespace Oz.GameFramework.Runtime
{
    /// <summary>下载/解压任务句柄（int 包装，0 表示无效）。</summary>
    public struct TaskHandle : IComparable<TaskHandle>, IEquatable<TaskHandle>
    {
        private int m_Handle;

        /// <summary>无效句柄（0）。</summary>
        public static TaskHandle Invaild
        {
            // RVA: 0x2E93848
            get { return new TaskHandle(0); }
        }

        // RVA: 0x2E93850
        public TaskHandle(int handle)
        {
            m_Handle = handle;
        }

        // RVA: 0x2E93858
        public int CompareTo(TaskHandle other)
        {
            return m_Handle.CompareTo(other.m_Handle);
        }

        // RVA: 0x2E93860
        public bool Equals(TaskHandle other)
        {
            return m_Handle.Equals(other.m_Handle);
        }

        // RVA: 0x2E93868
        public static TaskHandle operator ++(TaskHandle handle)
        {
            return new TaskHandle(handle.m_Handle + 1);
        }

        // RVA: 0x2E93870
        public override string ToString()
        {
            return m_Handle.ToString();
        }

        // RVA: 0x2E93878
        public override int GetHashCode()
        {
            return m_Handle;
        }
    }
}
