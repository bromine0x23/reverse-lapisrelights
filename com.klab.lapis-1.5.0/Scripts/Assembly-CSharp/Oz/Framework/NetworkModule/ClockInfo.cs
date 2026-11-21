// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.ClockInfo
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================


namespace Oz.Framework.NetworkModule
{
    /// <summary>服务器时间与本地发送时刻，用于校正时钟。</summary>
    public class ClockInfo
    {
        public long ServerTime;
        public float SendTime;

        // RVA: 0x14052F8
        public ClockInfo(long serverTime, float sendTime)
        {
            ServerTime = serverTime;
            SendTime = sendTime;
        }
    }
}
