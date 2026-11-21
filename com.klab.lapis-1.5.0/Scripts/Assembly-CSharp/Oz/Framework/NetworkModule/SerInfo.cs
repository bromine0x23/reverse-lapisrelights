// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.SerInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;

namespace Oz.Framework.NetworkModule
{
    /// <summary>登录/服务器信息响应。</summary>
    public class SerInfo
    {
        [SerializeField]
        public int code;
        [SerializeField]
        public string desc;
        [SerializeField]
        public string news;
        [SerializeField]
        public string certify;
        [SerializeField]
        public string survey;
        [SerializeField]
        public SerData data;

        // RVA: 0x2EE2210
        public SerInfo()
        {
        }
    }
}
