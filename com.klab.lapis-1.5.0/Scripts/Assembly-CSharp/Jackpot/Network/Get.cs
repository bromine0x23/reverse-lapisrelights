// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.Get
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

namespace Jackpot.Network
{
    public class Get : HTTPRequest
    {
        private QueryParameter parameters;

        // RVA: 0x1E90DCC
        public Get(string url)
            : this(url, HTTPRequestType.Text)
        {
        }

        // RVA: 0x1E90DD4
        public Get(string url, HTTPRequestType requestType)
            : base(url, HTTPMethod.Get, requestType)
        {
            parameters = new QueryParameter();
            if (Uri != null && !string.IsNullOrEmpty(Uri.Query))
            {
                parameters.AddParam(QueryParameter.ParseQuery(Uri.Query));
                Uri = new Uri(GetUrlRemovedQuery(Uri));
            }
        }

        // RVA: 0x1E914D0
        public void AddParam(string name, string value, string[] moreValues)
        {
            if (parameters != null) parameters.AddParam(name, value, moreValues);
        }

        // RVA: 0x1E91570
        public void AddParam(Dictionary<string, string> dict)
        {
            if (parameters != null) parameters.AddParam(dict);
        }

        // RVA: 0x1E916A0
        public void AddParam(Dictionary<string, List<string>> dict)
        {
            if (parameters != null) parameters.AddParam(dict);
        }

        // RVA: 0x1E918F8
        public string GetParam(string name)
        {
            return (parameters != null) ? parameters.GetParam(name) : null;
        }

        // RVA: 0x1E919D4
        public List<string> GetParams(string name)
        {
            return (parameters != null) ? parameters.GetParams(name) : null;
        }

        // RVA: 0x1E91AD4
        public Dictionary<string, List<string>> GetAllParams()
        {
            return (parameters != null) ? parameters.GetAllParams() : null;
        }

        // RVA: 0x1E91B5C
        public bool ParamsIsEmpty()
        {
            return parameters != null && parameters.IsEmpty();
        }

        // RVA: 0x1E91BD8
        protected override void OnBeforeSend()
        {
            Uri = CreateRequestUri(Uri, parameters);
        }

        // RVA: 0x1E91C00
        private Uri CreateRequestUri(Uri uri, QueryParameter parameter)
        {
            string text = uri.ToString();
            if (!parameters.IsEmpty())
            {
                text += parameters.ToQuery();
            }

            return new Uri(text);
        }
    }
}
