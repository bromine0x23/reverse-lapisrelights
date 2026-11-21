// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.SerNotice
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================


namespace Oz.Framework.NetworkModule
{
    /// <summary>维护/黑名单公告。</summary>
    public class SerNotice
    {
        public int black_start_ts;
        public int black_end_ts;
        public string black;
        public string news;
        public string desc;
        public int code;

        // RVA: 0x2EE38D8
        public SerNotice()
        {
            code = 1;
            desc = "";
        }
    }
}
