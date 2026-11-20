// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.SerList
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using UnityEngine;

namespace Oz.Framework.NetworkModule
{{
    /// <summary>单个服务器条目。</summary>
    public class SerList
    {
        [SerializeField]
        public int id;
        [SerializeField]
        public string name;
        [SerializeField]
        public string host;
        [SerializeField]
        public int port;
        [SerializeField]
        public int status;
        [SerializeField]
        public int isNew;

        // RVA: 0x2EE53F8
        public SerList()
        {
        }
    }
}}
