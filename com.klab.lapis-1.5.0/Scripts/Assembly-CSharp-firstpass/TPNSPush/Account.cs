// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp-firstpass.dll
//  TPNSPush.Account
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

namespace TPNSPush
{
    /// <summary>TPNS 账号绑定项（type + value，JSON 序列化用）。</summary>
    public class Account
    {
        private int type;
        private string value;

        // RVA: 0x2ECE810
        public Account(int type, string value)
        {
            this.type = type;
            this.value = value;
        }
    }
}
