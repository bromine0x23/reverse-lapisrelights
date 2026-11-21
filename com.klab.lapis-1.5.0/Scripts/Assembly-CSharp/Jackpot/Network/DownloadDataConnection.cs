// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.DownloadDataConnection
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
    public class DownloadDataConnection : Connection
    {

        // RVA: 0x1E902CC
        public DownloadDataConnection(HTTPClient client)
            : base(client)
        {
        }

        // RVA: 0x1E902D4
        public override void OnReceived(HTTPStatus status, Dictionary<string, string> headers)
        {
            if (Client != null && Client.Request != null && Client.Request.ReceivedHandler != null)
            {
                Client.Request.ReceivedHandler(status, headers);
            }
        }

        // RVA: 0x1E90598
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

            DownloadDataCompletedEventHandler downloadDataCompleted = Client.DownloadDataCompleted;
            if (downloadDataCompleted != null)
            {
                DownloadDataCompletedEventArgs e = new DownloadDataCompletedEventArgs(response.Bytes, response.Exception, IsCanceled(response), Client.UserState);
                downloadDataCompleted(Client, e);
            }
        }

        // RVA: 0x1E90674
        public override void OnProgress(long bytesReceive)
        {
            OnProgress(bytesReceive, -1L);
        }

        // RVA: 0x1E90684
        public override void OnProgress(long bytesReceive, long totalBytesToReceive)
        {
            if (Client == null)
            {
                return;
            }

            DownloadProgressChangedEventHandler downloadProgressChanged = Client.DownloadProgressChanged;
            HTTPProgress hTTPProgress = new HTTPProgress();
            hTTPProgress.BytesReceived = bytesReceive;
            hTTPProgress.TotalBytesToReceive = totalBytesToReceive;
            downloadProgressChanged(Client, new DownloadProgressChangedEventArgs(hTTPProgress, Client.UserState));
            NotifiedProgress = true;
        }
    }
}
