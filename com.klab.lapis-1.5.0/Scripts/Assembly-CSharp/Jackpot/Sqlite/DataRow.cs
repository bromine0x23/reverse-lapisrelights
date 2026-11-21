// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Sqlite.DataRow
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

namespace Jackpot.Sqlite
{
    public class DataRow
    {
        private object[] data;
        private Dictionary<string, int> name2index;
        private string strWord;
        public object this[string column]
        {
            get { return data[name2index[column]]; }
            set { data[name2index[column]] = value; }
        }
        public string StrWord { get { return strWord; } }
        public object this[int index]
        {
            get { return data[index]; }
            set { data[index] = value; }
        }
        // RVA: 0x16B8784
        public DataRow(object[] data, Dictionary<string, int> name2index)
        {
            this.data = data;
            this.name2index = name2index;
            StringBuilder stringBuilder = new StringBuilder();
            int count = name2index.Keys.Count;
            int num = 1;
            foreach (string key in name2index.Keys)
            {
                stringBuilder.Append(string.Format("{0},,,{1}", (num == 1) ? "" : ",,,", data[name2index[key]]));
                num++;
            }

            strWord = stringBuilder.ToString();
        }

        // RVA: 0x16B89A4
        public string[] GetColumnNames()
        {
            string[] array = new string[name2index.Count];
            int num = 0;
            foreach (string key in name2index.Keys)
            {
                array[num] = key;
                num++;
            }

            return array;
        }

        // RVA: 0x16B8C7C
        public string get_StrWord()
        {
            return strWord;
        }

    }
}
