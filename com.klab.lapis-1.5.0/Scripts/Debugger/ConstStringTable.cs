// =============================================================================
//  Lapis Re:Lights 1.5.0 — Debugger.dll
//  ConstStringTable
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

    public static class ConstStringTable
    {
        private static string[] secDict;
        private static string[] tenDict;

        // RVA: 0x2ED2F80
        static ConstStringTable()
        {
            secDict = new string[100];
            tenDict = new string[10];

            for (int i = 0; i < 100; i++)
            {
                secDict[i] = i.ToString("00").Intern();
            }

            for (int i = 0; i < 10; i++)
            {
                tenDict[i] = i.ToString().Intern();
            }
        }

        // RVA: 0x2ED3144
        public static string GetTimeIntern(int time)
        {
            return time < 100 ? secDict[time] : time.ToString();
        }

        // RVA: 0x2ED31FC
        public static string GetNumIntern(int num)
        {
            if (num < 10)
            {
                return tenDict[num];
            }

            return num < 100 ? secDict[num] : num.ToString();
        }
    }
