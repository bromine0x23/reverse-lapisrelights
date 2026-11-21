// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.PlatformInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.GameKit.Version
{
    /// <summary>某个平台（android/ios）的启动配置。</summary>
    public class PlatformInfo
    {
        [SerializeField]
        public string platform;
        [SerializeField]
        public string app_url;
        [SerializeField]
        public List<string> cdn_list;
        [SerializeField]
        public List<string> server_list;
        [SerializeField]
        public List<VersionInfo> version_list;

        /// <summary>按 app 版本查找兼容项。</summary>
        // RVA: 0x18821B8
        public bool TryGetCompatibleAppVersion(string appVersion, out VersionInfo versionInfo)
        {
            versionInfo = version_list?.Find(v => v.app_version == appVersion);
            return versionInfo != null;
        }

        // RVA: 0x18822A4
        public PlatformInfo()
        {
        }
    }
}
