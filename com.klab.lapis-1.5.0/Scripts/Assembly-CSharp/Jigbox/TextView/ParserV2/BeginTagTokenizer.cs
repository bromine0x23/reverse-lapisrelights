// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.BeginTagTokenizer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public sealed class BeginTagTokenizer : TrimTokenizer
    {
        protected override TokenizeMode OwnMode
        {
            // RVA: 0x167ECFC
            get { return TokenizeMode.Tag; }
        }

        // RVA: 0x167F194
        protected override void CreateToken(string str)
        {
            tokens.Add(new BeginTagToken(str));
        }

        // RVA: 0x167ED04
        protected override void SeekNextTokenizePoint()
        {
            char character = tokenizeInfo.Character;

            if (char.IsWhiteSpace(character))
            {
                if (tokenizeInfo.IsFinalCharacter)
                {
                    return;
                }

                if (!IsLetterOrDigitOrTrail(tokenizeInfo.NextCharacter))
                {
                    return;
                }

                Mode = TokenizeMode.Attribute;
                return;
            }

            switch (character)
            {
                case CharCloseTag:
                    Mode = TokenizeMode.Text;
                    return;

                case CharSlash:
                    if (tokenizeInfo.IsFinalCharacter)
                    {
                        return;
                    }

                    if (tokenizeInfo.NextCharacter != CharCloseTag)
                    {
                        tokenizeInfo.SetError(
                            "/ の後に > が入力されなかったため、タグを正しく閉じられませんでした。");
                        return;
                    }

                    tokens.Add(new EndTagToken(((BeginTagToken)tokens[tokens.Count - 1]).String, true));
                    tokenizeInfo.Index++;
                    Mode = TokenizeMode.Text;
                    return;

                case CharEqual:
                    tokens.Add(new AttributeKeyToken("Value"));
                    Mode = TokenizeMode.AttributeValue;
                    return;

                default:
                    tokenizeInfo.SetError(
                        "属性名には、文字、数字、 - 、 _ 以外の文字は入力できません。");
                    return;
            }
        }

        // RVA: 0x167F244
        public BeginTagTokenizer()
        {
        }
    }
}
