// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.HTTPResponse
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
    public class HTTPResponse
    {
        private const string StatusKey = "STATUS";
        private Dictionary<string, string> responseHeaders;
        public Dictionary<string, string> Headers
        {
            get
            {
                if (responseHeaders == null)
                {
                    responseHeaders = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                }

                return responseHeaders;
            }
            set
            {
                responseHeaders = value;
            }
        }
        public HTTPStatus Status { get; private set; }
        public string Text { get; set; }
        public byte[] Bytes { get; set; }
        public Texture2D Texture { get; set; }
        public AssetBundle Bundle { get; set; }
        public string ErrorText { get; set; }
        public bool HasErrorText { get { return !string.IsNullOrEmpty(ErrorText); } }
        public Exception Exception { get; set; }
        // RVA: 0x1E96688















        // RVA: 0x1E96688
        public HTTPResponse()
            : this(HTTPStatus.OK)
        {
        }

        // RVA: 0x1E96690
        public HTTPResponse(HTTPStatus status)
            : this(status, string.Empty)
        {
        }

        // RVA: 0x1E93D30
        public HTTPResponse(HTTPStatus status, string errorText)
        {
            Status = status;
            ErrorText = errorText;
            Headers = new Dictionary<string, string>();
        }

        // RVA: 0x1E966F8
        public HTTPResponse(HTTPStatus status, string errorText, string headersJson)
        {
            Status = status;
            ErrorText = errorText;
            Headers = ConvertHeaderTextToHeader(headersJson);
            if (Headers == null)
            {
                Headers = new Dictionary<string, string>();
            }

            Headers["STATUS"] = ((int)Status).ToString();
        }

        // RVA: 0x1E96894
        public HTTPResponse(HTTPStatus status, string errorText, Dictionary<string, string> headers)
        {
            Status = status;
            ErrorText = errorText;
            Headers = headers;
            if (Headers == null)
            {
                Headers = new Dictionary<string, string>();
            }

            Headers["STATUS"] = ((int)Status).ToString();
        }

        // RVA: 0x1E933F0
        public HTTPResponse(Dictionary<string, string> headers)
            : this(headers, string.Empty)
        {
        }

        // RVA: 0x1E93C08
        public HTTPResponse(Dictionary<string, string> headers, string errorText)
        {
            ErrorText = errorText;
            Headers = headers;
            if (Headers == null)
            {
                Headers = new Dictionary<string, string>();
            }

            Status = (Headers.ContainsKey("STATUS") && !string.IsNullOrEmpty(Headers["STATUS"]))
                ? ((HTTPStatus)int.Parse(Headers["STATUS"]))
                : HTTPStatus.OK;
        }

        // RVA: 0x1E9699C
        public string GetHeader(string key, string defaultValue = "")
        {
            if (HeaderContains(key))
            {
                defaultValue = Headers[key];
            }

            return defaultValue;
        }

        // RVA: 0x1E96A28
        public bool HeaderContains(string key)
        {
            return Headers != null && Headers.ContainsKey(key) && !string.IsNullOrEmpty(Headers[key]);
        }

        // RVA: 0x1E9680C
        private Dictionary<string, string> ConvertHeaderTextToHeader(string headersJson)
        {
            if (!string.IsNullOrEmpty(headersJson))
            {
                JsonCollectionSerializer<string, string> jsonCollectionSerializer = JsonUtility.FromJson<JsonCollectionSerializer<string, string>>(headersJson);
                if (jsonCollectionSerializer != null)
                {
                    Headers = jsonCollectionSerializer.ToDictionary();
                }
            }

            return Headers;
        }
    }
}
