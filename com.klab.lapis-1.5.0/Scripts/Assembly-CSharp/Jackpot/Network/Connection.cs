// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.Connection
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.Network
{
    public abstract class Connection
    {
        public abstract void OnReceived(HTTPStatus status, Dictionary<string, string> headers);
        public abstract void OnComplete(HTTPResponse response);
        public abstract void OnProgress(long bytesSize);
        public abstract void OnProgress(long bytesSize, long totalBytesSize);
        public HTTPClient Client { get; private set; }
        public bool NotifiedProgress { get; protected set; }




        // RVA: 0x19F8968
        public Connection(HTTPClient client)
        {
            Client = client;
            MainThreadDispatcher.Post(WaitResponse());
        }

        // RVA: 0x19F89F8
        [IteratorStateMachine]
        private IEnumerator WaitResponse()
        {
                        while (Client.Response == null)
                                    {
                                        yield return null;
                                    }
        }

        // RVA: 0x19F8A94
        protected static bool IsCanceled(HTTPResponse response)
        {
            if (response.Exception == null)
            {
                return false;
            }

            return ((HTTPException)response.Exception).ExceptionStatus == WebExceptionStatus.RequestCanceled;
        }
    }
}
