// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Extensions.NamedFormatExtension
//  来源：libil2cpp.so (ARM64) 反汇编 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.CompilerServices;

namespace Jackpot.Extensions
{
    public static class NamedFormatExtension
    {
        private interface ITextExpression
        {
            string Eval(Dictionary<string, string> obj);
        }

        private class LiteralExpression : ITextExpression
        {
            private readonly string expression;

            // RVA: 0x19E912C
            public LiteralExpression(string expression)
            {
                this.expression = expression;
            }

            // RVA: 0x19E9AA4
            public string Eval(Dictionary<string, string> source)
            {
                return expression.Replace(EscapedLeftLiteral, LeftLiteral).Replace(EscapedRightLiteral, RightLiteral);
            }
        }

        private class FormatExpression : ITextExpression
        {
            private static readonly Dictionary<string, NamedFormatDelegate> handlers;
            private readonly bool invalidExpression;
            private readonly string expression;
            private readonly string format;
            private readonly Dictionary<string, string> cachedResult;

            // RVA: 0x19E9158
            public FormatExpression(string expression, Dictionary<string, string> cachedResult)
            {
                this.expression = expression;
                this.cachedResult = cachedResult;
                if (expression.StartsWith(LeftLiteral) && expression.EndsWith(RightLiteral))
                {
                    invalidExpression = false;
                    format = expression.Substring(1, expression.Length - 2);
                }
                else
                {
                    invalidExpression = true;
                }
            }

            // RVA: 0x19E9380
            public string Eval(Dictionary<string, string> source)
            {
                if (invalidExpression)
                {
                    throw new FormatException(string.Format("Invalid Expression: {0}", expression));
                }

                if (!cachedResult.ContainsKey(format))
                {
                    try
                    {
                        NamedFormatDelegate namedFormatDelegate = null;
                        string text = null;
                        foreach (KeyValuePair<string, NamedFormatDelegate> handler in handlers)
                        {
                            text = handler.Key;
                            if (format.StartsWith(text) && handler.Value != null)
                            {
                                namedFormatDelegate = handler.Value;
                                break;
                            }
                        }

                        if (namedFormatDelegate == null)
                        {
                            namedFormatDelegate = DefaultHandler;
                            text = string.Empty;
                        }

                        cachedResult[format] = namedFormatDelegate(text, format.Substring(text.Length), source);
                    }
                    catch (Exception e)
                    {
                        Logger.Get("Jackpot.Extensions.NamedFormatExtension").Error(e, new object[0]);
                        cachedResult[format] = format;
                    }
                }

                return cachedResult[format];
            }

            // RVA: 0x19E99C0
            private string DefaultHandler(string prefix, string formatString, Dictionary<string, string> source)
            {
                if (source != null)
                {
                    return source[formatString];
                }

                return formatString;
            }

            // RVA: 0x19E858C
            public static void AddHandler(string prefix, NamedFormatDelegate handler)
            {
                if (string.IsNullOrEmpty(prefix) || prefix.Trim().Length == 0)
                {
                    throw new ArgumentException(string.Format("expected prefix is not empty, but was {0}", prefix));
                }

                if (prefix.Contains(LeftLiteral) || prefix.Contains(RightLiteral))
                {
                    throw new ArgumentException(string.Format("cannot set literal string to prefix, but was {0}", prefix));
                }

                if (handler != null)
                {
                    RemoveHandler(prefix);
                    handlers.Add(prefix, handler);
                }
            }

            // RVA: 0x19E879C
            public static bool HandlerContains(string prefix)
            {
                return handlers.ContainsKey(prefix) && handlers[prefix] != null;
            }

            // RVA: 0x19E88D8
            public static void RemoveHandler(string prefix)
            {
                if (HandlerContains(prefix))
                {
                    handlers.Remove(prefix);
                }
            }

            // RVA: 0x19E89E8
            public static void RemoveAllHandlers()
            {
                handlers.Clear();
            }

            // RVA: 0x19E9A30
            static FormatExpression()
            {
                handlers = new Dictionary<string, NamedFormatDelegate>();
            }
        }

        private static readonly char[] Literals;
        private static readonly char LeftLiteralChar;
        private static readonly char RightLiteralChar;
        private static readonly string LeftLiteral;
        private static readonly string RightLiteral;
        private static readonly string EscapedLeftLiteral;
        private static readonly string EscapedRightLiteral;

        // RVA: 0x19E7F58
        [Extension]
        public static string NamedFormat(string self, object source)
        {
            if (string.IsNullOrEmpty(self))
            {
                return string.Empty;
            }

            Dictionary<string, string> dictionary = new Dictionary<string, string>();
            foreach (PropertyInfo propertyInfo in source.GetType().GetProperties())
            {
                if (propertyInfo.CanRead)
                {
                    object value = propertyInfo.GetGetMethod().Invoke(source, null);
                    dictionary.Add(propertyInfo.Name, (value ?? "Null").ToString());
                }
            }

            return NamedFormat(self, dictionary);
        }

        // RVA: 0x19E8144
        [Extension]
        public static string NamedFormat(string self, Dictionary<string, string> source)
        {
            if (string.IsNullOrEmpty(self))
            {
                return string.Empty;
            }

            string text = string.Empty;
            foreach (ITextExpression textExpression in Expressions(self))
            {
                text += textExpression.Eval(source);
            }

            return text;
        }

        // RVA: 0x19E8518
        public static void AddHandler(string prefix, NamedFormatDelegate handler)
        {
            FormatExpression.AddHandler(prefix, handler);
        }

        // RVA: 0x19E8738
        public static bool HandlerContains(string prefix)
        {
            return FormatExpression.HandlerContains(prefix);
        }

        // RVA: 0x19E8874
        public static void RemoveHandler(string prefix)
        {
            FormatExpression.RemoveHandler(prefix);
        }

        // RVA: 0x19E898C
        public static void RemoveAllHandlers()
        {
            FormatExpression.RemoveAllHandlers();
        }

        // RVA: 0x19E8498
        private static IEnumerable<ITextExpression> Expressions(string format)
        {
            int num = 0;
            Dictionary<string, string> cachedResult = new Dictionary<string, string>();
            int num2 = 0;
            int num3 = 0;
            while (num3 < format.Length)
            {
                char c = format[num3];
                char? nextChar = (num3 + 1 < format.Length) ? new char?(format[num3 + 1]) : null;
                if (c == LeftLiteralChar)
                {
                    if (!nextChar.HasValue)
                    {
                        throw new FormatException(string.Format("Invalid Format: {0}", format));
                    }

                    if (nextChar.Value == LeftLiteralChar)
                    {
                        num3 += 2;
                    }
                    else
                    {
                        if (num3 > num)
                        {
                            yield return new LiteralExpression(format.Substring(num, num3 - num));
                        }

                        num2 = num3;
                        num = num3;
                        int num4 = format.IndexOf(RightLiteralChar, num3 + 1);
                        if (num4 < 0)
                        {
                            throw new FormatException(string.Format("Invalid Format: {0}", format));
                        }

                        yield return new FormatExpression(format.Substring(num2, num4 - num2 + 1), cachedResult);
                        num3 = num4 + 1;
                        num = num3;
                    }
                }
                else if (c == RightLiteralChar)
                {
                    if (!nextChar.HasValue)
                    {
                        throw new FormatException(string.Format("Invalid Format: {0}", format));
                    }

                    if (nextChar.Value != RightLiteralChar)
                    {
                        throw new FormatException(string.Format("Invalid Format: {0}", format));
                    }

                    num3 += 2;
                }
                else
                {
                    num3++;
                }
            }

            if (num < format.Length)
            {
                yield return new LiteralExpression(format.Substring(num));
            }
        }

        // RVA: 0x19E8A9C
        static NamedFormatExtension()
        {
            Literals = new char[]
            {
                '{',
                '}'
            };
            LeftLiteralChar = Literals[0];
            RightLiteralChar = Literals[1];
            LeftLiteral = LeftLiteralChar.ToString();
            RightLiteral = RightLiteralChar.ToString();
            EscapedLeftLiteral = LeftLiteral + LeftLiteral;
            EscapedRightLiteral = RightLiteral + RightLiteral;
        }
    }
}
