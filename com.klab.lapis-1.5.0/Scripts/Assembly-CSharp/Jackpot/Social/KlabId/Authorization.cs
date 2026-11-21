// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.KlabId.Authorization
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
    public class Authorization
    {
        private const string redirectUriHierPart = "://klab_id/callback";
        private static ILogger logger;
        private static string redirectUri;
        private static string state;
        private static Action<string> onSuccess;

        // RVA: 0x16B6E04
        public static void Start(Action<string> onSuccess, string state)
        {
            if (Authorization.state != null)
            {
                logger.Info("Already Authorization processing :{0}, cancel:{1}", new object[]
                {
                    Authorization.state,
                    state
                });
                return;
            }

            Authorization.onSuccess = onSuccess;
            Authorization.state = state;
            redirectUri = Config.RedirectUriScheme + redirectUriHierPart;
            Execute();
        }

        // RVA: 0x16B774C
        public static void Abort()
        {
            state = null;
            onSuccess = null;
        }

        // RVA: 0x16B77BC
        public static void HandleUriScheme(Uri uri)
        {
            if (string.IsNullOrEmpty(redirectUri))
            {
                logger.Info("Expected redirectUri was not null or empty");
                return;
            }

            if (uri == null)
            {
                return;
            }

            if (!uri.AbsoluteUri.StartsWith(redirectUri))
            {
                logger.Info("Invalid uri:{0}, expect:{1}", new object[]
                {
                    uri,
                    redirectUri
                });
                return;
            }

            QueryParameter queryParameter = QueryParameter.ParseQuery(uri.Query);
            string param = queryParameter.GetParam("code");
            string param2 = queryParameter.GetParam("state");
            if (param2 != state)
            {
                logger.Info("Invalid state:{0}, expect:{1}", new object[]
                {
                    param2,
                    state
                });
                return;
            }

            state = null;
            if (onSuccess == null)
            {
                logger.Info("Success delegate is null");
                return;
            }

            onSuccess(param);
            onSuccess = null;
        }

        // RVA: 0x16B704C
        private static void Execute()
        {
            QueryParameter queryParameter = new QueryParameter();
            queryParameter.AddParam("redirect_uri", redirectUri, new string[0]);
            queryParameter.AddParam("response_type", "code", new string[0]);
            queryParameter.AddParam("state", state, new string[0]);
            queryParameter.AddParam("client_id", Config.ClientId, new string[0]);
            StringBuilder stringBuilder = new StringBuilder();
            foreach (ScopeType scopeType in Config.ScopeTypes)
            {
                if (stringBuilder.Length >= 1)
                {
                    stringBuilder.Append("+");
                }

                stringBuilder.Append(scopeType.Name);
            }

            queryParameter.AddParam("scope", stringBuilder.ToString(), new string[0]);
            queryParameter.AddNotEscapeParameterKeys("scope");
            if (!string.IsNullOrEmpty(Config.Lang))
            {
                queryParameter.AddParam("lang", Config.Lang, new string[0]);
            }

            Application.OpenURL(Config.EndpointUrl + "/auth?" + queryParameter.ToString());
        }

        // RVA: 0x16B7D08
        public Authorization()
        {
        }

        // RVA: 0x16B7D10
        private static void .cctor()
        {
            logger = Logger.Get<Authorization>();
        }
    }
}
