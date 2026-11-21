// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Social.KlabId.PlatformMessageReceiver
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

namespace Jackpot.Social.KlabId
{
    public class PlatformMessageReceiver : PlatformMessageReceiverBase
    {
        private ILogger logger;

        // RVA: 0x16B82F0
        private void Awake()
        {
            logger = Logger.Get<PlatformMessageReceiver>();
        }

        // RVA: 0x16B8364
        protected override void OnUrlSchemeReceived(Uri uri)
        {
            logger.Info("Url Scheme Received : {0}, AbsolutePath : {1}, Host : {2}, Scheme : {3}, Query : {4}, Segments : {5}, Fragment : {6}", new object[]
            {
                uri.AbsoluteUri,
                uri.AbsolutePath,
                uri.Host,
                uri.Scheme,
                uri.Query,
                string.Join(",", uri.Segments),
                uri.Fragment
            });
            Authorization.HandleUriScheme(uri);
        }

        // RVA: 0x16B8638
        public void .ctor()
        {

        }
    }
}
