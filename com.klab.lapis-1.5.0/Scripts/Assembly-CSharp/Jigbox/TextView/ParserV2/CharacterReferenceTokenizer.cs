// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.CharacterReferenceTokenizer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;
using System.Globalization;

namespace Jigbox.TextView.ParserV2
{
    public sealed class CharacterReferenceTokenizer : TextTokenizer
    {
        private static readonly Dictionary<string, string> CharacterEntityReferences;

        // RVA: 0x167F248
        protected override bool Read()
        {
            char character = tokenizeInfo.Character;

            if (character == CharSemicolon)
            {
                if (fetchLength == 0)
                {
                    tokenizeInfo.SetError(
                        "文字参照を行うための識別用の文字列が入力されていません。");
                }
                else
                {
                    string value = tokenizeInfo.Text.Substring(fetchStartIndex, fetchLength);
                    tokens.Add(new TextToken(Resolve(value)));
                    Mode = TokenizeMode.Text;
                }
            }
            else
            {
                fetchLength++;
            }

            tokenizeInfo.Index++;
            return Mode != TokenizeMode.CharacterReference;
        }

        // RVA: 0x167F4F4
        private static string Resolve(string value)
        {
            string result;

            if (value.StartsWith("#x"))
            {
                if (int.TryParse(value.Substring(2), NumberStyles.HexNumber, null, out int codePoint))
                {
                    result = char.ConvertFromUtf32(codePoint);
                }
                else
                {
                    result = string.Empty;
                }
            }
            else if (value.StartsWith("#"))
            {
                if (int.TryParse(value.Substring(1), NumberStyles.Integer, null, out int codePoint))
                {
                    result = char.ConvertFromUtf32(codePoint);
                }
                else
                {
                    result = string.Empty;
                }
            }
            else if (CharacterEntityReferences.ContainsKey(value))
            {
                result = CharacterEntityReferences[value];
            }
            else
            {
                result = string.Empty;
            }

            return result;
        }

        // RVA: 0x167F6C0
        public CharacterReferenceTokenizer()
        {
        }

        // RVA: 0x167F730
        static CharacterReferenceTokenizer()
        {
            CharacterEntityReferences = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "amp", "&" },
                { "apos", "'" },
                { "quot", "\"" },
                { "lt", "<" },
                { "gt", ">" },
                { "shy", string.Empty }
            };
        }
    }
}
