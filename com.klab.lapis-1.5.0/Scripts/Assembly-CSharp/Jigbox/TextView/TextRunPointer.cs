// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.TextRunPointer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;

namespace Jigbox.TextView
{
    public class TextRunPointer
    {
        public int Position { get; set; }
        public int TextRunIndex { get; set; }
        public TextSource TextSource { get; set; }
        public TextRun Current { get; private set; }

        public TextRun Previous
        {
            // RVA: 0x16871D0
            get
            {
                int index = TextRunIndex;
                if (Position == -1)
                {
                    index--;
                }

                return TextSource.TextRuns[index];
            }
        }

        public bool CanRead
        {
            // RVA: 0x168722C
            get { return !EndOfSource && Position < Current.Length; }
        }

        public bool EndOfSource
        {
            // RVA: 0x168727C
            get { return TextRunIndex == TextSource.TextRuns.Length; }
        }

        // RVA: 0x16872B0
        public TextRunPointer(TextSource source)
        {
            Position = -1;
            TextRunIndex = -1;
            TextSource = source;
            Current = TextSource.TextRuns.Length < 1 ? null : TextSource.TextRuns[0];
        }

        // RVA: 0x1687310
        public void Initialize()
        {
            UpdateCurrent();
        }

        // RVA: 0x1687314
        private void UpdateCurrent()
        {
            Current = TextRunIndex < TextSource.TextRuns.Length
                ? TextSource.TextRuns[TextRunIndex]
                : null;
        }

        // RVA: 0x1687374
        public void BackChunk()
        {
            TextRunIndex--;
            UpdateCurrent();
            Position = Current.Length - 1;
        }

        // RVA: 0x16873C0
        public void NextChunk()
        {
            TextRunIndex++;
            UpdateCurrent();
            Position = -1;
        }

        // RVA: 0x16873F4
        public bool Back()
        {
            Position--;

            if (Position <= -2)
            {
                BackChunk();
                return true;
            }

            return false;
        }

        // RVA: 0x1687428
        public bool Next()
        {
            if (EndOfSource)
            {
                throw new InvalidOperationException();
            }

            Position++;
            if (Position > Current.Length - 1)
            {
                TextRunIndex++;
                UpdateCurrent();
                Position = -1;
                return true;
            }

            return false;
        }
    }
}
