// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.DownloadFileConnection
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
    public class DownloadFileConnection : DownloadDataConnection
    {

        // RVA: 0x1E90BB8
        public DownloadFileConnection(HTTPClient client)
            : base(client)
        {
        }

        // RVA: 0x1E90BC0
        public override void OnComplete(HTTPResponse response)
        {
            if (Client == null)
            {
                return;
            }

            Client.Response = response;
            if (response == null)
            {
                return;
            }

            AsyncCompletedEventHandler asyncCompletedEventHandler = Client.DownloadFileCompleted;
            if (asyncCompletedEventHandler != null)
            {
                AsyncCompletedEventArgs e = new AsyncCompletedEventArgs(response.Exception, IsCanceled(response), Client.UserState);
                asyncCompletedEventHandler(Client, e);
            }
        }
    }
}
