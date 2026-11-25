// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioLanguage
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  语言表：JSON 载入 Key/Value 列表，运行时替换用户名占位符。
// =============================================================================

using System;
using System.Collections.Generic;
using UnityEngine;

public class ScenarioLanguage : Module
{
    public ScenarioLanguage.LanguageData data;
    public TextAsset language;
    public string UserKeyName;
    public string testKey;

    // RVA: 0x1B83E48
    public override void Init()
    {
        base.Init();
        if (language == null || string.IsNullOrEmpty(language.text))
        {
            return;
        }

        data = JsonUtility.FromJson<LanguageData>(language.text);
        if (data == null)
        {
            return;
        }

        data.Init();
        string userName = Kit.Lua.Invoke<string>("GetUserName");
        data.Set(UserKeyName, userName);
    }

    // RVA: 0x1B84124
    public bool Remove(string key)
    {
        return data.Remove(key);
    }

    // RVA: 0x1B841A4
    public string Get(string key)
    {
        string text = data.Get(key);
        string userName = data.Get(UserKeyName);
        return text.Replace(UserKeyName, userName);
    }

    // RVA: 0x1B842A0
    public void Add(string key, string value)
    {
        data.Add(key, value);
    }

    // RVA: 0x1B84374
    public void Set(string key, string value)
    {
        data.Set(key, value);
    }

    // RVA: 0x1B8438C
    public void Test()
    {
    }

    // RVA: 0x1B84390
    public ScenarioLanguage()
    {
        data = new LanguageData();
        UserKeyName = "[USER_NAME]";
    }

    [Serializable]
    public class LanguageData
    {
        public List<string> Key;
        public List<string> Value;
        public Dictionary<string, string> dic;

        // RVA: 0x1B83F6C
        public void Init()
        {
            dic.Clear();
            for (int i = 0; i < Key.Count; i++)
            {
                dic[Key[i]] = Value[i];
            }
        }

        // RVA: 0x1B8413C
        public bool Remove(string key)
        {
            return dic.Remove(key);
        }

        // RVA: 0x1B841FC
        public string Get(string key)
        {
            string value;
            if (!dic.TryGetValue(key, out value) || value == null)
            {
                value = string.Empty;
            }
            return value;
        }

        // RVA: 0x1B842B8
        public void Add(string key, string value)
        {
            if (string.IsNullOrEmpty(key))
            {
                throw new Exception("Key is Null");
            }
            dic.Add(key, value);
        }

        // RVA: 0x1B84068
        public void Set(string key, string value)
        {
            if (string.IsNullOrEmpty(key))
            {
                throw new Exception("Key is Null");
            }
            dic[key] = value;
        }

        // RVA: 0x1B84404
        public LanguageData()
        {
            Key = new List<string>();
            Value = new List<string>();
            dic = new Dictionary<string, string>();
        }
    }
}
