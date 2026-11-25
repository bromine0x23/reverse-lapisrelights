// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.Markup.MarkupParser
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;

namespace Jigbox.TextView.Markup
{
    public class MarkupParser : MarkupParserBase
    {
        private static readonly Dictionary<string, Color> presetColors;
        private static readonly Regex pixelValueRegex;
        private static readonly string pixelSuffix;

        // RVA: 0x181F104
        protected override TextRun[] VisitMarkupElement(Element element, string tagNameUpper)
        {
            switch (tagNameUpper)
            {
                case "SPAN":
                    return SpanElement(element, tagNameUpper);
                case "RUBY":
                    return RubyElement(element, tagNameUpper);
                case "COLOR":
                    return ColoredElement(element, tagNameUpper);
                case "SIZE":
                    return SizedElement(element, tagNameUpper);
                case "B":
                    return BoldElement(element, tagNameUpper);
                case "I":
                    return ItalicElement(element, tagNameUpper);
                case "IMG":
                    return ImageElement(element, tagNameUpper);
                case "ALIGN":
                    return AlignElement(element, tagNameUpper);
                case "BDO":
                    return BiDirectionOverrideElement(element, tagNameUpper);
                default:
                    return base.VisitMarkupElement(element, tagNameUpper);
            }
        }

        // RVA: 0x181F550
        private static string TryGetStringAttribute(Element element, string attributeName)
        {
            if (element.AttributesCount == 0)
            {
                return null;
            }

            if (!element.Attributes.ContainsKey(attributeName))
            {
                return null;
            }

            return element.GetAttribute(attributeName);
        }

        // RVA: 0x181F5FC
        private static int? TryGetIntAttribute(Element element, string attributeName)
        {
            if (element.AttributesCount == 0)
            {
                return null;
            }

            if (!element.Attributes.ContainsKey(attributeName))
            {
                return null;
            }

            if (!int.TryParse(element.GetAttribute(attributeName), out int value))
            {
                return null;
            }

            return value;
        }

        // RVA: 0x181F6E8
        private static float? TryGetFloatAttribute(Element element, string attributeName)
        {
            if (element.AttributesCount == 0)
            {
                return null;
            }

            if (!element.Attributes.ContainsKey(attributeName))
            {
                return null;
            }

            if (!float.TryParse(element.GetAttribute(attributeName), out float value))
            {
                return null;
            }

            return value;
        }

        // RVA: 0x181F7D4
        private static int? TryGetIntAttributeByPixelSuffix(Element element, string attributeName)
        {
            if (element.AttributesCount == 0)
            {
                return null;
            }

            if (!element.Attributes.ContainsKey(attributeName))
            {
                return null;
            }

            string value = element.GetAttribute(attributeName).Trim();

            if (value.Length <= pixelSuffix.Length)
            {
                return null;
            }

            if (string.Compare(
                    value.Substring(value.Length - pixelSuffix.Length),
                    pixelSuffix,
                    true) != 0)
            {
                return null;
            }

            string number = value.Substring(0, value.Length - pixelSuffix.Length).Trim();

            if (!pixelValueRegex.IsMatch(number))
            {
                return null;
            }

            return int.Parse(number);
        }

        // RVA: 0x181F9DC
        private static float? TryGetSpacingAttribute(Element element, string attributeName = "Spacing")
        {
            return TryGetFloatAttribute(element, attributeName);
        }

        // RVA: 0x181FA50
        private static Color? TryGetColorAttribute(Element element, string attributeName = "Color")
        {
            string value = element.GetAttribute(attributeName);

            if (presetColors.ContainsKey(value))
            {
                return presetColors[value];
            }

            if (ColorUtility.TryParseHtmlString(value, out Color color))
            {
                return color;
            }

            return null;
        }

        // RVA: 0x181FBA4
        private static int? TryGetFontSizeAttribute(Element element, string attributeName = "Size")
        {
            return TryGetIntAttribute(element, attributeName);
        }

        // RVA: 0x181FC18
        private static float? TryGetFontScaleAttribute(Element element, string attributeName = "Scale")
        {
            return TryGetFloatAttribute(element, attributeName);
        }

        // RVA: 0x181FC8C
        private static float? TryGetRubyOffsetAttribute(Element element, string attributeName = "Offset")
        {
            return TryGetFloatAttribute(element, attributeName);
        }

        // RVA: 0x181FD00
        private static string TryGetSourceAttribute(Element element, string attributeName = "Src")
        {
            return TryGetStringAttribute(element, attributeName);
        }

        // RVA: 0x181FD74
        private static string TryGetNameAttribute(Element element, string attributeName = "Name")
        {
            return TryGetStringAttribute(element, attributeName);
        }

        // RVA: 0x181FDE8
        private static float? TryGetWidthAttribute(Element element, string attributeName = "Width")
        {
            return TryGetFloatAttribute(element, attributeName);
        }

        // RVA: 0x181FE5C
        private static float? TryGetHeightAttribute(Element element, string attributeName = "Height")
        {
            return TryGetFloatAttribute(element, attributeName);
        }

        // RVA: 0x181FED0
        private static InlineImageSize TryGetWidthPixelAttribute(
            Element element,
            string attributeName = "Width")
        {
            int? value = TryGetIntAttributeByPixelSuffix(element, attributeName);
            return value.HasValue ? new InlineImageSize(value.Value) : null;
        }

        // RVA: 0x181FF9C
        private static InlineImageSize TryGetHeightPixelAttribute(
            Element element,
            string attributeName = "Height")
        {
            int? value = TryGetIntAttributeByPixelSuffix(element, attributeName);
            return value.HasValue ? new InlineImageSize(value.Value) : null;
        }

        // RVA: 0x1820068
        private static int? TryGetMarginLeftPixelAttribute(
            Element element,
            string attributeName = "Margin-Left")
        {
            return TryGetIntAttributeByPixelSuffix(element, attributeName);
        }

        // RVA: 0x18200DC
        private static int? TryGetMarginRightPixelAttribute(
            Element element,
            string attributeName = "Margin-Right")
        {
            return TryGetIntAttributeByPixelSuffix(element, attributeName);
        }

        // RVA: 0x1820150
        private static int? TryGetOffsetYPixelAttribute(
            Element element,
            string attributeName = "OffsetY")
        {
            return TryGetIntAttributeByPixelSuffix(element, attributeName);
        }

        // RVA: 0x18201C4
        private static bool CheckWidthUsePixelSuffix(Element element, string attributeName = "Width")
        {
            if (!element.Attributes.ContainsKey(attributeName))
            {
                return false;
            }

            return element.Attributes[attributeName]
                          .ToUpper()
                          .Contains(pixelSuffix.ToUpper());
        }

        // RVA: 0x18202C8
        private static bool CheckHeightUsePixelSuffix(Element element, string attributeName = "Height")
        {
            if (!element.Attributes.ContainsKey(attributeName))
            {
                return false;
            }

            return element.Attributes[attributeName]
                          .ToUpper()
                          .Contains(pixelSuffix.ToUpper());
        }

        // RVA: 0x18203CC
        private static InlineImageSize CreateWidthAttribute(Element element)
        {
            if (CheckWidthUsePixelSuffix(element))
            {
                InlineImageSize size = TryGetWidthPixelAttribute(element, "Width");
                return size ?? InlineImageSize.CreateByDefaultMagnificationValue();
            }

            float? value = TryGetWidthAttribute(element, "Width");
            if (value.HasValue)
            {
                return new InlineImageSize(value.Value);
            }

            return InlineImageSize.CreateByDefaultMagnificationValue();
        }

        // RVA: 0x1820504
        private static InlineImageSize CreateHeightAttribute(Element element)
        {
            if (CheckHeightUsePixelSuffix(element))
            {
                InlineImageSize size = TryGetHeightPixelAttribute(element, "Height");
                return size ?? InlineImageSize.CreateByDefaultMagnificationValue();
            }

            float? value = TryGetHeightAttribute(element, "Height");
            if (value.HasValue)
            {
                return new InlineImageSize(value.Value);
            }

            return InlineImageSize.CreateByDefaultMagnificationValue();
        }

        // RVA: 0x182063C
        protected virtual TextRun[] SpanElement(Element element, string tagNameUpper)
        {
            TextCharactersSpanGroup span = new TextCharactersSpanGroup();
            span.Color = TryGetColorAttribute(element, "Color");
            span.FontSize = TryGetFontSizeAttribute(element, "Size");
            span.Spacing = TryGetSpacingAttribute(element, "Spacing");
            return Packing(span, element, tagNameUpper);
        }

        // RVA: 0x18208CC
        protected virtual TextRun[] RubyElement(Element element, string tagNameUpper)
        {
            TextModifier modifier = new TextModifier();
            modifier.RubyColor = TryGetColorAttribute(element, "Value");
            modifier.RubyFontScale = TryGetFontScaleAttribute(element, "Scale");
            modifier.RubyOffset = TryGetRubyOffsetAttribute(element, "Offset");
            modifier.FontSize = TryGetFontSizeAttribute(element, "Size");
            modifier.Spacing = TryGetSpacingAttribute(element, "Spacing");
            return Packing(modifier, element, tagNameUpper);
        }

        // RVA: 0x1820A04
        protected virtual TextRun[] ColoredElement(Element element, string tagNameUpper)
        {
            TextModifier modifier = new TextModifier();
            modifier.Color = TryGetColorAttribute(element, "Value");
            modifier.FontSize = TryGetFontSizeAttribute(element, "Size");
            modifier.Spacing = TryGetSpacingAttribute(element, "Spacing");
            return Packing(modifier, element, tagNameUpper);
        }

        // RVA: 0x1820B0C
        protected virtual TextRun[] SizedElement(Element element, string tagNameUpper)
        {
            TextModifier modifier = new TextModifier();
            modifier.FontSize = TryGetFontSizeAttribute(element, "Value");
            modifier.Color = TryGetColorAttribute(element, "Color");
            modifier.Spacing = TryGetSpacingAttribute(element, "Spacing");
            return Packing(modifier, element, tagNameUpper);
        }

        // RVA: 0x1820C14
        protected virtual TextRun[] BoldElement(Element element, string tagNameUpper)
        {
            TextModifier modifier = new TextModifier();
            modifier.FontStyle = FontStyle.Bold;
            modifier.Color = TryGetColorAttribute(element, "Color");
            modifier.FontSize = TryGetFontSizeAttribute(element, "Size");
            modifier.Spacing = TryGetSpacingAttribute(element, "Spacing");
            return Packing(modifier, element, tagNameUpper);
        }

        // RVA: 0x1820D40
        protected virtual TextRun[] ItalicElement(Element element, string tagNameUpper)
        {
            TextModifier modifier = new TextModifier();
            modifier.FontStyle = FontStyle.Italic;
            modifier.Color = TryGetColorAttribute(element, "Color");
            modifier.FontSize = TryGetFontSizeAttribute(element, "Size");
            modifier.Spacing = TryGetSpacingAttribute(element, "Spacing");
            return Packing(modifier, element, tagNameUpper);
        }

        // RVA: 0x1820E6C
        protected virtual TextRun[] ImageElement(Element element, string tagNameUpper)
        {
            InlineImage image = new InlineImage();
            image.Source = TryGetSourceAttribute(element, "Src");
            image.Name = TryGetNameAttribute(element, "Name");
            image.Width = CreateWidthAttribute(element);
            image.Height = CreateHeightAttribute(element);
            image.MarginLeftWithPixel = TryGetMarginLeftPixelAttribute(element, "Margin-Left");
            image.MarginRightWithPixel = TryGetMarginRightPixelAttribute(element, "Margin-Right");
            image.OffsetYWithPixel = TryGetOffsetYPixelAttribute(element, "OffsetY");

            return new TextRun[] { image };
        }

        // RVA: 0x1820FE4
        protected virtual TextRun[] AlignElement(Element element, string tagNameUpper)
        {
            return new TextRun[]
            {
                new TextAlignModifier(element.GetAttribute("value", string.Empty))
            };
        }

        // RVA: 0x18210D4
        protected virtual TextRun[] BiDirectionOverrideElement(Element element, string tagNameUpper)
        {
            return new TextRun[]
            {
                new TextBiDirectionOverride(element.GetAttribute("dir", "auto"))
            };
        }

        // RVA: 0x1820744
        private TextRun[] Packing(TextRun head, Element element, string tagNameUpper)
        {
            TextRun[] children = base.VisitMarkupElement(element, tagNameUpper);
            TextRun[] runs = new TextRun[children.Length + 2];

            runs[0] = head;
            runs[runs.Length - 1] = new TextEndOfSegment();

            for (int i = 0; i < children.Length; i++)
            {
                runs[i + 1] = children[i];
            }

            return runs;
        }

        // RVA: 0x18211C4
        public MarkupParser()
        {
        }

        // RVA: 0x1821214
        static MarkupParser()
        {
            presetColors = new Dictionary<string, Color>(StringComparer.OrdinalIgnoreCase)
            {
                { "red", Color.red },
                { "green", Color.green },
                { "blue", Color.blue },
                { "white", Color.white },
                { "black", Color.black },
                { "yellow", Color.yellow },
                { "cyan", Color.cyan },
                { "magenta", Color.magenta },
                { "gray", Color.gray },
                { "grey", Color.grey },
                { "clear", Color.clear }
            };

            pixelValueRegex = new Regex("^-?[0-9]+$");
            pixelSuffix = "px";
        }
    }
}
