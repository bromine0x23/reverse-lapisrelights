// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  OptionalDownloadInfo
//  来源：Il2CppDumper 元数据 + 反汇编（0x16A8054）
// =============================================================================

using Oz.GameFramework.Runtime;

/// <summary>单个可选资源下载项（bundle 名与下载句柄）。</summary>
public class OptionalDownloadInfo
{
    public string name;
    public TaskHandle taskHandle;
    public ulong curSize;

    public OptionalDownloadInfo(string name, TaskHandle handle)
    {
        this.name = name;
        taskHandle = handle;
    }
}
