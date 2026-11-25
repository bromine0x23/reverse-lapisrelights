// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.ThreeProcessTokenizer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public abstract class ThreeProcessTokenizer : TextTokenizer
    {
        protected enum State
        {
            PreProcess = 0,
            TokenizeProcess = 1,
            PostProcess = 2
        }

        protected State state; // 0x10

        protected abstract TokenizeMode OwnMode { get; }

        // RVA: 0x167DF44
        protected override void Init()
        {
            fetchLength = 0;
            state = State.PreProcess;
        }

        // RVA: 0x1682750
        protected override bool Read()
        {
            switch (state)
            {
                case State.PreProcess:
                    SeekTokenizePoint();
                    break;

                case State.TokenizeProcess:
                    ReadAndCreateToken();
                    break;

                case State.PostProcess:
                    SeekNextTokenizePoint();
                    break;
            }

            if (!tokenizeInfo.IsFailed)
            {
                tokenizeInfo.Index++;
            }

            return Mode != OwnMode;
        }

        protected abstract void SeekTokenizePoint();

        protected abstract void ReadAndCreateToken();

        protected abstract void SeekNextTokenizePoint();

        // RVA: 0x167EB94
        protected ThreeProcessTokenizer()
        {
        }
    }
}
