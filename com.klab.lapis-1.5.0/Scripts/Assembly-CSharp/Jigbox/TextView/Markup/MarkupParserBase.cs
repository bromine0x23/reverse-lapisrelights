// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.Markup.MarkupParserBase
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：ConvertNodeToTextSource 的 Thai/Arabic 文本整形分支尚未还原，
//        它依赖 ThaiTable / ThaiTextConverter / ArabicLetter /
//        ArabicTextConverter（均未还原），当前 Default 语言路径完整。
// =============================================================================

using System.Collections.Generic;
using Jigbox.TextView.ParserV2;
using UnityEngine;

namespace Jigbox.TextView.Markup
{
    public class MarkupParserBase
    {
        public bool TreatNewLineAsLineBreak { get; set; } // 0x10

        // RVA: 0x18211EC
        public MarkupParserBase()
        {
        }

        // RVA: 0x18214C0
        protected virtual TextRun[] VisitMarkupNode(MarkupNode node)
        {
            if (node is TextNode textNode)
            {
                if (TreatNewLineAsLineBreak)
                {
                    string[] lines = textNode.TextContent.Split(new[] { '\n' });
                    TextRun[] runs = new TextRun[Mathf.Max(lines.Length * 2 - 1, 0)];

                    for (int i = 0; i < lines.Length; i++)
                    {
                        runs[i * 2] = new TextCharacters(lines[i]);

                        if (i < lines.Length - 1)
                        {
                            runs[i * 2 + 1] = new LineBreak();
                        }
                    }

                    return runs;
                }

                return new TextRun[]
                {
                    new TextCharacters(
                        textNode.TextContent.Replace("\n", string.Empty)
                                            .Replace("\r", string.Empty))
                };
            }

            if (node is Element element)
            {
                return VisitMarkupElement(element, element.TagName.ToUpper());
            }

            return GetChildrenTextRuns(node);
        }

        // RVA: 0x181F3B8
        protected virtual TextRun[] VisitMarkupElement(Element element, string tagNameUpper)
        {
            if (tagNameUpper == "RUBY")
            {
                return new TextRun[]
                {
                    new TextCharactersRubyGroup(
                        element.TextContent,
                        element.GetAttribute("Value"))
                };
            }

            if (tagNameUpper == "BR")
            {
                return new TextRun[] { new LineBreak() };
            }

            return GetChildrenTextRuns(element);
        }

        // RVA: 0x1821860
        protected TextRun[] GetChildrenTextRuns(MarkupNode node)
        {
            List<MarkupNode> children = node.Children;
            int count = children == null ? 0 : children.Count;

            if (count == 0)
            {
                return new TextRun[0];
            }

            List<TextRun[]> runsList = new List<TextRun[]>(count);
            int totalLength = 0;

            for (int i = 0; i < count; i++)
            {
                TextRun[] runs = VisitMarkupNode(children[i]);
                totalLength += runs.Length;
                runsList.Add(runs);
            }

            TextRun[] result = new TextRun[totalLength];
            int index = 0;

            foreach (TextRun[] runs in runsList)
            {
                for (int i = 0; i < runs.Length; i++)
                {
                    result[index + i] = runs[i];
                }

                index += runs.Length;
            }

            return result;
        }

        // RVA: 0x1821B54
        protected virtual TextSource ConvertNodeToTextSource(
            MarkupNode rootNode,
            string errorMessage,
            TextLanguageType languageType)
        {
            TextRun[] runs = VisitMarkupNode(rootNode);

            // 未还原：languageType == Thai / Arabic 的文本整形分支，
            // 依赖 ThaiTable / ThaiTextConverter / ArabicLetter / ArabicTextConverter。
            return new TextSource(runs, errorMessage);
        }

        // RVA: 0x1821F34
        public TextSource ParseTextSource(
            string value,
            TextLanguageType languageType = TextLanguageType.Default)
        {
            if (string.IsNullOrEmpty(value))
            {
                return new TextSource(new TextRun[0], string.Empty);
            }

            ParseResult parseResult = TextParser.TryParse(value);
            MarkupNode node;
            string errorMessage;

            if (parseResult.WasSuccessful)
            {
                node = parseResult.Node;
                errorMessage = string.Empty;
            }
            else
            {
                MarkupNode fallback = new MarkupNode();
                fallback.AppendChild(new TextNode(value));

                node = fallback;
                errorMessage = parseResult.Message;
            }

            return ConvertNodeToTextSource(node, errorMessage, languageType);
        }
    }
}
