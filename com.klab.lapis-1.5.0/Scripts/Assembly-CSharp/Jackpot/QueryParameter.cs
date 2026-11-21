// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.QueryParameter
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
    public class QueryParameter
    {
        private Dictionary<string, List<string>> parameters;
        private List<string> notEscapeParameterKeys;

        // RVA: 0x1E90F5C
        public QueryParameter()
            : this(new Dictionary<string, List<string>>())
        {
        }

        // RVA: 0x1E940DC
        public QueryParameter(Dictionary<string, List<string>> dictionary)
        {
            parameters = dictionary;
            notEscapeParameterKeys = new List<string>();
        }

        // RVA: 0x1E90FC8
        public static QueryParameter ParseQuery(string queryString)
        {
            QueryParameter queryParameter = new QueryParameter();
            if (string.IsNullOrEmpty(queryString))
            {
                return queryParameter;
            }

            if (queryString.Substring(0, 1) == "?")
            {
                queryString = queryString.Substring(1);
            }

            string[] array = queryString.Split(new char[]
            {
                '&'
            });
            for (int i = 0; i < array.Length; i++)
            {
                string[] array2 = array[i].Split(new char[]
                {
                    '='
                });
                if (array2.Length != 0 && array2.Length != 1)
                {
                    string text = array2[0];
                    string text2 = array2[1];
                    if (!string.IsNullOrEmpty(text))
                    {
                        if (string.IsNullOrEmpty(text2))
                        {
                            text2 = string.Empty;
                        }

                        queryParameter.AddParam(Uri.UnescapeDataString(text), Uri.UnescapeDataString(text2));
                    }
                }
            }

            return queryParameter;
        }

        // RVA: 0x1EA0008
        public void AddNotEscapeParameterKeys(string key)
        {
            if (!notEscapeParameterKeys.Contains(key))
            {
                notEscapeParameterKeys.Add(key);
            }
        }

        // RVA: 0x1EA00A0
        public List<string> GetAllotEscapeParameterKeys()
        {
            return new List<string>(notEscapeParameterKeys);
        }

        // RVA: 0x1E914E8
        public void AddParam(string name, string value, string[] moreValues)
        {
            AddParam(name, value);
            if (moreValues != null && moreValues.Length >= 1)
            {
                for (int i = 0; i < moreValues.Length; i++)
                {
                    AddParam(name, moreValues[i]);
                }
            }
        }

        // RVA: 0x1E911F0
        public void AddParam(QueryParameter queryParam)
        {
            foreach (KeyValuePair<string, List<string>> item in queryParam.GetAllParams())
            {
                foreach (string text in queryParam.GetParams(item.Key))
                {
                    AddParam(item.Key, text);
                }
            }
        }

        // RVA: 0x1E91588
        public void AddParam(Dictionary<string, string> dict)
        {
            foreach (KeyValuePair<string, string> item in dict)
            {
                AddParam(item.Key, item.Value);
            }
        }

        // RVA: 0x1E916B8
        public void AddParam(Dictionary<string, List<string>> dict)
        {
            foreach (KeyValuePair<string, List<string>> item in dict)
            {
                foreach (string text in item.Value)
                {
                    AddParam(item.Key, text);
                }
            }
        }

        // RVA: 0x1E91910
        public string GetParam(string name)
        {
            if (parameters.ContainsKey(name))
            {
                return parameters[name][0];
            }

            return string.Empty;
        }

        // RVA: 0x1E919EC
        public List<string> GetParams(string name)
        {
            if (parameters.ContainsKey(name))
            {
                return new List<string>(parameters[name]);
            }

            return new List<string>();
        }

        // RVA: 0x1E91AEC
        public Dictionary<string, List<string>> GetAllParams()
        {
            return new Dictionary<string, List<string>>(parameters);
        }

        // RVA: 0x1E91B74
        public bool IsEmpty()
        {
            return parameters.Count == 0;
        }

        // RVA: 0x1EA0110
        public override string ToString()
        {
            return CreateQueryString(parameters);
        }

        // RVA: 0x1E91CC0
        public string ToQuery()
        {
            if (IsEmpty())
            {
                return string.Empty;
            }

            return string.Format("?{0}", CreateQueryString(parameters));
        }

        // RVA: 0x1E9FF14
        private void AddParam(string name, string value)
        {
            if (!parameters.ContainsKey(name))
            {
                parameters[name] = new List<string>();
            }

            parameters[name].Add(value);
        }

        // RVA: 0x1EA0118
        private string CreateQueryString(Dictionary<string, List<string>> parameters)
        {
            if (IsEmpty())
            {
                return string.Empty;
            }

            StringBuilder stringBuilder = new StringBuilder();
            foreach (KeyValuePair<string, List<string>> parameter in parameters)
            {
                string key = parameter.Key;
                string text = UriHelper.Escape(key);
                foreach (string value in parameter.Value)
                {
                    if (notEscapeParameterKeys.Contains(key))
                    {
                        stringBuilder.AppendFormat("{0}={1}&", key, value ?? string.Empty);
                    }
                    else
                    {
                        stringBuilder.AppendFormat("{0}={1}&", text, UriHelper.Escape(value ?? string.Empty));
                    }
                }
            }

            if (stringBuilder.Length > 0)
            {
                stringBuilder.Remove(stringBuilder.Length - 1, 1);
            }

            return stringBuilder.ToString();
        }
    }
}
