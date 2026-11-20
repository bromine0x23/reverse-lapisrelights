// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.PatchInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using UnityEngine;

namespace Oz.GameKit.Version
{{
    /// <summary>补丁包条目（按版本号排序）。</summary>
    public class PatchInfo : IComparable<PatchInfo>
    {
        [SerializeField]
        public ulong version;
        [SerializeField]
        public string path;

        // RVA: 0x1882190
        public int CompareTo(PatchInfo other)
        {
            return version.CompareTo(other.version);
        }

        // RVA: 0x18821B0
        public PatchInfo()
        {
        }
    }
}}
