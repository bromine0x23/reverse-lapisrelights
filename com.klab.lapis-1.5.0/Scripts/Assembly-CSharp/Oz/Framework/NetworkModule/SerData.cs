// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.SerData
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.Framework.NetworkModule
{{
    /// <summary>服务器列表响应（分区 → 服务器）。</summary>
    public class SerData
    {
        [SerializeField]
        public int selfArea;
        [SerializeField]
        public int self;
        [SerializeField]
        public int suggestArea;
        [SerializeField]
        public int suggest;
        [SerializeField]
        public List<SerDistrict> list;

        // RVA: 0x2EE52F8
        public SerData()
        {
        }
    }
}}
