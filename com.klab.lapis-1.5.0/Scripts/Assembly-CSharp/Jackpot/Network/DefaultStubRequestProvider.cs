// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.DefaultStubRequestProvider
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

namespace Jackpot.Network
{
    public static class DefaultStubRequestProvider
    {

        public enum PathRules
        {
            CapitalizeAndRemoveSeparator = 0,
            Capitalize = 1,
            Untouched = 2
        }
        private static readonly ILogger logger;
        private static Dictionary<string, string> urlMappingRules;
        private static Dictionary<string, string> hostMappingRules;
        private static Dictionary<string, DefaultStubRequestProvider.PathRules> pathRules;

        // RVA: 0x19F87F0
        public static void Clean()
        {
            urlMappingRules.Clear();
            hostMappingRules.Clear();
            pathRules.Clear();
        }

        // RVA: 0x19F8BFC
        public static void RegisterRuleByUrl(string url, string resourceFilePath)
        {
            if (urlMappingRules.ContainsKey(url))
            {
                urlMappingRules.Remove(url);
            }

            urlMappingRules.Add(url, resourceFilePath);
        }

        // RVA: 0x19F8D0C
        public static void RegisterRuleByHost(string host, string mappedResourcesStubBasePath)
        {
            RegisterRuleByHost(host, mappedResourcesStubBasePath, DefaultStubRequestProvider.PathRules.CapitalizeAndRemoveSeparator);
        }

        // RVA: 0x19F8D84
        public static void RegisterRuleByHost(string host, string mappedResourcesStubBasePath, DefaultStubRequestProvider.PathRules pathRule)
        {
            if (hostMappingRules.ContainsKey(host))
            {
                hostMappingRules.Remove(host);
            }

            hostMappingRules.Add(host, mappedResourcesStubBasePath);
            if (pathRules.ContainsKey(host))
            {
                pathRules.Remove(host);
            }

            pathRules.Add(host, pathRule);
            logger.Info(string.Format("registered rule. host: {0}, mappedPath: {1}, pathRule: {2}", host, mappedResourcesStubBasePath, pathRule));
        }

        // RVA: 0x19F9004
        public static StubRequestResult Request(HTTPRequest request)
        {
            if (request.Type != HTTPRequestType.Text)
            {
                logger.Info("pass thru because DefaultStubRequestProvider supports HTTPRequestType.Text only.");
                return StubRequestResult.Pass();
            }

            logger.Info("hook request url: {0}", new object[]
            {
                request.Uri
            });
            string text = "Stub/";
            string host = request.Uri.Host;
            string text2 = request.Uri.AbsolutePath.Substring(1);
            string leftPart = request.Uri.GetLeftPart(UriPartial.Path);
            if (urlMappingRules.ContainsKey(leftPart))
            {
                string text3 = text + urlMappingRules[leftPart];
                TextAsset textAsset = Resources.Load<TextAsset>(text3);
                if (textAsset != null)
                {
                    logger.Info("alternative load from Resources/{0}", new object[]
                    {
                        text3
                    });
                    string text4 = textAsset.text;
                    Resources.UnloadAsset(textAsset);
                    return StubRequestResult.Success(text4);
                }
            }

            string text5 = text;
            if (hostMappingRules.ContainsKey(host))
            {
                text5 = text + hostMappingRules[host];
                if (!text5.EndsWith("/"))
                {
                    text5 += "/";
                }
            }

            string text6;
            if (!pathRules.ContainsKey(host) || pathRules[host] == DefaultStubRequestProvider.PathRules.Untouched)
            {
                text6 = text5 + text2;
            }
            else
            {
                string[] array = text2.Split(new char[]
                {
                    '/'
                });
                string text7 = string.Empty;
                for (int i = 0; i < array.Length; i++)
                {
                    string text8 = array[i];
                    string text9 = char.ToUpper(text8[0]).ToString() + text8.Substring(1);
                    text7 += text9;
                    if (pathRules[host] == DefaultStubRequestProvider.PathRules.Capitalize && i != array.Length - 1)
                    {
                        text7 += "/";
                    }
                }

                text6 = text5 + text7;
            }

            TextAsset textAsset2 = Resources.Load<TextAsset>(text6);
            if (textAsset2 != null)
            {
                logger.Info("alternative load from Resources/{0}", new object[]
                {
                    text6
                });
                string text10 = textAsset2.text;
                Resources.UnloadAsset(textAsset2);
                return StubRequestResult.Success(text10);
            }

            logger.Info("pass thru load from Resources/{0}", new object[]
            {
                text6
            });
            return StubRequestResult.Pass();
        }

        // RVA: 0x19F9AF8
        static DefaultStubRequestProvider()
        {
            logger = Logger.Get(typeof(DefaultStubRequestProvider));
            urlMappingRules = new Dictionary<string, string>();
            hostMappingRules = new Dictionary<string, string>();
            pathRules = new Dictionary<string, DefaultStubRequestProvider.PathRules>();
        }
    }
}
