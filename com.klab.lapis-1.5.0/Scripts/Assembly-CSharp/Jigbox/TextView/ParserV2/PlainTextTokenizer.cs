// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.PlainTextTokenizer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public sealed class PlainTextTokenizer : TextTokenizer
    {
        // RVA: 0x167FC6C
        public void CreateToken()
        {
            if (fetchLength == 0)
            {
                return;
            }

            TextToken token = new TextToken(
                tokenizeInfo.Text.Substring(fetchStartIndex, fetchLength));

            tokens.Add(token);
        }

        // RVA: 0x167FD70
        protected override bool Read()
        {
            char character = tokenizeInfo.Character;

            if (character == CharAmpersand)
            {
                CreateToken();
                Mode = TokenizeMode.CharacterReference;
            }
            else if (character == CharOpenTag)
            {
                CreateToken();

                int nextMode;
                if (tokenizeInfo.IsFinalCharacter)
                {
                    nextMode = (int)TokenizeMode.Tag;
                }
                else
                {
                    nextMode = tokenizeInfo.NextCharacter == CharSlash
                        ? (int)TokenizeMode.EndTag
                        : (int)TokenizeMode.Tag;
                }

                Mode = (TokenizeMode)nextMode;
            }
            else
            {
                fetchLength++;
            }

            tokenizeInfo.Index += Mode == TokenizeMode.EndTag ? 2 : 1;

            return Mode != TokenizeMode.Text;
        }

        // RVA: 0x16800A8
        public PlainTextTokenizer()
        {
        }
    }
}
