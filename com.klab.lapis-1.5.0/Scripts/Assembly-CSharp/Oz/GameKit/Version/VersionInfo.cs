// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.VersionInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Oz.GameKit.Version
{{
    /// <summary>某个 app 版本对应的补丁列表。</summary>
    public class VersionInfo
    {
        [SerializeField]
        public string app_version;
        [SerializeField]
        public string notice_key;
        [SerializeField]
        public List<PatchInfo> patch_list;

        /// <summary>取版本号最大的补丁。</summary>
        // RVA: 0x18927C4
        public PatchInfo GetLatestPatch()
        {
            if (patch_list.Count < 1)
            {
                return null;
            }
            return patch_list.Max();
        }

        /// <summary>查找指定版本号的补丁。</summary>
        // RVA: 0x1892834
        public bool TryGetCompatiblePatchInfo(ulong version, out PatchInfo patchInfo)
        {
            patchInfo = patch_list.Find(p => p.version == version);
            return patchInfo != null;
        }

        // RVA: 0x1892918
        public VersionInfo()
        {
        }
    }
}}
