// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.HttpClientAndroid
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
    public class HttpClientAndroid : HTTPClient
    {
        private static readonly Dictionary<string, Connection> Connections;
        private const string UnityBridgeClassName = "com.klab.jackpot.network.UnityBridge";
        private static AndroidJavaObject bridge;
        private static AndroidJavaProxy listener;
        private string taskId;
        private long totalBytesToReceive;
        private Connection Connection { get; private set; }


        // RVA: 0x1E925D8
        public static void Init()
        {
                        if (bridge == null)
                        {
                            NativeBridge();
                            NativeListener();
                        }
        }

        // RVA: 0x1E985B8
        private static AndroidJavaObject NativeBridge()
        {
                        if (bridge == null)
                        {
                            bridge = new AndroidJavaObject("com.klab.jackpot.network.UnityBridge", new object[0]);
                        }

                        return bridge;
        }

        // RVA: 0x1E98728
        private static AndroidJavaProxy NativeListener()
        {
                        if (listener == null)
                        {
                            listener = new HttpClientAndroid.NetworkListener();
                        }

                        return listener;
        }

        // RVA: 0x1E98864
        private static void CallStatic(string method, object[] args)
        {
                        using (JniAttachSection jniAttachSection = new JniAttachSection())
                        {
                            NativeBridge().CallStatic(method, args);
                        }
        }

        private static T CallStatic<T>(string method, object[] args)
        {
            return NativeBridge().CallStatic<T>(method, args);
        }

        // RVA: 0x1E9277C
        public HttpClientAndroid(HTTPRequest request)
            : base(request)
        {
        }

        // RVA: 0x1E989B0
        public override void DownloadDataAsync(Uri address, object userToken)
        {
            taskId = Guid.NewGuid().ToString();
            Connection = new DownloadDataConnection(this);
            lock (Connections)
            {
                Connections.Add(taskId, Connection);
            }

            object[] args = new object[]
            {
                NativeListener(),
                taskId,
                address.AbsoluteUri,
                Request.GetHeadersJson(),
                ProxyHost,
                ProxyPort,
                TimeoutMillisec
            };
            CallStatic("download", args);
        }

        // RVA: 0x1E98D3C
        public override void UploadDataAsync(Uri address, string method, byte[] requestBody, object userToken)
        {
            taskId = Guid.NewGuid().ToString();
            Connection = new UploadConnection(this);
            lock (Connections)
            {
                Connections.Add(taskId, Connection);
            }

            if (requestBody == null)
            {
                requestBody = new byte[0];
            }

            object[] args = new object[]
            {
                NativeListener(),
                taskId,
                method.ToUpper(),
                address.AbsoluteUri,
                ContentsType,
                Request.GetHeadersJson(),
                ProxyHost,
                ProxyPort,
                TimeoutMillisec,
                MaxTimeoutMillisec,
                requestBody
            };
            CallStatic("upload", args);
        }

        // RVA: 0x1E991D8
        public override void DownloadFileAsync(Uri address, string filePath, object userToken)
        {
            taskId = Guid.NewGuid().ToString();
            Connection = new DownloadFileConnection(this);
            lock (Connections)
            {
                Connections.Add(taskId, Connection);
            }

            object[] args = new object[]
            {
                NativeListener(),
                taskId,
                address.AbsoluteUri,
                filePath,
                Request.GetHeadersJson(),
                ProxyHost,
                ProxyPort,
                TimeoutMillisec,
                MaxTimeoutMillisec
            };
            CallStatic("downloadFile", args);
        }

        // RVA: 0x1E995D4
        public override void CancelAsync()
        {
            if ((int)requestType <= 2)
            {
                string method = new string[]
                {
                    "cancelDownload",
                    "cancelUpload",
                    "cancelDownloadFile"
                }[(int)requestType];
                if (method != null)
                {
                    CallStatic(method, new object[]
                    {
                        taskId
                    });
                }
            }
        }

        // RVA: 0x1E996D4
        public void StartProgress()
        {
            MainThreadDispatcher.Post(GetCurrentBytes());
        }

        // RVA: 0x1E9974C
        private IEnumerator GetCurrentBytes()
        {
            while (Response == null)
            {
                if ((int)requestType <= 2)
                {
                    string method = new string[]
                    {
                        "getDownloadCurrentBytes",
                        "getUploadCurrentBytes",
                        "getDownloadFileCurrentBytes"
                    }[(int)requestType];
                    if (method != null)
                    {
                        long num = CallStatic<long>(method, new object[]
                        {
                            taskId
                        });
                        if (num != -1L)
                        {
                            Connection.OnProgress(num);
                        }
                    }
                }

                yield return null;
            }
        }

        // RVA: 0x1E997E8
        static HttpClientAndroid()
        {
                        Connections = new Dictionary<string, Connection>();
        }

        private class NetworkListener : AndroidJavaProxy
        {
            // RVA: 0x1E987F0
            public NetworkListener()
                : base("com.klab.jackpot.network.NetworkListener")
            {
            }

            // RVA: 0x1E99A30
            public void notifyReceived(string taskId, int status, string headersJson)
            {
                Connection connection;
                lock (Connections)
                {
                    if (!Connections.TryGetValue(taskId, out connection))
                    {
                        return;
                    }

                    ((HttpClientAndroid)connection.Client).StartProgress();
                    Dictionary<string, string> headers = string.IsNullOrEmpty(headersJson)
                        ? null
                        : JsonUtility.FromJson<JsonCollectionSerializer<string, string>>(headersJson).ToDictionary();
                    connection.OnReceived((HTTPStatus)status, headers);
                }
            }

            // RVA: 0x1E99C20
            public void notifyComplete(string taskId, int status, AndroidJavaObject resultObj, string headersJson, long resultSize, bool isTimeout, bool isCancel, string errorMessage)
            {
                Connection connection;
                lock (Connections)
                {
                    if (Connections.TryGetValue(taskId, out connection))
                    {
                        HTTPResponse response = new HTTPResponse((HTTPStatus)status, errorMessage, headersJson);
                        if (resultObj != null)
                        {
                            using (AndroidJavaObject androidJavaObject = resultObj.Get<AndroidJavaObject>("result"))
                            {
                                response.Bytes = AndroidJNIHelper.ConvertFromJNIArray<byte[]>(androidJavaObject.GetRawObject());
                            }
                        }

                        response.Exception = HTTPClient.GetException(response, isTimeout, isCancel);
                        connection.OnProgress(resultSize);
                        connection.OnComplete(response);
                        Connections.Remove(taskId);
                    }
                }
            }
        }
    }
}
