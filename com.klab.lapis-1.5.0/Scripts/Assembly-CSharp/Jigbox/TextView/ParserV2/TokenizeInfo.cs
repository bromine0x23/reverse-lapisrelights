// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.TokenizeInfo
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;

namespace Jigbox.TextView.ParserV2
{
    public sealed class TokenizeInfo
    {
        private static readonly int ErrorTextPickupLength = 10;

        public string Text { get; private set; }
        public int Length { get; private set; }
        public int Index { get; set; }
        public bool IsFailed { get; private set; }
        public string Message { get; private set; }

        public char Character
        {
            // RVA: 0x167DBB0
            get { return Text[Index]; }
        }

        public char NextCharacter
        {
            // RVA: 0x167E42C
            get { return Text[Index + 1]; }
        }

        public bool IsFinalCharacter
        {
            // RVA: 0x167E17C
            get { return Index + 1 >= Length; }
        }

        public bool IsEnd
        {
            // RVA: 0x1681778
            get { return IsFailed || Index >= Length; }
        }

        // RVA: 0x16818D4
        public void Init(string text)
        {
            Text = text;
            Length = text.Length;
            Index = 0;
            IsFailed = false;
            Message = null;
        }

        // RVA: 0x167DBD4
        public void SetError(string errorMessage)
        {
            Message = string.Concat(new object[]
            {
                "テキスト(",
                Index,
                "/",
                Length,
                ") : ",
                PickupError(Index),
                "\nエラー内容 : ",
                errorMessage
            });
            IsFailed = true;
        }

        // RVA: 0x1682330
        public void SetError(string errorMessage, int index)
        {
            Message = string.Concat(new object[]
            {
                "テキスト(",
                Index,
                "/",
                Length,
                ") : ",
                PickupError(index),
                "\nエラー内容 : ",
                errorMessage
            });
            IsFailed = true;
        }

        // RVA: 0x1682094
        public void SetError(string errorMessage, int index, char pickupCharacter)
        {
            int originalIndex = index;

            while (true)
            {
                if (Text[index] == pickupCharacter)
                {
                    break;
                }

                index--;
                if (index < 0)
                {
                    index = originalIndex;
                    break;
                }
            }

            Message = string.Concat(new object[]
            {
                "テキスト(",
                Index,
                "/",
                Length,
                ") : ",
                PickupError(index),
                "\nエラー内容 : ",
                errorMessage
            });
            IsFailed = true;
        }

        // RVA: 0x1682924
        private string PickupError(int index)
        {
            int start = Length <= index ? index - 1 : index;

            int beforeLength = Mathf.Min(start, ErrorTextPickupLength);
            string before = Text.Substring(start - beforeLength, beforeLength);
            if (start > ErrorTextPickupLength)
            {
                before = "..." + before;
            }

            int afterStart = start + 1;
            int afterLength = Mathf.Min(Length - afterStart, ErrorTextPickupLength);
            string after = Text.Substring(afterStart, afterLength);
            if (Length - afterStart > ErrorTextPickupLength)
            {
                after = after + "...";
            }

            return string.Concat(new object[]
            {
                before,
                "<color=red>",
                Text.Substring(start, 1),
                "</color>",
                after
            });
        }

        // RVA: 0x1682698
        public TokenizeInfo()
        {
        }
    }
}
