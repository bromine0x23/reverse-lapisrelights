// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.TextTokenizer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace Jigbox.TextView.ParserV2
{
    public abstract class TextTokenizer
    {
        public const char CharHyphen = '-';
        public const char CharUnderScore = '_';
        public const char CharOpenTag = '<';
        public const char CharCloseTag = '>';
        public const char CharSlash = '/';
        public const char CharEqual = '=';
        public const char CharSingleQuote = (char)0x27;
        public const char CharDoubleQuote = (char)0x22;
        public const char CharAmpersand = '&';
        public const char CharSemicolon = ';';
        public const char CharBackSlash = (char)0x5C;

        protected static TokenizeInfo tokenizeInfo;
        protected static List<Token> tokens;
        protected static TextTokenizer.Enumerator enumerator;
        private static TokenizeMode mode;
        protected static int fetchStartIndex;
        protected static int fetchLength;
        protected static StringBuilder stringBuilder;
        private static Stack<BeginTagToken> cachedTagStack;

        public static bool IsEnd
        {
            // RVA: 0x1681538
            get { return tokenizeInfo.IsEnd; }
        }

        public static bool IsFailed
        {
            // RVA: 0x16804D0
            get { return tokenizeInfo.IsFailed; }
        }

        public static string Message
        {
            // RVA: 0x1680544
            get { return tokenizeInfo.Message; }
        }

        public static TokenizeMode Mode
        {
            // RVA: 0x1681798
            get { return mode; }
            // RVA: 0x1681800
            protected set { mode = value; }
        }

        public static int FetchStartIndex
        {
            // RVA: 0x168186C
            get { return fetchStartIndex; }
        }

        // RVA: 0x16812AC
        public static void Refresh(string text)
        {
            tokenizeInfo.Init(text);
            tokens.Clear();
            Mode = TokenizeMode.Text;
            stringBuilder.Length = 0;

            if (enumerator == null)
            {
                enumerator = new Enumerator(tokens);
            }
        }

        // RVA: 0x1681424
        public void Tokenize()
        {
            Init();

            while (!IsEnd)
            {
                if (Read())
                {
                    break;
                }
            }

            if (!IsEnd)
            {
                return;
            }

            if (IsFailed)
            {
                return;
            }

            if (!CheckErrorFinalTokenizer() && GetType() == typeof(PlainTextTokenizer))
            {
                ((PlainTextTokenizer)this).CreateToken();
            }

            CountUpRelativeNodes();
        }

        // RVA: 0x168122C
        public static Enumerator GetTokens()
        {
            enumerator.currentIndex = -1;
            return enumerator;
        }

        // RVA: 0x16810C4
        public static int GetTopNodesCount()
        {
            int depth = 0;
            int count = 0;

            foreach (Token token in tokens)
            {
                if (token.Type == TokenType.Tag)
                {
                    if (depth == 0)
                    {
                        count++;
                    }

                    depth++;
                }
                else if (token.Type == TokenType.EndTag)
                {
                    depth--;
                }
                else if (depth == 0)
                {
                    count++;
                }
            }

            return count;
        }

        // RVA: 0x1681C80
        protected static void CountUpRelativeNodes()
        {
            cachedTagStack.Clear();

            for (int i = 0; i < tokens.Count; i++)
            {
                Token token = tokens[i];

                switch (token.Type)
                {
                    case TokenType.Text:
                        if (cachedTagStack.Count != 0)
                        {
                            cachedTagStack.Peek().ChildrenCount++;
                        }
                        break;

                    case TokenType.Tag:
                        if (cachedTagStack.Count != 0)
                        {
                            cachedTagStack.Peek().ChildrenCount++;
                        }

                        cachedTagStack.Push(token as BeginTagToken);
                        break;

                    case TokenType.EndTag:
                        if (cachedTagStack.Count < 1)
                        {
                            return;
                        }

                        cachedTagStack.Pop();
                        break;

                    case TokenType.Attribute:
                        if (cachedTagStack.Count != 0)
                        {
                            cachedTagStack.Peek().AttributeCount++;
                        }
                        break;
                }
            }
        }

        // RVA: 0x1682014
        protected virtual void Init()
        {
            fetchStartIndex = tokenizeInfo.Index;
            fetchLength = 0;
        }

        protected abstract bool Read();

        // RVA: 0x167EAC0
        protected bool IsLetterOrDigitOrTrail(char character)
        {
            return char.IsLetterOrDigit(character) ||
                   character == CharHyphen ||
                   character == CharUnderScore;
        }

        // RVA: 0x1681934
        protected bool CheckErrorFinalTokenizer()
        {
            switch (Mode)
            {
                case TokenizeMode.CharacterReference:
                    tokenizeInfo.SetError(
                        "; が入力されていないため、文字参照が正しく行われませんでした。",
                        tokenizeInfo.Index,
                        CharAmpersand);
                    return true;

                case TokenizeMode.Tag:
                    tokenizeInfo.SetError(
                        "> が入力されていないため、タグが正しく閉じられませんでした。",
                        tokenizeInfo.Index,
                        CharOpenTag);
                    return true;

                case TokenizeMode.EndTag:
                    tokenizeInfo.SetError(
                        "> が入力されていないため、閉じタグが正しく閉じられませんでした。",
                        tokenizeInfo.Index,
                        CharOpenTag);
                    return true;

                case TokenizeMode.Attribute:
                    tokenizeInfo.SetError(
                        "属性名以降の入力がないため、タグが正しく閉じられませんでした。",
                        tokenizeInfo.Index);
                    return true;

                case TokenizeMode.AttributeValue:
                    tokenizeInfo.SetError(
                        "属性の値の指定が閉じられていないため、値を正しく設定できませんでした。",
                        tokenizeInfo.Index);
                    return true;

                default:
                    return false;
            }
        }

        // RVA: 0x167F728
        protected TextTokenizer()
        {
        }

        // RVA: 0x1682594
        static TextTokenizer()
        {
            tokenizeInfo = new TokenizeInfo();
            tokens = new List<Token>();
            fetchStartIndex = 0;
            fetchLength = 0;
            stringBuilder = new StringBuilder();
            cachedTagStack = new Stack<BeginTagToken>();
        }

        public sealed class Enumerator : IEnumerator<Token>, IEnumerable
        {
            private List<Token> tokens;
            private int currentIndex;
            private Token current;

            public Token Current
            {
                // RVA: 0x16826A0
                get { return current; }
            }

            object IEnumerator.Current
            {
                // RVA: 0x16826A8
                get { return current; }
            }

            // RVA: 0x16818FC
            public Enumerator(List<Token> tokens)
            {
                this.tokens = tokens;
                currentIndex = -1;
                current = null;
            }

            // RVA: 0x16826B0
            public bool MoveNext()
            {
                currentIndex++;

                if (currentIndex >= tokens.Count)
                {
                    return false;
                }

                current = tokens[currentIndex];
                return true;
            }

            // RVA: 0x1682008
            public void Reset()
            {
                currentIndex = -1;
            }

            // RVA: 0x1682748
            void System.IDisposable.Dispose()
            {
            }

            // RVA: 0x168274C
            IEnumerator System.Collections.IEnumerable.GetEnumerator()
            {
                return this;
            }
        }
    }
}
