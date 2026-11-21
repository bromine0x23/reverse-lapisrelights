// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.GoogleIabSkuDetail
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
    public class GoogleIabSkuDetail
    {
        public string ProductId { get; private set; }
        public string Type { get; private set; }
        public string Price { get; private set; }
        public string FormattedPrice { get; private set; }
        public long PriceAmountMicros { get; private set; }
        public string PriceCurrencyCode { get; private set; }
        public string Title { get; private set; }
        public string Description { get; private set; }
















        // RVA: 0x177B074
        public GoogleIabSkuDetail(Dictionary<string, object> dict)
        {
                        if (dict.ContainsKey("productId"))
                        {
                            ProductId = dict["productId"] as string;
                        }
                        if (dict.ContainsKey("type"))
                        {
                            Type = dict["type"] as string;
                        }
                        if (dict.ContainsKey("price"))
                        {
                            FormattedPrice = dict["price"] as string;
                        }
                        if (dict.ContainsKey("price_amount_micros"))
                        {
                            PriceAmountMicros = Convert.ToInt64(dict["price_amount_micros"]);
                            Price = ((decimal)PriceAmountMicros / 1000000m).ToString("F6");
                        }
                        if (dict.ContainsKey("price_currency_code"))
                        {
                            PriceCurrencyCode = dict["price_currency_code"] as string;
                        }
                        if (dict.ContainsKey("title"))
                        {
                            Title = dict["title"] as string;
                        }
                        if (dict.ContainsKey("description"))
                        {
                            Description = dict["description"] as string;
                        }
        }

        // RVA: 0x177B40C
        public override string ToString()
        {
                        return string.Format("ProductId:{0}\nType:{1}\nPrice:{2}\nPriceAmountMicros:{3}\nPriceCurrencyCode:{4}\nTitle:{5}\nDescription:{6}", ProductId, Type, Price, PriceAmountMicros, PriceCurrencyCode, Title, Description);
        }
    }
}
