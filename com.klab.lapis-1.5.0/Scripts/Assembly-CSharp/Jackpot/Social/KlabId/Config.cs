// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.KlabId.Config
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

namespace Jackpot.Social.KlabId
{
    public class Config
    {
        public const string DevEndpointUrl = "https://dev-www.id.klabgames.net";
        public const string ProdEndpointUrl = "https://www.id.klabgames.net";
        public static string EndpointUrl { get; set; }
        public static string ClientId { get; set; }
        public static string RedirectUriScheme { get; set; }
        public static string Lang { get; set; }
        public static List<ScopeType> ScopeTypes { get; set; }










        // RVA: 0x16B80C4
        public static void Set(string endpointUrl, string clientId, string redirectUriScheme)
        {
            Set(endpointUrl, clientId, redirectUriScheme, null);
        }

        // RVA: 0x16B80CC
        public static void Set(string endpointUrl, string clientId, string redirectUriScheme, string lang)
        {
            List<ScopeType> scopeType = new List<ScopeType>();
            scopeType.Add(ScopeType.TransferUserData);
            Set(endpointUrl, clientId, redirectUriScheme, lang, scopeType);
        }

        // RVA: 0x16B81A8
        public static void Set(string endpointUrl, string clientId, string redirectUriScheme, string lang, List<ScopeType> scopeType)
        {
            EndpointUrl = endpointUrl;
            ClientId = clientId;
            RedirectUriScheme = redirectUriScheme;
            Lang = lang;
            ScopeTypes = scopeType;
        }

        // RVA: 0x16B82E8
        public Config()
        {
        }
    }
}
