// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.ParseInfo
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public sealed class ParseInfo
    {
        public bool IsFailed { get; private set; }
        public string Message { get; private set; }

        // RVA: 0x167FB48
        public void Init()
        {
            IsFailed = false;
            Message = null;
        }

        // RVA: 0x167FB54
        public void SetError(string errorMessage)
        {
            Message = "エラー内容 : " + errorMessage;
            IsFailed = true;
        }

        // RVA: 0x167FBC4
        public ParseInfo()
        {
        }
    }
}
