// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.SerDistrict
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

namespace Oz.Framework.NetworkModule
{
    /// <summary>服务器分区。</summary>
    public class SerDistrict
    {
        [SerializeField]
        public string name;
        [SerializeField]
        public List<SerList> listData;

        /// <summary>按服务器 id 查找。</summary>
        // RVA: 0x2EE5300
        public SerList GetSerList(int id)
        {
            return listData.Find(s => s.id == id);
        }

        // RVA: 0x2EE53CC
        public SerDistrict()
        {
        }
    }
}
