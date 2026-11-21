// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.GrpcConnector
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using Oz.Utility;
using Kc.Utility;
using System.Text.RegularExpressions;
using Grpc.Core;
using System.Threading;
using System.Threading.Tasks;
using Lapis;
using Oz.Framework.LuaModule;
using System.Text;
using Kc.Config;
using Game;
using MiniJSON;
using Oz.GameFramework.Runtime;
using Google.Protobuf;
using Oz.Framework.Utility;
using Jackpot;
using UnityEngine.Networking;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Framework.NetworkModule
{
    public class GrpcConnector : Connectable
    {
        private const string MAINTAIN_CODE = "503";
        private const string FORCE_CODE = "410";
        private HashSet<int> noAuthMsg;
        private Dictionary<int, string> lastestMsgIdCached;
        private byte[] gSessionKey;
        private byte[] cachedSession;
        private NetworkReachability networkState;
        private GrpcConnector.CntState m_state;
        public bool AutoReconnect;
        public Protocol m_protocol;
        private string service_slug_value;
        private GrpcConnector.HostInfo m_host;
        private Lapis.LapisClient conn_client;
        private Channel m_channel;
        private ChannelOption[] options;
        private ChannelCredentials ssl;
        private List<GrpcConnector.RequestInfo> m_send_list;
        private Mutex m_mutex;
        private Mutex m_mutex_flush;
        private Mutex m_mutex_get;
        private Metadata headerStreaming;
        private Task recieveTask;
        private CancellationTokenSource ctsRecieve;
        private string m_lang;
        private string m_version;
        private string m_platform;
        private long m_playerId;
        private long cachedPlayerId;
        private long m_debugTime;
        private string resVersion;
        private string err_send;
        private string err_recv;
        private AsyncDuplexStreamingCall<CommonRequest, CommonResponse> m_bidi_call;
        private static int cmdNum;
        private string ServiceSlugValue { get; }
        public string LuaVersion { get; set; }
        public bool IsLogin { get; }
        public AsyncDuplexStreamingCall<CommonRequest, CommonResponse> BidiCall { get; }
        public override string EncryptKey { get { return m_protocol.EncryptKey; } set { m_protocol.EncryptKey = value; } }

        // RVA: 0x2ED938C
        private string get_ServiceSlugValue()
        {
            if (service_slug_value == null)
            {
                service_slug_value = NetworkUtil.GetServiceSlugValue(m_host.Ip);
                Debug.Log("prefix:" + service_slug_value);
            }

            return service_slug_value;
        }



        // RVA: 0x2ED9450
        public void SetDebugTime(long debugTime)
        {
            m_debugTime = debugTime;
        }

        // RVA: 0x2ED9458
        public bool get_IsLogin()
        {
            return m_playerId != 0;
        }

        // RVA: 0x2ED9468
        public void SetResVersion(string ver)
        {
            resVersion = ver;
        }

        // RVA: 0x2ED9470
        public AsyncDuplexStreamingCall<CommonRequest, CommonResponse> get_BidiCall()
        {
            m_mutex_get.WaitOne();

            if (m_bidi_call == null)
            {
                headerStreaming = new Metadata();
                headerStreaming.Add(HttpConstant.X_APP_VERSION_META_KEY, m_version);
                headerStreaming.Add(HttpConstant.X_APP_PLATFORM_META_KEY, m_platform);
                headerStreaming.Add(HttpConstant.X_SERVICE_SLUG_META_KEY, ServiceSlugValue);
                headerStreaming.Add(HttpConstant.X_PLAYER_ID_META_KEY, m_playerId.ToString());

                string sign = GetRequestSign(
                    Encoding.UTF8.GetBytes(
                        m_version + m_platform + ServiceSlugValue + m_playerId),
                    gSessionKey);
                headerStreaming.Add(HttpConstant.X_SIGNATURE_META_KEY, sign);

                headerStreaming.Add(HttpConstant.X_APP_LANG_META_KEY, m_lang);
                headerStreaming.Add(HttpConstant.X_APP_VIRTUAL_UT, m_debugTime.ToString());

                if (resVersion != null)
                {
                    headerStreaming.Add(HttpConstant.X_RES_VERSION_META_KEY, resVersion);
                }

                m_bidi_call = conn_client.BidiCall(headerStreaming, null, default(CancellationToken));
            }

            m_mutex_get.ReleaseMutex();
            return m_bidi_call;
        }

        // RVA: 0x2ED97AC
        public Metadata GetMetaHeaderUnary(string msgId)
        {
            Metadata metadata = new Metadata();
            foreach (KeyValuePair<string, string> pair in GetHttpHeaderDict(msgId))
            {
                metadata.Add(pair.Key, pair.Value);
            }
            return metadata;
        }

        // RVA: 0x2ED991C
        private Dictionary<string, string> GetHttpHeaderDict(string msgId)
        {
            Dictionary<string, string> header = new Dictionary<string, string>();
            header.Add(HttpConstant.X_APP_VERSION_META_KEY, m_version);
            header.Add(HttpConstant.X_APP_PLATFORM_META_KEY, m_platform);
            header.Add(HttpConstant.X_SERVICE_SLUG_META_KEY, ServiceSlugValue);

            long playerId = m_playerId != 0 ? m_playerId : cachedPlayerId;
            header.Add(HttpConstant.X_PLAYER_ID_META_KEY, playerId.ToString());

            header.Add(HttpConstant.X_APP_PATH, msgId);
            header.Add(HttpConstant.X_APP_LANG_META_KEY, m_lang);
            header.Add(HttpConstant.X_APP_VIRTUAL_UT, m_debugTime.ToString());

            if (resVersion != null)
            {
                header.Add(HttpConstant.X_RES_VERSION_META_KEY, resVersion);
            }

            return header;
        }

        // RVA: 0x2ED9B28
        private static string CreateRequestId()
        {
            cmdNum++;
            return CryptographyUtil.Hexlify(CryptographyUtil.RandomBytes(8)) + cmdNum.ToString();
        }

        // RVA: 0x2ED9BF0
        public GrpcConnector(Protocol prot, string ver, string platform, string lang)
        {
            noAuthMsg = new HashSet<int>();
            lastestMsgIdCached = new Dictionary<int, string>();
            m_send_list = new List<RequestInfo>();
            m_mutex = new Mutex();
            m_mutex_flush = new Mutex();
            m_mutex_get = new Mutex();

            m_lang = lang;
            m_version = ver;
            m_platform = platform;
            m_protocol = prot;

            options = new[]
            {
                new ChannelOption("grpc.keepalive_time_ms", 5000),
                new ChannelOption("grpc.keepalive_timeout_ms", 5000),
                new ChannelOption("grpc.keepalive_permit_without_calls", 1),
                new ChannelOption("grpc.http2.max_pings_without_data", 0),
                new ChannelOption("grpc.http2.min_time_between_pings_ms", 10000),
                new ChannelOption("grpc.http2.min_ping_interval_without_data_ms", 5000),
            };

            networkState = Application.internetReachability;

            cachedPlayerId = long.Parse(PlayerPrefs.GetString("PRE_USER_ID", "0"));

            string session = PlayerPrefs.GetString(NetworkManager.COMMON_KEY, null);
            if (session != null)
            {
                cachedSession = Convert.FromBase64String(session);
            }

            m_debugTime = PlayerPrefs.GetInt("DebugSysTime", 0);
        }

        // RVA: 0x2EDA00C
        public IEnumerator RequestHttpOne(string msg, int group, byte[] body, bool needAuth)
        {
            RequestInfo info = new RequestInfo
            {
                requestData = m_protocol.Pack(msg, group, group, body),
                rawData = body,
                msgId = int.Parse(msg.Substring(1, msg.IndexOf("_") - 1)),
                needAuth = needAuth,
                msgStr = msg,
            };

            string err = null;
            float sendTime = Time.realtimeSinceStartup;
            long? requestTime = Clock.MilliTimestamp();

            CommonRequest commonRequest = GetCommonRequest(info, ref err, requestTime);

            using (UnityWebRequest request = new UnityWebRequest(KcAppSetting.HttpOneEndPoint, "POST"))
            {
                foreach (KeyValuePair<string, string> header in GetHttpHeaderDict(msg))
                {
                    request.SetRequestHeader(header.Key, header.Value);
                }

                UploadHandlerRaw uploadHandler = new UploadHandlerRaw(commonRequest.ToByteArray());
                uploadHandler.contentType = "application/grpc+proto";
                request.uploadHandler = uploadHandler;
                request.downloadHandler = new DownloadHandlerBuffer();

                yield return request.SendWebRequest();

                if (request.isNetworkError || request.isHttpError || err != null)
                {
                    Debug.LogError(KcAppSetting.HttpOneEndPoint);
                    Debug.LogError(request.error);
                    Dispatcher.m_inst.PushEvent(
                        Dispatcher.EventType.ServerError,
                        false,
                        NetworkManager.ERROR_HTTP1_ERROR,
                        this,
                        null);
                }
                else
                {
                    CommonResponse response = CommonResponse.Parser.ParseFrom(
                        ByteString.CopyFrom(request.downloadHandler.data));
                    ProcessCommonResponse(response, true, sendTime);
                }
            }
        }

        // RVA: 0x2EDA0D8
        public override void SetAsLogin(string playerId)
        {
            m_playerId = long.Parse(playerId);
            StartRecieve();
        }

        // RVA: 0x2EDA238
        private byte[] GetConnectInfo()
        {
            LuaFunction function = Launcher.Instance.LuaMgr.luaState.GetFunction(
                "NetManager.GetConnectPBMsg", true);

            byte[] result = function != null ? function.Invoke<byte[]>() : null;
            function?.Dispose();
            return result;
        }

        // RVA: 0x2EDA3FC
        public override void SaveSessionKey(string resKey, byte[] randomBytes, bool isCached)
        {
            byte[] sessionKey = CryptographyUtil.XorBytes(
                randomBytes, Convert.FromBase64String(resKey));

            if (isCached)
            {
                PlayerPrefs.SetString(NetworkManager.COMMON_KEY, Convert.ToBase64String(sessionKey));
                cachedSession = sessionKey;
            }
            else
            {
                sessionKey = CryptographyUtil.XorBytes(sessionKey, KcAppSetting.SessionKey);
            }

            gSessionKey = sessionKey;
            Debug.LogWarning("Saved Session key : " + Convert.ToBase64String(sessionKey));
        }

        // RVA: 0x2EDA600
        public override void Connect(string ip, int port)
        {
            if (m_state != CntState.Connected)
            {
                noAuthMsg.Clear();
                Disconnect();

                if (Regex.IsMatch(ip, "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"))
                {
                    ssl = ChannelCredentials.InsecureInstance;
                }
                else
                {
                    ssl = new SslCredentials();
                }

                SetEncryptType(0);

                m_host = new HostInfo { Ip = ip, Port = port };
                Debug.Log("start connect to " + m_host.IpPort);

                m_channel = new Channel(m_host.IpPort, ssl, options);
                conn_client = new LapisClient(m_channel);
                m_state = CntState.Connected;

                if (Application.internetReachability == NetworkReachability.NotReachable)
                {
                    Disconnect("no network");
                    return;
                }

                StartRecieve();
            }

            Dispatcher.m_inst.PushEvent(Dispatcher.EventType.Connect, true, string.Empty, this, null);
        }

        // RVA: 0x2EDAA98
        private void ConnectNoRecieve(string ip, int port)
        {
            if (m_state == CntState.Connected)
            {
                Dispatcher.m_inst.PushEvent(Dispatcher.EventType.Connect, true, string.Empty, this, null);
                return;
            }

            noAuthMsg.Clear();
            Disconnect();

            if (Regex.IsMatch(ip, "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"))
            {
                ssl = ChannelCredentials.InsecureInstance;
            }
            else
            {
                ssl = new SslCredentials();
            }

            SetEncryptType(0);

            m_host = new HostInfo { Ip = ip, Port = port };
            Debug.Log("start connect to " + m_host.IpPort);

            m_channel = new Channel(m_host.IpPort, ssl, options);
            conn_client = new LapisClient(m_channel);
            m_state = CntState.Connected;
        }

        // RVA: 0x2EDAD74
        public override void Disconnect()
        {
            if (recieveTask != null
                && !recieveTask.IsCanceled
                && !ctsRecieve.IsCancellationRequested)
            {
                ctsRecieve.Cancel();
                recieveTask = null;
            }

            cmdNum = 0;

            if (m_bidi_call != null)
            {
                m_bidi_call.requestStream.CompleteAsync().Wait(1000);
                m_bidi_call.Dispose();
                m_bidi_call = null;
            }

            if (m_channel == null)
            {
                m_state = CntState.Closed;
                conn_client = null;
                m_channel = null;
            }
            else if (m_channel.State != ChannelState.Ready)
            {
                m_state = CntState.Closed;
                m_channel.ShutdownAsync();
                conn_client = null;
                m_channel = null;
            }
            else
            {
                conn_client = null;
                m_channel.ShutdownAsync();
                m_channel = null;
            }

            recieveTask = null;
            m_state = CntState.Closed;
            m_channel = null;
        }

        // RVA: 0x2EDAA18
        public void Disconnect(string err)
        {
            Disconnect();
            Dispatcher.m_inst.PushEvent(Dispatcher.EventType.OnDisconnect, true, err, null, null);
        }

        // RVA: 0x2EDB144
        public override void Send(
            string msg,
            int group,
            byte[] body,
            bool setTop = false,
            bool needAuth = true,
            bool retry = false)
        {
            m_mutex.WaitOne();

            // 原实现把 group 同时作为 Pack 的 sn 与 requestId 传入
            byte[] packed = m_protocol.Pack(msg, group, group, body);

            RequestInfo info = new RequestInfo
            {
                requestData = packed,
                rawData = body,
                msgId = int.Parse(msg.Substring(1, msg.IndexOf("_") - 1)),
                msgStr = msg,
                needAuth = needAuth,
                isRetry = retry,
            };

            if (setTop)
            {
                m_send_list.Insert(0, info);
            }
            else
            {
                m_send_list.Add(info);
            }

            m_mutex.ReleaseMutex();
        }

        // RVA: 0x2EDB480
        public override void SetEncryptType(int type)
        {
            m_protocol.SetEncryptType(type);
        }

        // RVA: 0x2EDB4DC
        public override void Close()
        {
            Disconnect();
        }

        // RVA: 0x2EDB4E8
        public override void Flush()
        {
            OutputError();

            if (AutoReconnect && m_state == CntState.Closed)
            {
                Connect(m_host.Ip, m_host.Port);
            }
            else if (m_state == CntState.Connected)
            {
                FlushSend();
            }
        }

        // RVA: 0x2EDB55C
        private void OutputError()
        {
            if (err_recv != null)
            {
                Debug.LogErrorFormat("[GRPC]got recieve error : {0}", err_recv);
                err_recv = null;
            }

            if (err_send != null)
            {
                Debug.LogErrorFormat("[GRPC]got send error : {0}", err_send);
                err_send = null;
            }
        }

        // RVA: 0x2EDB830
        private void ProcessStatues(
            StatusCode status,
            PackData data,
            string serverSign,
            bool vaildSign = true,
            string resVer = null)
        {
            switch (status)
            {
                case StatusCode.Cancelled:
                case StatusCode.NotFound:
                    Dispatcher.m_inst.PushEvent(
                        Dispatcher.EventType.ServerError,
                        false,
                        NetworkManager.ERROR_SERVER_ERROR,
                        this,
                        null);
                    return;
                case StatusCode.Unknown:
                    Dispatcher.m_inst.PushEvent(
                        Dispatcher.EventType.ServerError,
                        false,
                        NetworkManager.ERROR_SIGN,
                        this,
                        null);
                    return;
                case StatusCode.InvalidArgument:
                    Dispatcher.m_inst.PushEvent(
                        Dispatcher.EventType.ServerError,
                        false,
                        NetworkManager.ERROR_KICKOFF,
                        this,
                        null);
                    return;
                case StatusCode.DeadlineExceeded:
                    Dispatcher.m_inst.PushEvent(
                        Dispatcher.EventType.ServerError,
                        false,
                        NetworkManager.ERROR_CAUTION,
                        this,
                        null);
                    return;
            }

            bool needVerify = KcAppSetting.EnableProtocolEncrypt
                && data.msgId != NetworkManager.HEART_MSGID;
            if (!needVerify || !vaildSign)
            {
                return;
            }

            byte[] sessionKey = noAuthMsg.Contains(data.msgId)
                ? KcAppSetting.StartUpKey
                : gSessionKey;
            if (data.msgId == NetworkManager.LOGIN_MSGID)
            {
                sessionKey = cachedSession;
            }

            byte[] combined = GetCombineData(data.msgId, data.pbData);
            if (GetRequestSign(combined, sessionKey) != serverSign)
            {
                Dispatcher.m_inst.PushEvent(
                    Dispatcher.EventType.ServerError,
                    false,
                    NetworkManager.ERROR_SIGN,
                    this,
                    null);
            }

            if (string.IsNullOrEmpty(resVer) || !AppConst.AssetBundleMode)
            {
                return;
            }

            Dictionary<string, object> json =
                (Dictionary<string, object>)Json.Deserialize(resVer);
            if (json["resVersion"].ToString() != resVersion)
            {
                Dispatcher.m_inst.PushEvent(
                    Dispatcher.EventType.ServerError,
                    false,
                    NetworkManager.ERROR_RES_VER,
                    this,
                    null);
            }
        }

        // RVA: 0x2EDA108
        private void StartRecieve()
        {
            if (recieveTask == null && m_playerId != 0)
            {
                Debug.Log("Start Recieve");
                ctsRecieve = new CancellationTokenSource();
                recieveTask = Task.Run(async () =>
                {
                    do
                    {
                        if (await BidiCall.responseStream.MoveNext())
                        {
                            ProcessCommonResponse(BidiCall.responseStream.Current, false, -1f);
                        }
                    }
                    while (m_state == CntState.Connected);
                }, ctsRecieve.Token);
            }
        }

        // RVA: 0x2ED972C
        private string GetRequestSign(byte[] data, byte[] sessionKey)
        {
            return CryptographyUtil.Hexlify(CryptographyUtil.HmacSha1(data, sessionKey));
        }

        // RVA: 0x2EDBD3C
        private byte[] GetCombineData(int msgId, byte[] data)
        {
            byte[] msgIdBytes = BitConverter.GetBytes(msgId);
            Array.Reverse(msgIdBytes);

            if (data != null)
            {
                byte[] combined = new byte[data.Length + msgIdBytes.Length];
                Array.Copy(msgIdBytes, 0, combined, 0, msgIdBytes.Length);
                Array.Copy(data, 0, combined, msgIdBytes.Length, data.Length);
                return combined;
            }

            byte[] onlyMsgId = new byte[msgIdBytes.Length];
            Array.Copy(msgIdBytes, 0, onlyMsgId, 0, msgIdBytes.Length);
            return onlyMsgId;
        }

        // RVA: 0x2EDBE48
        private byte[] GetCombineData(int msgId, byte[] data, long playerId, string platform)
        {
            byte[] msgIdBytes = BitConverter.GetBytes(msgId);
            byte[] playerIdBytes = BitConverter.GetBytes(playerId);
            byte[] platformBytes = Encoding.UTF8.GetBytes(platform);

            Array.Reverse(msgIdBytes);
            Array.Reverse(playerIdBytes);

            if (data == null)
            {
                byte[] onlyHeader = new byte[
                    playerIdBytes.Length + msgIdBytes.Length + platformBytes.Length];
                Array.Copy(msgIdBytes, 0, onlyHeader, 0, msgIdBytes.Length);
                Array.Copy(playerIdBytes, 0, onlyHeader, msgIdBytes.Length, playerIdBytes.Length);
                Array.Copy(
                    platformBytes, 0, onlyHeader,
                    msgIdBytes.Length + playerIdBytes.Length, platformBytes.Length);
                return onlyHeader;
            }

            byte[] combined = new byte[
                data.Length + msgIdBytes.Length + playerIdBytes.Length + platformBytes.Length];
            Array.Copy(msgIdBytes, 0, combined, 0, msgIdBytes.Length);
            Array.Copy(data, 0, combined, msgIdBytes.Length, data.Length);
            Array.Copy(
                playerIdBytes, 0, combined,
                msgIdBytes.Length + data.Length, playerIdBytes.Length);
            Array.Copy(
                platformBytes, 0, combined,
                msgIdBytes.Length + data.Length + playerIdBytes.Length, platformBytes.Length);
            return combined;
        }

        // RVA: 0x2EDC03C
        private CommonRequest GetCommonRequest(
            GrpcConnector.RequestInfo data, ref string err, long? requestTimeStamp)
        {
            if (!data.needAuth && !noAuthMsg.Contains(data.msgId))
            {
                noAuthMsg.Add(data.msgId);
            }

            byte[] sessionKey = data.needAuth ? gSessionKey : KcAppSetting.StartUpKey;

            if (KcAppSetting.EnableProtocolEncrypt)
            {
                if (data.msgId == NetworkManager.HEART_MSGID)
                {
                    sessionKey = KcAppSetting.StartUpKey;
                }
                else if (data.msgId == NetworkManager.LOGIN_MSGID)
                {
                    sessionKey = cachedSession;
                }
            }

            if (sessionKey == null)
            {
                return null;
            }

            byte[] combined = GetCombineData(
                data.msgId, data.rawData, m_playerId, m_platform);
            string signature = GetRequestSign(combined, sessionKey);

            string requestId;
            if (data.isRetry && lastestMsgIdCached.ContainsKey(data.msgId))
            {
                requestId = lastestMsgIdCached[data.msgId];
            }
            else
            {
                requestId = CreateRequestId();
            }

            CommonRequest request = new CommonRequest();
            request.Payload = ByteString.CopyFrom(data.requestData);
            request.Platform = m_platform;
            request.Signature = signature;
            request.playerId_ = m_playerId;
            request.Lang = m_lang;
            request.Id = requestId;
            request.ResVersion = resVersion;

            if (data.msgId == NetworkManager.GET_PLAYER_MSGID)
            {
                request.LuaHash = SecurityUtil.GetLuaHash(requestId, 1);
                request.MainResVersion = LuaVersion;
            }

            if (requestTimeStamp.HasValue)
            {
                request.ts_ = requestTimeStamp.Value;
            }

            return request;
        }

        // RVA: 0x2EDC8C4
        private void ProcessCommonResponse(CommonResponse commonRep, bool vaildSign = true, float sendTime = -1)
        {
            int offset = 0;
            byte[] payload = commonRep.payload_.ToByteArray();

            PackData data = m_protocol.ParserOutput(null, payload, ref offset, payload.Length);

            if (sendTime != -1f)
            {
                Dispatcher.m_inst.PushEvent(
                    Dispatcher.EventType.SetServerTime,
                    false,
                    NetworkManager.ERROR_CAUTION,
                    new ClockInfo(commonRep.ts_, sendTime),
                    null);
            }

            ProcessStatues(
                commonRep.status_, data, commonRep.signature_, vaildSign, commonRep.resVer_);
        }

        // RVA: 0x2EDCA50
        private bool ProcessCommonError(string detail)
        {
            if (detail.Contains("503"))
            {
                Dispatcher.m_inst.PushEvent(
                    Dispatcher.EventType.ServerError,
                    false,
                    NetworkManager.ERROR_MAINTAIN,
                    this,
                    null);
                return false;
            }

            if (detail.Contains("410"))
            {
                Dispatcher.m_inst.PushEvent(
                    Dispatcher.EventType.ServerError,
                    false,
                    NetworkManager.ERROR_FORCE_UPDATE,
                    this,
                    null);
                return false;
            }

            return true;
        }

        // RVA: 0x2EDCBD4
        public void SendBidiPing(string msg)
        {
            if (m_playerId == 0)
            {
                return;
            }

            RequestInfo info = new RequestInfo
            {
                requestData = m_protocol.Pack(msg, 0, 0, null),
                rawData = null,
                msgId = int.Parse(msg.Substring(1, msg.IndexOf("_") - 1)),
                needAuth = true,
                msgStr = msg,
            };

            long? requestTime = Clock.MilliTimestamp();

            Task.Run(async () =>
            {
                if (gSessionKey == null)
                {
                    return;
                }

                string err = null;
                CommonRequest request = GetCommonRequest(info, ref err, requestTime);
                await BidiCall.requestStream.WriteAsync(request);
            });
        }

        // RVA: 0x2EDB6D0
        private void FlushSend()
        {
            if (m_send_list.Count < 1)
            {
                return;
            }

            List<RequestInfo> currentList = new List<RequestInfo>(m_send_list);
            m_send_list.Clear();

            float sentTime = Time.realtimeSinceStartup;
            long? requestTime = Clock.MilliTimestamp();

            Task.Run(async () =>
            {
                string err = null;
                foreach (RequestInfo info in currentList)
                {
                    CommonRequest request = GetCommonRequest(info, ref err, requestTime);
                    if (request == null)
                    {
                        continue;
                    }

                    lastestMsgIdCached[info.msgId] = request.id_;

                    AsyncUnaryCall<CommonResponse> call = conn_client.CallAsync(
                        request, GetMetaHeaderUnary(info.msgStr), null, default(CancellationToken));
                    CommonResponse response = await call;
                    ProcessCommonResponse(response, true, sentTime);
                }

                if (err != null)
                {
                    Disconnect(NetworkManager.ERROR_RECIEVE_SEND);
                }
            });
        }

        // RVA: 0x2EDA9F8
        private bool IsNetWorkDisabled()
        {
            return Application.internetReachability == NetworkReachability.NotReachable;
        }

        // RVA: 0x2EDCD74
        public void SendPackUrlRequest(string[] urls, string buildVersion)
        {
            if (Application.internetReachability == NetworkReachability.NotReachable)
            {
                Dispatcher.m_inst.PushEvent(
                    Dispatcher.EventType.GetAssetUrl, false, string.Empty, null, null);
                return;
            }

            string ip = PlayerPrefs.GetString("endpoint_host", KcAppSetting.ApiEndPoint);
            int port = PlayerPrefs.GetInt("endpoint_port", KcAppSetting.ApiPort);
            ConnectNoRecieve(ip, port);

            Task.Run(async () =>
            {
                AssetUrlsRequest request = new AssetUrlsRequest();
                request.assetKeys_.AddRange(urls);
                request.ResVersion = buildVersion;

                AsyncUnaryCall<AssetUrlsResponse> call = conn_client.GetAssetUrlsAsync(
                    request,
                    GetMetaHeaderUnary(Dispatcher.EventType.GetAssetUrl.ToString()),
                    null,
                    default(CancellationToken));
                AssetUrlsResponse response = await call;

                if (response.status_ == StatusCode.Cancelled
                    || response.status_ == StatusCode.NotFound)
                {
                    throw new UnityException("Get Asset Api Error");
                }

                Dispatcher.m_inst.PushEvent(
                    Dispatcher.EventType.GetAssetUrl, true, string.Empty, response, null);

                Jackpot.MainThreadDispatcher.Post(Close);
            });
        }

        // RVA: 0x2EDCF40
        public void FetchVersion()
        {
            if (Application.internetReachability == NetworkReachability.NotReachable)
            {
                Dispatcher.m_inst.PushEvent(
                    Dispatcher.EventType.OnFetchVersion, false, string.Empty, null, null);
                return;
            }

            string ip = PlayerPrefs.GetString("endpoint_host", KcAppSetting.ApiEndPoint);
            int port = PlayerPrefs.GetInt("endpoint_port", KcAppSetting.ApiPort);
            ConnectNoRecieve(ip, port);

            Task.Run(async () =>
            {
                VerManifestRequest request = new VerManifestRequest();
                request.Lang = m_lang;
                request.Platform = m_platform;

                AsyncUnaryCall<VerManifestResponse> call = conn_client.GetVerManifestAsync(
                    request,
                    GetMetaHeaderUnary(Dispatcher.EventType.OnFetchVersion.ToString()),
                    null,
                    default(CancellationToken));
                VerManifestResponse response = await call;

                Dispatcher.m_inst.PushEvent(
                    Dispatcher.EventType.OnFetchVersion, true, string.Empty, response, null);

                Jackpot.MainThreadDispatcher.Post(Close);
            });
        }

        // RVA: 0x2EDD0C8
        public void FetchSout(long pid, Action<int, string, string> callback)
        {
            if (Application.internetReachability == NetworkReachability.NotReachable)
            {
                callback?.Invoke(0, null, null);
                return;
            }

            string ip = PlayerPrefs.GetString("endpoint_host", KcAppSetting.ApiEndPoint);
            int port = PlayerPrefs.GetInt("endpoint_port", KcAppSetting.ApiPort);
            ConnectNoRecieve(ip, port);

            Task.Run(async () =>
            {
                MaintenanceRequest request = new MaintenanceRequest();
                request.playerId_ = pid;

                AsyncUnaryCall<MaintenanceResponse> call = conn_client.GetMaintenanceAsync(
                    request,
                    GetMetaHeaderUnary(Dispatcher.EventType.GetMaintenance.ToString()),
                    null,
                    default(CancellationToken));
                MaintenanceResponse response = await call;

                Jackpot.MainThreadDispatcher.Post(() =>
                {
                    callback?.Invoke(response.code_, response.body_, response.refundUrl_);
                });
            });
        }

        // RVA: 0x2EDD290
        public void FetchSoutToken(long pid, Action<string> callback)
        {
            if (Application.internetReachability == NetworkReachability.NotReachable)
            {
                callback?.Invoke(null);
                return;
            }

            string ip = PlayerPrefs.GetString("endpoint_host", KcAppSetting.ApiEndPoint);
            int port = PlayerPrefs.GetInt("endpoint_port", KcAppSetting.ApiPort);
            ConnectNoRecieve(ip, port);

            Task.Run(async () =>
            {
                RefundUrlRequest request = new RefundUrlRequest();
                request.playerId_ = pid;

                AsyncUnaryCall<RefundUrlResponse> call = conn_client.GetRefundUrlAsync(
                    request,
                    GetMetaHeaderUnary(Dispatcher.EventType.GetMaintenance.ToString()),
                    null,
                    default(CancellationToken));
                RefundUrlResponse response = await call;

                Jackpot.MainThreadDispatcher.Post(() =>
                {
                    callback?.Invoke(response.url_);
                });
            });
        }

        // RVA: 0x2EDD41C
        static GrpcConnector()
        {
        }

    }
}
