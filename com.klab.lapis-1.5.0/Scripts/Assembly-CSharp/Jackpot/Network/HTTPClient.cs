// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Network.HTTPClient
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot.Network
{
    public abstract class HTTPClient : IDisposable, IEquatable<HTTPClient>
    {
        protected enum RequestType
        {
            Download = 0,
            Upload = 1,
            DownloadFile = 2
        }

        private const string ContentTypeKey = "Content-Type";
        private Encoding encoding;
        private Dictionary<string, string> headers;
        private bool proxySet;
        private static readonly ILogger logger;
        public DownloadProgressChangedEventHandler DownloadProgressChanged;
        public DownloadDataCompletedEventHandler DownloadDataCompleted;
        public UploadProgressChangedEventHandler UploadProgressChanged;
        public UploadDataCompletedEventHandler UploadDataCompleted;
        public AsyncCompletedEventHandler DownloadFileCompleted;
        private HTTPRequest request;
        private bool completed;
        protected HTTPClient.RequestType requestType;
        public abstract void DownloadDataAsync(Uri address, object userToken);
        public abstract void UploadDataAsync(Uri address, string method, byte[] data, object userToken);
        public abstract void DownloadFileAsync(Uri address, string fileName, object userToken);
        public abstract void CancelAsync();
        private Encoding Encoding { get { return encoding; } set { encoding = value; } }
        private WebProxy Proxy { get; private set; }
        private Dictionary<string, string> ResponseHeaders { get { return Response.Headers; } }
        protected string ProxyHost { get; }
        protected int ProxyPort { get; }
        protected string ContentsType { get { return (request != null) ? request.GetHeader("Content-Type") : string.Empty; } }
        protected int TimeoutMillisec { get { return (int)(((request != null) ? request.Timeout : Config.Timeout) * 1000f); } }
        protected int MaxTimeoutMillisec { get { return (int)(Config.MaxTimeout * 1000f); } }
        public bool Completed { get { return completed; } }
        public Exception Error { get; private set; }
        public HTTPRequest Request { get { return request; } }
        public object UserState { get; set; }
        public HTTPResponse Response { get; set; }
        public HTTPProgress RequestProgress { get; private set; }
        private byte[] Result { get; private set; }
        // RVA: 0x1E91D50
        private Encoding get_Encoding()
        {
            return encoding;
        }

        // RVA: 0x1E91D58
        private void set_Encoding(Encoding value)
        {
            encoding = value;
        }

        // RVA: 0x1E9228C
        public bool get_Completed()
        {
            return completed;
        }

        // RVA: 0x1E922C4
        public HTTPRequest get_Request()
        {
            return request;
        }

        // RVA: 0x1E9230C
        public HTTPClient(HTTPRequest request)
        {
            encoding = Encoding.Default;
            this.request = request;
            Encoding = Encoding.UTF8;
            DownloadDataCompleted += OnDownloadDataCompleted;
            DownloadProgressChanged += OnDownloadProgressChanged;
            UploadDataCompleted += OnUploadDataCompleted;
            UploadProgressChanged += OnUploadProgressChanged;
            DownloadFileCompleted += OnDownloadFileCompleted;
            Result = null;
            if (request != null && request.Proxy != null)
            {
                Proxy = request.Proxy;
                proxySet = true;
            }
        }

        // RVA: 0x1E9257C
        public static void Initialize()
        {
            HttpClientAndroid.Init();
        }

        // RVA: 0x1E92668
        public static HTTPClient Create(HTTPRequest request)
        {
            logger.Info("HTTPClient.Create(HTTPRequest)");
            return new HttpClientAndroid(request);
        }

        // RVA: 0x1E927F0
        public void Send()
        {
            Send(null);
        }

        // RVA: 0x1E927F8
        public void Send(object userState)
        {
            UserState = userState;
            if (request == null)
            {
                return;
            }

            if (request.Type == HTTPRequestType.Download)
            {
                logger.Info(string.Concat(new string[]
                {
                    "before DownloadFileAsync(",
                    request.Uri.AbsoluteUri,
                    ",",
                    request.FileName,
                    ")"
                }));
                string directoryName = Path.GetDirectoryName(request.FileName);
                if (!Directory.Exists(directoryName))
                {
                    Directory.CreateDirectory(directoryName);
                }

                requestType = RequestType.DownloadFile;
                DownloadFileAsync(request.Uri, request.FileName, null);
                logger.Info("after DownloadFileAsync");
                return;
            }

            switch (request.Method)
            {
                case HTTPMethod.Get:
                    GetData();
                    break;
                case HTTPMethod.Post:
                    PostData();
                    break;
                case HTTPMethod.Put:
                    PutData();
                    break;
                case HTTPMethod.Delete:
                    DeleteData();
                    break;
                default:
                    throw new NotSupportedException(string.Format("HTTP method '{0}' was not supported.", request.Method));
            }
        }

        // RVA: 0x1E92F38
        protected static Exception GetException(HTTPResponse response, bool isTimeout, bool isCancel)
        {
            if (response == null)
            {
                throw new ArgumentNullException();
            }

            string text = response.ErrorText;
            if (isTimeout)
            {
                if (string.IsNullOrEmpty(text))
                {
                    text = "Connection Timed out";
                }

                return new HTTPException(text, response, WebExceptionStatus.Timeout);
            }

            if (isCancel)
            {
                if (string.IsNullOrEmpty(text))
                {
                    text = "Request Canceled";
                }

                return new HTTPException(text, response, WebExceptionStatus.RequestCanceled);
            }

            if ((int)response.Status < 300)
            {
                if (string.IsNullOrEmpty(text))
                {
                    return null;
                }

                return new HTTPException(text, response, (WebExceptionStatus)16);
            }

            text = string.Format("The remote server returned an error: ({0}) {1}.", response.Status, text);
            return new HTTPException(text, response, WebExceptionStatus.ProtocolError);
        }

        // RVA: 0x1E931FC
        public void Dispose()
        {
        }

        // RVA: 0x1E93200
        public HTTPResponse GetResponse()
        {
            HTTPResponse hTTPResponse = new HTTPResponse(response.Headers);
            switch (request.Type)
            {
                case HTTPRequestType.Text:
                    hTTPResponse.Text = encoding.GetString(Result);
                    break;
                case HTTPRequestType.Binary:
                    hTTPResponse.Bytes = Result;
                    break;
                case HTTPRequestType.Download:
                    break;
                default:
                    logger.Error(string.Format("request.Type '{0}' was not supported.", request.Type));
                    break;
            }

            return hTTPResponse;
        }

        // RVA: 0x1E93458
        public HTTPResponse GetErrorResponse()
        {
            if (Error == null)
            {
                throw new ArgumentNullException("Error");
            }

            HTTPResponse hTTPResponse;
            if (Error is HTTPException)
            {
                hTTPResponse = GetHttpExceptionResponse();
            }
            else
            {
                logger.Fatal("Exception:{0},{1}", new object[]
                {
                    Error,
                    Error.Message
                });
                hTTPResponse = ((response.Headers != null)
                    ? new HTTPResponse(response.Headers, Error.Message)
                    : new HTTPResponse(HTTPStatus.InternalServerError, Error.Message));
            }

            if (request.FileName != null && File.Exists(request.FileName))
            {
                File.Delete(request.FileName);
            }

            return hTTPResponse;
        }

        // RVA: 0x1E93DC0
        public void DownloadDataAsync(Uri address)
        {
            requestType = RequestType.Download;
            DownloadDataAsync(address, null);
        }

        // RVA: 0x1E93DD4
        public void UploadDataAsync(Uri address, string method, byte[] data)
        {
            requestType = RequestType.Upload;
            UploadDataAsync(address, method, data, null);
        }

        // RVA: 0x1E92C6C
        public void DownloadFileAsync(Uri address, string filePath)
        {
            requestType = RequestType.DownloadFile;
            DownloadFileAsync(address, filePath, null);
        }

        // RVA: 0x1E92C84
        private void GetData()
        {
            requestType = RequestType.Download;
            DownloadDataAsync(request.Uri, null);
        }

        // RVA: 0x1E92CB0
        private void PostData()
        {
            requestType = RequestType.Upload;
            UploadDataAsync(request.Uri, HTTPMethod.Post.ToString(), CreateUploadData(), null);
        }

        // RVA: 0x1E92D88
        private void PutData()
        {
            requestType = RequestType.Upload;
            UploadDataAsync(request.Uri, HTTPMethod.Put.ToString(), CreateUploadData(), null);
        }

        // RVA: 0x1E92E60
        private void DeleteData()
        {
            requestType = RequestType.Upload;
            UploadDataAsync(request.Uri, HTTPMethod.Delete.ToString(), CreateUploadData(), null);
        }

        // RVA: 0x1E93DEC
        private byte[] CreateUploadData()
        {
            string header = request.GetHeader("Content-Type");
            byte[] rawBody = request.GetRawBody();
            if (rawBody != null)
            {
                if (string.IsNullOrEmpty(header))
                {
                    request.SetHeader("Content-Type", "application/json;charset=utf-8");
                }

                return rawBody;
            }

            string text = string.Empty;
            Dictionary<string, List<string>> allBodies = request.GetAllBodies();
            if (allBodies.Count >= 1)
            {
                text = new QueryParameter(allBodies).ToString();
            }

            if (string.IsNullOrEmpty(header))
            {
                request.SetHeader("Content-Type", "application/x-www-form-urlencoded");
            }

            return encoding.GetBytes(text);
        }

        // RVA: 0x1E94160
        public void OnDownloadDataCompleted(object sender, DownloadDataCompletedEventArgs e)
        {
            Error = e.Error;
            Result = e.Result;
        }

        // RVA: 0x1E94184
        public void OnUploadDataCompleted(object sender, UploadDataCompletedEventArgs e)
        {
            Error = e.Error;
            Result = e.Result;
        }

        // RVA: 0x1E941A8
        public void OnDownloadProgressChanged(object sender, DownloadProgressChangedEventArgs e)
        {
            RequestProgress = e.Progress;
        }

        // RVA: 0x1E941C4
        public void OnUploadProgressChanged(object sender, UploadProgressChangedEventArgs e)
        {
            RequestProgress = e.Progress;
        }

        // RVA: 0x1E941E0
        public void OnDownloadFileCompleted(object sender, AsyncCompletedEventArgs e)
        {
            completed = true;
            Error = e.Error;
        }

        // RVA: 0x1E93748
        private HTTPResponse GetHttpExceptionResponse()
        {
            HTTPException hTTPException = (HTTPException)Error;
            if (hTTPException.ExceptionStatus == WebExceptionStatus.Timeout)
            {
                HTTPResponse hTTPResponse = new HTTPResponse(HTTPStatus.RequestTimeout, hTTPException.Message);
                hTTPResponse.Exception = hTTPException;
                return hTTPResponse;
            }

            HTTPResponse hTTPResponse2 = hTTPException.Response;
            HTTPStatus status = (hTTPResponse2 != null) ? hTTPResponse2.Status : HTTPStatus.InternalServerError;
            HTTPResponse hTTPResponse3 = new HTTPResponse(status, hTTPException.Message);
            hTTPResponse3.Exception = hTTPException;
            if (hTTPResponse2 != null)
            {
                hTTPResponse3.Headers = hTTPResponse2.Headers;
            }

            if (request.Type == HTTPRequestType.Download)
            {
                if (File.Exists(request.FileName))
                {
                    using (FileStream fileStream = new FileStream(request.FileName, FileMode.Open, FileAccess.Read))
                    {
                        using (BinaryReader binaryReader = new BinaryReader(fileStream))
                        {
                            hTTPResponse3.Bytes = binaryReader.ReadBytes((int)fileStream.Length);
                        }
                    }
                }

                return hTTPResponse3;
            }

            object obj = hTTPException.Data["result"];
            if (obj == null)
            {
                return hTTPResponse3;
            }

            byte[] array = obj as byte[];
            if (array != null)
            {
                if (request.Type == HTTPRequestType.Binary)
                {
                    hTTPResponse3.Bytes = array;
                }
                else if (request.Type == HTTPRequestType.Text)
                {
                    hTTPResponse3.Text = encoding.GetString(array);
                }
                else
                {
                    logger.Error(string.Format("request.Type '{0}' was not supported.", request.Type));
                }
            }

            return hTTPResponse3;
        }

        // RVA: 0x1E942EC
        private bool System.IEquatable<Jackpot.Network.HTTPClient>.Equals(HTTPClient other)
        {
            return Equals(other);
        }

        // RVA: 0x1E942F8
        static HTTPClient()
        {
            logger = Logger.Get<HTTPClient>();
        }
    }
}
