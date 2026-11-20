// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.BootInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;
using System.IO;
using ICSharpCode.SharpZipLib.GZip;
using UnityEngine;

namespace Oz.GameKit.Version
{{
    /// <summary>启动清单（manifest.xml 的根对象）。</summary>
    public class BootInfo
    {
        [SerializeField]
        public List<NoticeInfo> notice_list;
        [SerializeField]
        public List<PlatformInfo> platform_list;

        /// <summary>
        /// 从流读取 JSON。注意：二进制中 GZipInputStream 虽然创建了，
        /// 但 StreamReader 直接读取的是<b>原始流</b>（未使用 gzip 解压流），此处保持原样。
        /// </summary>
        // RVA: 0x187D8B8
        public static BootInfo ReadFromStream(Stream stream)
        {
            using (GZipInputStream gzip = new GZipInputStream(stream))
            using (StreamReader reader = new StreamReader(stream))
            {
                string json = reader.ReadToEnd();
                return JsonUtility.FromJson<BootInfo>(json);
            }
        }
    }
}}
