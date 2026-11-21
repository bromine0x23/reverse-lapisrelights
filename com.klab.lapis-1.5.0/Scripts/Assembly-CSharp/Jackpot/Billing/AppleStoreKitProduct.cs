// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.AppleStoreKitProduct
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
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
    public class AppleStoreKitProduct
    {
        private ILogger logger;
        public string LocalizedDescription { get; private set; }
        public string LocalizedTitle { get; private set; }
        public Decimal Price { get; private set; }
        public string FormattedPrice { get; private set; }
        public string CurrencyCode { get; private set; }
        public string CurrencySymbol { get; private set; }
        public string CountryCode { get; private set; }
        public string ProductIdentifier { get; private set; }
















        // RVA: 0x176FD98
        public AppleStoreKitProduct(Dictionary<string, object> dict)
        {
                        logger = Logger.Get<AppleStoreKitProduct>();
                        if (dict.ContainsKey("localizedDescription"))
                        {
                            LocalizedDescription = dict["localizedDescription"] as string;
                        }
                        if (dict.ContainsKey("localizedTitle"))
                        {
                            LocalizedTitle = dict["localizedTitle"] as string;
                        }
                        if (dict.ContainsKey("price"))
                        {
                            Price = Convert.ToDecimal(dict["price"]);
                            if (dict["price"].GetType() == typeof(double))
                            {
                                double num = Convert.ToDouble(dict["price"]);
                                if (num != (double)Price)
                                {
                                    logger.Error("invalid price double:{0}, decimal:{1}", num.ToString("G17"), Price.ToString("G17"));
                                    Price = 0m;
                                }
                            }
                        }
                        if (dict.ContainsKey("formattedPrice"))
                        {
                            FormattedPrice = dict["formattedPrice"] as string;
                        }
                        if (dict.ContainsKey("currencyCode"))
                        {
                            CurrencyCode = dict["currencyCode"] as string;
                        }
                        if (dict.ContainsKey("currencySymbol"))
                        {
                            CurrencySymbol = dict["currencySymbol"] as string;
                        }
                        if (dict.ContainsKey("countryCode"))
                        {
                            CountryCode = dict["countryCode"] as string;
                        }
                        if (dict.ContainsKey("productIdentifier"))
                        {
                            ProductIdentifier = dict["productIdentifier"] as string;
                        }
        }

        // RVA: 0x177040C
        public override string ToString()
        {
                        return string.Format("LocalizedDescription:{0}\nLocalizedTitle:{1}\nPrice:{2}\nFormattedPrice:{3}\nCurrencyCode:{4}\nCurrencySymbol:{5}\nCountryCode:{6}\nProductIdentifier:{7}", LocalizedDescription, LocalizedTitle, Price, FormattedPrice, CurrencyCode, CurrencySymbol, CountryCode, ProductIdentifier);
        }
    }
}
