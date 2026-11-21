// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.UriHelper
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot
{
    public static class UriHelper
    {
        private static readonly string hexLowerChar;

        // RVA: 0x16BD5F4
        public static string Escape(string toEscape)
        {
                        if (toEscape == null)
                        {
                            throw new ArgumentNullException("toEscape");
                        }

                        StringBuilder stringBuilder = new StringBuilder(toEscape.Length);
                        foreach (byte b in Encoding.UTF8.GetBytes(toEscape))
                        {
                            char c = (char)b;
                            if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '_' || (c >= '0' && c <= '9') || c == '~' || c == '-')
                            {
                                stringBuilder.Append(c);
                            }
                            else
                            {
                                stringBuilder.Append(HexEscape(c));
                            }
                        }

                        return stringBuilder.ToString();
        }

        // RVA: 0x16BD7EC
        private static bool NeedToEscapeDataChar(char b)
        {
                        return !((b >= 'A' && b <= 'Z') || (b >= 'a' && b <= 'z') || b == '_' || (b >= '0' && b <= '9') || b == '~' || b == '-');
        }

        // RVA: 0x16BD84C
        private static object HexEscape(char character)
        {
                        if (character >= (char)256)
                        {
                            throw new ArgumentOutOfRangeException("character");
                        }

                        return "%" + hexLowerChar[(character >> 4) & 0xF] + hexLowerChar[character & 0xF];
        }

        // RVA: 0x16BD984
        static UriHelper()
        {
                        hexLowerChar = "0123456789abcdef";
        }
    }
}
