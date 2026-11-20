// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.WebNoticeInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections.Generic;

namespace Oz.Framework.NetworkModule
{{
    /// <summary>网页公告列表响应。</summary>
    public class WebNoticeInfo
    {
        public string message;
        public int retCode;
        public List<WebNoticeDetail> data;

        // RVA: 0x2EE5408
        public WebNoticeInfo()
        {
            message = "";
            data = new List<WebNoticeDetail>();
        }
    }
}}
