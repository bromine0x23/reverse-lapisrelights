// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.AttributeValueTokenizer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public sealed class AttributeValueTokenizer : ThreeProcessTokenizer
    {
        private bool isSingleQuote;      // 0x14
        private bool isExistQuoteInValue; // 0x15

        protected override TokenizeMode OwnMode
        {
            // RVA: 0x167DF18
            get { return TokenizeMode.AttributeValue; }
        }

        // RVA: 0x167DF20
        protected override void Init()
        {
            base.Init();
            isSingleQuote = false;
            isExistQuoteInValue = false;
        }

        // RVA: 0x167DFB4
        protected override void SeekTokenizePoint()
        {
            char character = tokenizeInfo.Character;

            if (char.IsWhiteSpace(character))
            {
                if (!tokenizeInfo.IsFinalCharacter)
                {
                    return;
                }

                tokenizeInfo.SetError(
                    "属性の値の先頭には、 ' か \" を入力しなければいけません。");
                return;
            }

            if (character == (char)0x27 || character == (char)0x22)
            {
                state = State.TokenizeProcess;
                isSingleQuote = character == (char)0x27;
                fetchStartIndex = tokenizeInfo.Index + 1;
                return;
            }

            tokenizeInfo.SetError(
                "属性の値の先頭は、 ' 、 \" 以外入力できません。");
        }

        // RVA: 0x167E190
        protected override void ReadAndCreateToken()
        {
            char character = tokenizeInfo.Character;
            char quote = isSingleQuote ? (char)0x27 : (char)0x22;

            if (character == quote)
            {
                string value = tokenizeInfo.Text.Substring(fetchStartIndex, fetchLength);
                if (isExistQuoteInValue)
                {
                    value = UnescapeQuote(value);
                }

                tokens.Add(new AttributeValueToken(value));
                state = State.PostProcess;
                return;
            }

            fetchLength++;

            if (character != CharBackSlash)
            {
                return;
            }

            if (tokenizeInfo.IsFinalCharacter)
            {
                return;
            }

            char nextQuote = isSingleQuote ? (char)0x27 : (char)0x22;
            if (tokenizeInfo.NextCharacter != nextQuote)
            {
                tokenizeInfo.SetError(
                    "属性の値は、クォーテーションのエスケープの目的以外で \\ は使えません。");
                return;
            }

            isExistQuoteInValue = true;
            tokenizeInfo.Index++;
            fetchLength++;
        }

        // RVA: 0x167E630
        protected override void SeekNextTokenizePoint()
        {
            char character = tokenizeInfo.Character;

            if (char.IsWhiteSpace(character))
            {
                return;
            }

            if (IsLetterOrDigitOrTrail(character))
            {
                tokenizeInfo.Index--;
                Mode = TokenizeMode.Attribute;
                return;
            }

            if (character == CharCloseTag)
            {
                Mode = TokenizeMode.Text;
                return;
            }

            if (character != CharSlash)
            {
                tokenizeInfo.SetError(
                    "属性名には、文字、数字、 - 、 _ 以外の文字は入力できません。");
                return;
            }

            if (tokenizeInfo.IsFinalCharacter)
            {
                tokenizeInfo.SetError(
                    "> がないため、タグが正しく閉じられませんでした。");
                return;
            }

            if (tokenizeInfo.NextCharacter != CharCloseTag)
            {
                tokenizeInfo.SetError(
                    "/ の後に > が入力されなかったため、タグを正しく閉じられませんでした。");
                return;
            }

            BeginTagToken beginTagToken = null;
            for (int i = tokens.Count - 1; i >= 0; i--)
            {
                if (tokens[i] is BeginTagToken)
                {
                    beginTagToken = (BeginTagToken)tokens[i];
                    break;
                }
            }

            tokens.Add(new EndTagToken(beginTagToken.String, true));
            tokenizeInfo.Index++;
            Mode = TokenizeMode.Text;
        }

        // RVA: 0x167E454
        private static string UnescapeQuote(string value)
        {
            stringBuilder.Length = 0;

            for (int i = 0; i < value.Length; i++)
            {
                char character = value[i];

                if (character == CharBackSlash && i + 1 < value.Length)
                {
                    char next = value[i + 1];
                    if (next == (char)0x22 || next == (char)0x27)
                    {
                        stringBuilder.Append(next);
                        i++;
                        continue;
                    }
                }

                stringBuilder.Append(character);
            }

            return stringBuilder.ToString();
        }

        // RVA: 0x167EB90
        public AttributeValueTokenizer()
        {
        }
    }
}
