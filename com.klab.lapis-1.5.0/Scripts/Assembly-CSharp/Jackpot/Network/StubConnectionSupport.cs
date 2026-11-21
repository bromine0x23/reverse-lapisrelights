// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.StubConnectionSupport
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
    public static class StubConnectionSupport
    {

        public enum PathRules
        {
            CapitalizeAndRemoveSeparator = 0,
            Capitalize = 1,
            Untouched = 2
        }

        // RVA: 0x1E99FE4
        [Obsolete]
        public static void RegisterRuleByUrl(string url, string resourceFilePath)
        {
            DefaultStubRequestProvider.RegisterRuleByUrl(url, resourceFilePath);
        }

        // RVA: 0x1E9A05C
        [Obsolete]
        public static void RegisterRuleByHost(string host, string mappedResourcesStubBasePath)
        {
            DefaultStubRequestProvider.RegisterRuleByHost(host, mappedResourcesStubBasePath);
        }

        // RVA: 0x1E9A0D8
        [Obsolete]
        public static void RegisterRuleByHost(string host, string mappedResourcesStubBasePath, StubConnectionSupport.PathRules pathRule)
        {
            DefaultStubRequestProvider.RegisterRuleByHost(host, mappedResourcesStubBasePath, ConvertPathRule(pathRule));
        }

        // RVA: 0x1E9A180
        [Obsolete]
        public static void Clean()
        {
            DefaultStubRequestProvider.Clean();
        }

        // RVA: 0x1E9A16C
        private static DefaultStubRequestProvider.PathRules ConvertPathRule(StubConnectionSupport.PathRules rule)
        {
            switch (rule)
            {
                case StubConnectionSupport.PathRules.CapitalizeAndRemoveSeparator:
                    return DefaultStubRequestProvider.PathRules.CapitalizeAndRemoveSeparator;
                case StubConnectionSupport.PathRules.Capitalize:
                    return DefaultStubRequestProvider.PathRules.Capitalize;
                default:
                    return DefaultStubRequestProvider.PathRules.Untouched;
            }
        }
    }
}
