// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.Currency
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.Billing
{
    public class Currency
    {
        private static readonly Dictionary<string, string> currencySymbolMap;
        public string Code { get; private set; }
        public string Symbol { get; private set; }




        // RVA: 0x1774BC8
        public static Currency Resolve(string currencyCode)
        {
                        return Resolve(currencyCode, new Currency(currencyCode, ""));
        }

        // RVA: 0x1777D98
        public static Currency Resolve(string currencyCode, Currency defaultValue)
        {
                        if (!string.IsNullOrEmpty(currencyCode) && currencySymbolMap.ContainsKey(currencyCode) && !string.IsNullOrEmpty(currencySymbolMap[currencyCode]))
                        {
                            return new Currency(currencyCode, currencySymbolMap[currencyCode]);
                        }

                        return defaultValue;
        }

        // RVA: 0x1777D60
        public Currency(string code, string symbol)
        {
            Code = code;
            Symbol = symbol;
        }

        // RVA: 0x1777EA8
        static Currency()
        {
                        currencySymbolMap = new Dictionary<string, string>();
                        currencySymbolMap["AED"] = "د.إ.‏";
                        currencySymbolMap["AFN"] = "؋";
                        currencySymbolMap["ALL"] = "Lekë";
                        currencySymbolMap["AMD"] = "դր.";
                        currencySymbolMap["ARS"] = "$";
                        currencySymbolMap["AUD"] = "$";
                        currencySymbolMap["AZN"] = "man.";
                        currencySymbolMap["BAM"] = "KM";
                        currencySymbolMap["BDT"] = "৳";
                        currencySymbolMap["BGN"] = "лв.";
                        currencySymbolMap["BHD"] = "د.ب.‏";
                        currencySymbolMap["BOB"] = "Bs";
                        currencySymbolMap["BRL"] = "R$";
                        currencySymbolMap["BYR"] = "р.";
                        currencySymbolMap["BZD"] = "$";
                        currencySymbolMap["CAD"] = "$";
                        currencySymbolMap["CHF"] = "$";
                        currencySymbolMap["CLP"] = "$";
                        currencySymbolMap["CNY"] = "¥";
                        currencySymbolMap["COP"] = "$";
                        currencySymbolMap["CRC"] = "₡";
                        currencySymbolMap["CZK"] = "Kč";
                        currencySymbolMap["DKK"] = "kr";
                        currencySymbolMap["DOP"] = "$";
                        currencySymbolMap["DZD"] = "د.ج.‏";
                        currencySymbolMap["EGP"] = "ج.م.‏";
                        currencySymbolMap["ETB"] = "ብር";
                        currencySymbolMap["EUR"] = "€";
                        currencySymbolMap["GBP"] = "£";
                        currencySymbolMap["GEL"] = "";
                        currencySymbolMap["GTQ"] = "Q";
                        currencySymbolMap["HKD"] = "$";
                        currencySymbolMap["HNL"] = "L";
                        currencySymbolMap["HRK"] = "kn";
                        currencySymbolMap["HUF"] = "Ft";
                        currencySymbolMap["IDR"] = "Rp";
                        currencySymbolMap["ILS"] = "₪";
                        currencySymbolMap["INR"] = "₹";
                        currencySymbolMap["IQD"] = "د.ع.‏";
                        currencySymbolMap["IRR"] = "ریال";
                        currencySymbolMap["ISK"] = "kr";
                        currencySymbolMap["JMD"] = "$";
                        currencySymbolMap["JOD"] = "د.أ.‏";
                        currencySymbolMap["JPY"] = "￥";
                        currencySymbolMap["KES"] = "Ksh";
                        currencySymbolMap["KHR"] = "៛";
                        currencySymbolMap["KRW"] = "₩";
                        currencySymbolMap["KWD"] = "د.ك.‏";
                        currencySymbolMap["KZT"] = "₸";
                        currencySymbolMap["LAK"] = "₭";
                        currencySymbolMap["LBP"] = "ل.ل.‏";
                        currencySymbolMap["LKR"] = "රු.";
                        currencySymbolMap["LTL"] = "Lt";
                        currencySymbolMap["LYD"] = "د.ل.‏";
                        currencySymbolMap["MAD"] = "د.م.‏";
                        currencySymbolMap["MKD"] = "ден";
                        currencySymbolMap["MOP"] = "MOP$";
                        currencySymbolMap["MXN"] = "$";
                        currencySymbolMap["MYR"] = "RM";
                        currencySymbolMap["NGN"] = "₦";
                        currencySymbolMap["NIO"] = "C$";
                        currencySymbolMap["NOK"] = "kr";
                        currencySymbolMap["NPR"] = "नेरू";
                        currencySymbolMap["NZD"] = "$";
                        currencySymbolMap["OMR"] = "ر.ع.‏";
                        currencySymbolMap["PAB"] = "B/.";
                        currencySymbolMap["PEN"] = "S/.";
                        currencySymbolMap["PHP"] = "₱";
                        currencySymbolMap["PKR"] = "Rs";
                        currencySymbolMap["PLN"] = "zł";
                        currencySymbolMap["PYG"] = "₲";
                        currencySymbolMap["QAR"] = "ر.ق.‏";
                        currencySymbolMap["RON"] = "";
                        currencySymbolMap["RSD"] = "din.";
                        currencySymbolMap["RUB"] = "руб.";
                        currencySymbolMap["RUR"] = "р.";
                        currencySymbolMap["RWF"] = "RF";
                        currencySymbolMap["SAR"] = "ر.س.‏";
                        currencySymbolMap["SEK"] = "kr";
                        currencySymbolMap["SGD"] = "$";
                        currencySymbolMap["SYP"] = "ل.س.‏";
                        currencySymbolMap["THB"] = "฿";
                        currencySymbolMap["TJS"] = "сом";
                        currencySymbolMap["TND"] = "د.ت.‏";
                        currencySymbolMap["TRL"] = "TL";
                        currencySymbolMap["TRY"] = "₺";
                        currencySymbolMap["TTD"] = "$";
                        currencySymbolMap["TWD"] = "NT$";
                        currencySymbolMap["UAH"] = "₴";
                        currencySymbolMap["USD"] = "$";
                        currencySymbolMap["UYU"] = "$";
                        currencySymbolMap["UZS"] = "soʻm";
                        currencySymbolMap["VEF"] = "Bs.";
                        currencySymbolMap["VND"] = "₫";
                        currencySymbolMap["YER"] = "ر.ي.‏";
                        currencySymbolMap["ZAR"] = "R";
        }
    }
}
