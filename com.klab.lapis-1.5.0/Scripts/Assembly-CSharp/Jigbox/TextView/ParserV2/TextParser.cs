// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.ParserV2.TextParser
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：重复属性名（0x1680C90 的 0x27F 退出标记）在原实现中不写 parseInfo，
//        而是直接让 Parse 返回 null；此处照搬该行为。
// =============================================================================

using System.Collections.Generic;
using Jigbox.TextView.Markup;

namespace Jigbox.TextView.ParserV2
{
    public static class TextParser
    {
        private static ParseInfo parseInfo;
        private static readonly PlainTextTokenizer plainTextTokenizer;
        private static readonly CharacterReferenceTokenizer characterReferenceTokenizer;
        private static readonly BeginTagTokenizer beginTagTokenizer;
        private static readonly EndTagTokenizer endTagTokenizer;
        private static readonly AttributeKeyTokenizer attributeKeyTokenizer;
        private static readonly AttributeValueTokenizer attributeValueTokenizer;

        // RVA: 0x1680110
        public static ParseResult TryParse(string text)
        {
            Tokenize(text);

            if (TextTokenizer.IsFailed)
            {
                return new ParseResult(TextTokenizer.Message);
            }

            MarkupNode node = Parse();

            if (parseInfo.IsFailed)
            {
                return new ParseResult(parseInfo.Message);
            }

            return new ParseResult(node);
        }

        // RVA: 0x16802A0
        private static void Tokenize(string text)
        {
            TextTokenizer.Refresh(text);

            while (true)
            {
                TextTokenizer tokenizer;

                switch (TextTokenizer.Mode)
                {
                    case TokenizeMode.Text:
                        tokenizer = plainTextTokenizer;
                        break;
                    case TokenizeMode.CharacterReference:
                        tokenizer = characterReferenceTokenizer;
                        break;
                    case TokenizeMode.Tag:
                        tokenizer = beginTagTokenizer;
                        break;
                    case TokenizeMode.EndTag:
                        tokenizer = endTagTokenizer;
                        break;
                    case TokenizeMode.Attribute:
                        tokenizer = attributeKeyTokenizer;
                        break;
                    case TokenizeMode.AttributeValue:
                        tokenizer = attributeValueTokenizer;
                        break;
                    default:
                        tokenizer = null;
                        break;
                }

                tokenizer.Tokenize();

                if (TextTokenizer.IsEnd)
                {
                    return;
                }
            }
        }

        // RVA: 0x16805B8
        private static MarkupNode Parse()
        {
            parseInfo.Init();

            MarkupNode root = new MarkupNode();

            int topNodesCount = TextTokenizer.GetTopNodesCount();
            if (topNodesCount >= 1)
            {
                root.SetChildrenCapacity(topNodesCount);
            }

            Stack<MarkupNode> stack = new Stack<MarkupNode>();
            string attributeName = null;

            foreach (Token token in TextTokenizer.GetTokens())
            {
                switch (token.Type)
                {
                    case TokenType.Text:
                    {
                        MarkupNode node = token.CreateMarkupNode();

                        if (stack.Count != 0)
                        {
                            stack.Peek().AppendChild(node);
                        }
                        else
                        {
                            root.AppendChild(node);
                        }

                        break;
                    }

                    case TokenType.Tag:
                    {
                        MarkupNode node = token.CreateMarkupNode();

                        if (stack.Count >= 1)
                        {
                            stack.Peek().AppendChild(node);
                        }

                        stack.Push(node as Element);
                        break;
                    }

                    case TokenType.EndTag:
                    {
                        if (stack.Count == 0)
                        {
                            parseInfo.SetError(
                                "閉じタグ(" + token.String + ")に対応するタグが存在しません。");
                            break;
                        }

                        MarkupNode top = stack.Peek();
                        string tagName = ((Element)top).TagName;

                        if (tagName != token.String)
                        {
                            parseInfo.SetError(
                                "タグ(" + tagName + ")に対応する閉じタグが入力される前に別な閉じタグ(" +
                                token.String + ")が入力されました。");
                            break;
                        }

                        EndTagToken endTagToken = (EndTagToken)token;

                        if (endTagToken.AllowEmpty || top.ChildrenCount != 0)
                        {
                            stack.Pop();

                            if (stack.Count == 0)
                            {
                                root.AppendChild(top);
                            }
                        }
                        else
                        {
                            parseInfo.SetError(
                                "タグ(" + tagName + ")内に要素が存在しません。");
                        }

                        break;
                    }

                    case TokenType.Attribute:
                        if (!string.IsNullOrEmpty(attributeName))
                        {
                            return null;
                        }

                        attributeName = token.String;
                        break;

                    case TokenType.AttributeValue:
                    {
                        MarkupNode top = stack.Peek();

                        if (top.Attributes.ContainsKey(attributeName))
                        {
                            top.Attributes[attributeName] = token.String;
                        }
                        else
                        {
                            top.Attributes.Add(attributeName, token.String);
                        }

                        attributeName = null;
                        break;
                    }
                }

                if (parseInfo.IsFailed)
                {
                    break;
                }
            }

            if (!parseInfo.IsFailed && stack.Count >= 1)
            {
                parseInfo.SetError(
                    "タグ(" + ((Element)stack.Peek()).TagName +
                    ")に対応する閉じタグが入力されていません。");
            }

            return parseInfo.IsFailed ? null : root;
        }

        // RVA: 0x16815C4
        static TextParser()
        {
            parseInfo = new ParseInfo();
            plainTextTokenizer = new PlainTextTokenizer();
            characterReferenceTokenizer = new CharacterReferenceTokenizer();
            beginTagTokenizer = new BeginTagTokenizer();
            endTagTokenizer = new EndTagTokenizer();
            attributeKeyTokenizer = new AttributeKeyTokenizer();
            attributeValueTokenizer = new AttributeValueTokenizer();
        }
    }
}
