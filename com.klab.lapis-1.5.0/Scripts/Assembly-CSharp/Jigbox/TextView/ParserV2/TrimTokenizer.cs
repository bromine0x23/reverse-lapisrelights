// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.TrimTokenizer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public abstract class TrimTokenizer : ThreeProcessTokenizer
    {
        // RVA: 0x1682C7C
        protected override void SeekTokenizePoint()
        {
            char character = tokenizeInfo.Character;

            if (char.IsWhiteSpace(character))
            {
                return;
            }

            if (!char.IsLetter(character))
            {
                tokenizeInfo.SetError("数字、記号からは開始出来ません。");
                return;
            }

            state = State.TokenizeProcess;
            fetchStartIndex = tokenizeInfo.Index;
            fetchLength = 1;
        }

        // RVA: 0x1682DE4
        protected override void ReadAndCreateToken()
        {
            if (IsLetterOrDigitOrTrail(tokenizeInfo.Character))
            {
                fetchLength++;
                return;
            }

            CreateToken(tokenizeInfo.Text.Substring(fetchStartIndex, fetchLength));
            tokenizeInfo.Index--;
            state = State.PostProcess;
        }

        protected abstract void CreateToken(string str);

        // RVA: 0x167DEE0
        protected TrimTokenizer()
        {
        }
    }
}
