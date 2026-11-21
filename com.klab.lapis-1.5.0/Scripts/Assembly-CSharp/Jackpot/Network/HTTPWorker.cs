// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.HTTPWorker
//  来源：libil2cpp.so (ARM64) 反汇编 + Il2CppDumper 元数据
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jackpot.Network
{
    public class HTTPWorker : MonoBehaviour
    {
        private enum ConnectionState
        {
            None = 0,
            Connect = 1,
            Error = 2,
            Disconnect = 3,
            Finish = 4
        }

        private static readonly ILogger logger;
        private int retryCount;
        private float lastProgressNotifiedTime;
        private bool isOrderdDisconnect;
        private HTTPWorker.ConnectionState connectionState;
        private Case.IMatcher<int, HTTPClient> routeResponseStatus;

        public HTTPRequest Request { get; protected set; }

        public bool IsConnected
        {
            get { return Request != null; }
        }

        public string Url
        {
            get
            {
                if (Request != null)
                {
                    return Request.Uri.ToString();
                }

                return string.Empty;
            }
        }

        // RVA: 0x1E972B0
        public bool get_IsConnected()
        {
            return IsConnected;
        }

        // RVA: 0x1E972C0
        public string get_Url()
        {
            return Url;
        }

        // RVA: 0x1E9734C
        public void Initialize()
        {
            routeResponseStatus = CaseAction.When<int, HTTPClient>((int status, HTTPClient client) => status == 3, (int status, HTTPClient client) => ProcessDisconnect())
                .When((int status, HTTPClient client) => status == 2, (int status, HTTPClient client) => ProcessError(client))
                .Default((int status, HTTPClient client) => ProcessSuccess(client));
            InitConnection();
        }

        // RVA: 0x1E97668
        private void InitConnection()
        {
            connectionState = HTTPWorker.ConnectionState.None;
            Request = null;
            retryCount = 0;
            isOrderdDisconnect = false;
        }

        // RVA: 0x1E97678
        public virtual void Connect(HTTPRequest request)
        {
            if (Request != null)
            {
                logger.Error("This object under connection.");
                return;
            }

            if (request == null)
            {
                logger.Error("The argument 'request' object was null. This request did not performed.");
                connectionState = HTTPWorker.ConnectionState.None;
                Request = null;
                retryCount = 0;
                isOrderdDisconnect = false;
                return;
            }

            Request = request;
            MainThreadDispatcher.Send(InternalConnect());
        }

        // RVA: 0x1E97894
        private IEnumerator InternalConnect()
        {
            if (Request == null)
            {
                yield break;
            }

            if (Request.Stub && Config.StubRequestProviderFunc != null)
            {
                StubRequestResult stubRequestResult = Config.StubRequestProviderFunc(Request);
                if (stubRequestResult == null)
                {
                    yield break;
                }

                if (!stubRequestResult.Passed)
                {
                    if (!Request.Sync)
                    {
                        yield return null;
                    }

                    if (!stubRequestResult.IsSuccess)
                    {
                        if (Request.ErrorHandler != null)
                        {
                            Request.ErrorHandler(Request, stubRequestResult.Response);
                        }
                    }
                    else if (Request.ResponseHandler != null)
                    {
                        Request.ResponseHandler(Request, stubRequestResult.Response);
                    }

                    InitConnection();
                    yield break;
                }
            }

            HTTPClient client = HTTPClient.Create(Request);
            connectionState = HTTPWorker.ConnectionState.Connect;
            client.Send();
            while (!client.Completed)
            {
                yield return null;
                if (Request.ProgressHandler != null && client.RequestProgress != null && Time.realtimeSinceStartup - lastProgressNotifiedTime > Request.ProgressInterval)
                {
                    lastProgressNotifiedTime = Time.realtimeSinceStartup;
                    Request.ProgressHandler(Request, client.RequestProgress);
                }
            }

            routeResponseStatus.Apply((int)connectionState, client);
            InitConnection();
        }

        // RVA: 0x1E97904
        public virtual void Disconnect()
        {
            if (Request != null)
            {
                isOrderdDisconnect = true;
                return;
            }

            connectionState = HTTPWorker.ConnectionState.None;
            Request = null;
            retryCount = 0;
            isOrderdDisconnect = false;
        }

        // RVA: 0x1E97958
        private void ProcessDisconnect()
        {
            logger.Warn("Disconnect order was confirmed.");
        }

        // RVA: 0x1E97A40
        private void ProcessError(HTTPClient client)
        {
            if (Request == null || Request.ErrorHandler == null || client == null)
            {
                return;
            }

            Request.ErrorHandler(Request, client.GetErrorResponse());
        }

        // RVA: 0x1E97A9C
        private void ProcessSuccess(HTTPClient client)
        {
            if (Request == null || Request.ResponseHandler == null || client == null)
            {
                return;
            }

            Request.ResponseHandler(Request, client.GetResponse());
        }

        // RVA: 0x1E97AF8
        public HTTPWorker()
        {
        }

        // RVA: 0x1E97B00
        static HTTPWorker()
        {
            logger = Logger.Get<HTTPWorker>();
        }
    }
}
