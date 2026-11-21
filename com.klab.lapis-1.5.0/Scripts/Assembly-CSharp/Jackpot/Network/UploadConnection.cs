// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.UploadConnection
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
    public class UploadConnection : Connection
    {

        // RVA: 0x1E991D0
        public UploadConnection(HTTPClient client)
            : base(client)
        {
        }

        // RVA: 0x1E9A49C
        public override void OnReceived(HTTPStatus status, Dictionary<string, string> headers)
        {
        }

        // RVA: 0x1E9A4A0
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

            UploadDataCompletedEventHandler uploadDataCompleted = Client.UploadDataCompleted;
            if (uploadDataCompleted != null)
            {
                UploadDataCompletedEventArgs e = new UploadDataCompletedEventArgs(response.Bytes, response.Exception, IsCanceled(response), Client.UserState);
                uploadDataCompleted(Client, e);
            }
        }

        // RVA: 0x1E9A9A0
        public override void OnProgress(long bytesSent)
        {
            OnProgress(bytesSent, -1L);
        }

        // RVA: 0x1E9A9B0
        public override void OnProgress(long bytesSent, long totalBytesSend)
        {
            if (Client == null)
            {
                return;
            }

            UploadProgressChangedEventHandler uploadProgressChanged = Client.UploadProgressChanged;
            HTTPProgress hTTPProgress = new HTTPProgress();
            hTTPProgress.BytesSent = bytesSent;
            hTTPProgress.TotalBytesSend = totalBytesSend;
            uploadProgressChanged(Client, new UploadProgressChangedEventArgs(hTTPProgress, Client.UserState));
            NotifiedProgress = true;
        }
    }
}
