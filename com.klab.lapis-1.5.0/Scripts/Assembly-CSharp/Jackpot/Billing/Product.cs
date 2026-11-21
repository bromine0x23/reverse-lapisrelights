// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Billing.Product
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
    public class Product
    {
        private Currency currency;
        public string Id { get; private set; }
        public string Type { get; private set; }
        public string Title { get; private set; }
        public string Description { get; private set; }
        public string Price { get; set; }
        public string FormattedPrice { get; set; }
        public string CurrencyCode { get { return currency.Code; } }
        public string CurrencySymbol { get { return currency.Symbol; } }












        // RVA: 0x1774C5C
        public Product(string id, string type, string title, string description, string price, string formattedPrice, Currency currency)
        {
            Id = id;
            Type = type;
            Title = title;
            Description = description;
            Price = price;
            FormattedPrice = formattedPrice;
            this.currency = currency;
        }

        // RVA: 0x17804D0
        public override string ToString()
        {
                        return string.Format("[Product: Id={0}, Type={1}, Title={2}, Description={3}, Price={4}, FormattedPrice={5}, CurrencyCode={6}, CurrencySymbol={7}]", Id, Type, Title, Description, Price, FormattedPrice, Currency.Code, Currency.Symbol);
        }
    }
}
