// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.AttributeKeyTokenizer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView.ParserV2
{
    public sealed class AttributeKeyTokenizer : TrimTokenizer
    {
        protected override TokenizeMode OwnMode
        {
            // RVA: 0x167DA54
            get { return TokenizeMode.Attribute; }
        }

        // RVA: 0x167DE2C
        protected override void CreateToken(string str)
        {
            tokens.Add(new AttributeKeyToken(str));
        }

        // RVA: 0x167DA5C
        protected override void SeekNextTokenizePoint()
        {
            char character = tokenizeInfo.Character;

            if (char.IsWhiteSpace(character))
            {
                return;
            }

            if (character != CharEqual)
            {
                tokenizeInfo.SetError(
                    "属性名の後に = が入力されなかったため、属性の値を設定できませんでした。");
                return;
            }

            Mode = TokenizeMode.AttributeValue;
        }

        // RVA: 0x167DEDC
        public AttributeKeyTokenizer()
        {
        }
    }
}
