// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.EndTagTokenizer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public sealed class EndTagTokenizer : TrimTokenizer
    {
        protected override TokenizeMode OwnMode
        {
            // RVA: 0x167F914
            get { return TokenizeMode.EndTag; }
        }

        // RVA: 0x167FA6C
        protected override void CreateToken(string str)
        {
            tokens.Add(new EndTagToken(str));
        }

        // RVA: 0x167F91C
        protected override void SeekNextTokenizePoint()
        {
            char character = tokenizeInfo.Character;

            if (char.IsWhiteSpace(character))
            {
                return;
            }

            if (character != CharCloseTag)
            {
                tokenizeInfo.SetError(
                    "> 以外の文字が入力されたため、閉じタグを正しく閉じられませんでした。");
                return;
            }

            Mode = TokenizeMode.Text;
        }

        // RVA: 0x167FB20
        public EndTagTokenizer()
        {
        }
    }
}
