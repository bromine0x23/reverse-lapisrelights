// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.MainThreadDispatcherException
//  来源：libil2cpp.so (ARM64) 反汇编 + Il2CppDumper 元数据
// =============================================================================

using System;

namespace Jackpot
{
    public class MainThreadDispatcherException : Exception
    {
        private readonly string stackTrace;

        // RVA: 0x19F6988
        public MainThreadDispatcherException(string stackTrace, Exception e)
            : base(e.Message, e)
        {
            this.stackTrace = stackTrace;
        }

        // RVA: 0x19F6B20 get_StackTrace
        public override string StackTrace
        {
            get { return stackTrace; }
        }
    }
}
