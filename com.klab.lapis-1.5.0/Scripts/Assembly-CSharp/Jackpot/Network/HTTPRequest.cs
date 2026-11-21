// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.HTTPRequest
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

namespace Jackpot.Network
{
    public class HTTPRequest
    {
        public delegate void ReceivedDelegate(HTTPStatus status, Dictionary<string, string> headers);

        public delegate void ResponseDelegate(HTTPRequest sender, HTTPResponse response);

        public delegate void ErrorDelegate(HTTPRequest sender, HTTPResponse response);

        public delegate void ProgressDelegate(HTTPRequest sender, HTTPProgress progress);

        private Dictionary<string, string> headers;
        private Dictionary<string, List<string>> body;
        private IMemory attributes;
        private byte[] rawBody;
        public Uri Uri { get; protected set; }
        public HTTPMethod Method { get; protected set; }
        public HTTPRequestType Type { get; protected set; }
        public HTTPRequest.ReceivedDelegate ReceivedHandler { get; set; }
        public HTTPRequest.ResponseDelegate ResponseHandler { get; set; }
        public HTTPRequest.ErrorDelegate ErrorHandler { get; set; }
        public HTTPRequest.ProgressDelegate ProgressHandler { get; set; }
        public bool Sync { get; set; }
        public bool Stub { get; set; }
        public WebProxy Proxy { get; set; }
        public float Timeout { get; set; }
        public int RetryCount { get; set; }
        public float ProgressInterval { get; set; }
        public int BundleVersion { get; set; }
        public string FileName { get; set; }

        // RVA: 0x1E90ED0
        public HTTPRequest(string url, HTTPMethod method = 1, HTTPRequestType type = 0)
            : this(new Uri(url), method, type)
        {
        }

        // RVA: 0x1E9488C
        public HTTPRequest(Uri uri, HTTPMethod method = 1, HTTPRequestType type = 0)
        {
            Uri = uri;
            Method = method;
            Type = type;
            Timeout = Config.Timeout;
            RetryCount = Config.RetryCount;
            BundleVersion = Config.BundleVersion;
            Sync = Config.SyncRequest;
            Stub = Config.StubRequest;
            headers = new Dictionary<string, string>();
            body = new Dictionary<string, List<string>>();
            attributes = new Memory();
        }

        // RVA: 0x1E94B14
        public HTTPRequest(string url, HTTPRequestType type, HTTPMethod method = 1)
            : this(new Uri(url), method, type)
        {
        }

        // RVA: 0x1E94BA0
        public HTTPRequest(Uri url, HTTPRequestType type, HTTPMethod method = 1)
            : this(url, method, type)
        {
        }

        // RVA: 0x1E93F94
        public void SetHeader(string name, string value)
        {
            name = name.Trim();
            value = value.Trim();
            if (headers.ContainsKey(name))
            {
                headers.Remove(name);
            }

            headers.Add(name, value);
        }

        // RVA: 0x1E94BB0
        public void RemoveHeader(string name)
        {
            headers.Remove(name);
        }

        // RVA: 0x1E91F78
        public string GetHeader(string name)
        {
            name = name.Trim();
            if (headers.ContainsKey(name))
            {
                return headers[name];
            }

            return string.Empty;
        }

        // RVA: 0x1E94C18
        public Dictionary<string, string> GetAllHeaders()
        {
            return new Dictionary<string, string>(headers);
        }

        // RVA: 0x1E94C88
        public string GetHeadersJson()
        {
            string result = string.Empty;
            Dictionary<string, string> allHeaders = GetAllHeaders();
            if (allHeaders.Count >= 1)
            {
                return JsonUtility.ToJson(new JsonCollectionSerializer<string, string>(allHeaders));
            }

            return result;
        }

        // RVA: 0x1E94D40
        public bool HeaderIsEmpty()
        {
            return headers.Count == 0;
        }

        // RVA: 0x1E94DA4
        public void AddBody(string name, string value, string[] moreValues)
        {
            AddBody(name, value);
            if (moreValues != null && moreValues.Length >= 1)
            {
                for (int i = 0; i < moreValues.Length; i++)
                {
                    AddBody(name, moreValues[i]);
                }
            }
        }

        // RVA: 0x1E94F20
        public void AddBody(Dictionary<string, string> dict)
        {
            if (dict != null && dict.Count >= 1)
            {
                foreach (KeyValuePair<string, string> item in dict)
                {
                    AddBody(item.Key, item.Value);
                }
            }
        }

        // RVA: 0x1E95038
        public void SetRawBody(string textData)
        {
            rawBody = Encoding.UTF8.GetBytes(textData);
        }

        // RVA: 0x1E95080
        public void SetRawBody(byte[] byteData)
        {
            rawBody = byteData;
        }

        // RVA: 0x1E95088
        public byte[] GetRawBody()
        {
            return rawBody;
        }

        // RVA: 0x1E95090
        public string GetBody(string name)
        {
            if (body.ContainsKey(name))
            {
                return body[name][0];
            }

            return string.Empty;
        }

        // RVA: 0x1E95154
        public List<string> GetBodies(string name)
        {
            if (body.ContainsKey(name))
            {
                return new List<string>(body[name]);
            }

            return new List<string>();
        }

        // RVA: 0x1E9406C
        public Dictionary<string, List<string>> GetAllBodies()
        {
            return new Dictionary<string, List<string>>(body);
        }

        // RVA: 0x1E9523C
        public bool BodyIsEmpty()
        {
            return body.Count == 0;
        }

        public T GetAttribute<T>(string key)
        {
            return attributes.Get<T>(key);
        }

        public T GetAttribute<T>(string key, T defaultValue)
        {
            return attributes.Get<T>(key, defaultValue);
        }

        // RVA: 0x1E952A0
        public bool ContainsAttribute(string key)
        {
            return attributes.Contains(key);
        }

        public void SetAttribute<T>(string key, T value)
        {
            attributes.Set<T>(key, value);
        }

        // RVA: 0x1E95364
        public void RemoveAttribute(string key)
        {
            attributes.Remove(key);
        }

        // RVA: 0x1E95428
        public void RemoveAllAttributes()
        {
            attributes.Clear();
        }

        // RVA: 0x1E954DC
        public void Send()
        {
            OnBeforeSend();
            if (HTTPService.Instance != null)
            {
                HTTPService.Instance.Request(this);
            }

            OnAfterSend();
        }

        // RVA: 0x1E957C4
        public void Cancel()
        {
            if (HTTPService.Instance != null)
            {
                HTTPService.Instance.Cancel(this);
            }
        }

        // RVA: 0x1E9589C
        protected virtual void OnBeforeSend()
        {
        }

        // RVA: 0x1E958A0
        protected virtual void OnAfterSend()
        {
        }

        // RVA: 0x1E91444
        protected string GetUrlRemovedQuery(Uri uri)
        {
            return uri.ToString().Replace(uri.Query, string.Empty);
        }

        // RVA: 0x1E94E2C
        private void AddBody(string name, string value)
        {
            if (!body.ContainsKey(name))
            {
                body[name] = new List<string>();
            }

            body[name].Add(value);
        }
    }
}
