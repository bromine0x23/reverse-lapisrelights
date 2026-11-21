// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.NetworkModule.NetworkManager
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//
//  说明：已按成员 RVA 还原连接管理、心跳、HTTP 旁路以及公告/维护弹窗流程；
//  方法体来源于 libil2cpp.so 反汇编，RVA 标注在对应方法上。
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using Oz.Framework.Utility;
using System.IO;
using UnityEngine.Networking;
using Oz.GameFramework.Runtime;
using Oz.GameKit.Version;
using Jigbox.Components;
using Jigbox.UIControl;
using MiniJSON;
using Kc.Config;
using Oz.Framework.UIModule;
using Oz.GameFramework.Runtime.Coroutines;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace Oz.Framework.NetworkModule
{
    /// <summary>网络总控：连接管理、心跳、HTTP 旁路与公告/维护弹窗。</summary>
    public class NetworkManager : MonoBehaviour
    {
        public static string COMMON_KEY;
        public static string ERROR_SIGN;
        public static string ERROR_KICKOFF;
        public static string ERROR_CAUTION;
        public static string ERROR_SERVER_ERROR;
        public static string ERROR_HTTP1_ERROR;
        public static string ERROR_RECIEVE_SEND;
        public static string ERROR_RES_VER;
        public static string ERROR_MAINTAIN;
        public static string ERROR_FORCE_UPDATE;
        public static int CONNECT_MSGID;
        public static int LOGIN_MSGID;
        public static int GET_PLAYER_MSGID;
        public static int HEART_MSGID;
        public static int TIMEOUT_DURATION;

        private bool useGRPC;
        private bool isBlock;
        private static Connectable m_ctn_gate;
        private static int m_RetryCount;
        private static int m_RetryCount2;
        private bool isHeartSend;
        private List<HeartSendInfo> heartSendInfos;
        private Dictionary<string, object> mainDic;

        private static NetworkManager Instance { get; set; }

        /// <summary>当前 Gate 连接（TCP 或 gRPC 实现）。</summary>
        public static Connectable ConnectorGate
        {
            // RVA: 0x2EE0A54
            get { return m_ctn_gate; }
        }

        /// <summary>当前连接为 gRPC 时返回其实现，否则 null。</summary>
        public static GrpcConnector GrpcGate
        {
            // RVA: 0x2EE0ABC
            get { return m_ctn_gate as GrpcConnector; }
        }

        // RVA: 0x2EE0B64
        private void Awake()
        {
            m_RetryCount = 0;
            m_RetryCount2 = 0;

            if (Instance == null)
            {
                Instance = this;
            }

            ProtocolFixedHeader protocolFixedHeader = new ProtocolFixedHeader();
            if (useGRPC)
            {
                string platform = Application.platform == RuntimePlatform.Android ? "a" : "i";
                m_ctn_gate = new GrpcConnector(
                    protocolFixedHeader, Application.version, platform, KcAppSetting.CurrentLang);
            }
            else
            {
                m_ctn_gate = new Connector(protocolFixedHeader);
            }

            Debug.Log("init network " + m_ctn_gate);

            Dispatcher.CreateInstance();
            Dispatcher.m_inst.OnConnect += OnConnect;
            Dispatcher.m_inst.OnDisconnect += OnDisconnect;
            Dispatcher.m_inst.OnServerError += OnServerError;
        }

        // RVA: 0x2EE103C
        private void Update()
        {
            if (m_ctn_gate != null)
            {
                m_ctn_gate.Flush();
            }
            Dispatcher.m_inst.Dispatch();
            if (isHeartSend)
            {
                ProcessHeartSend();
            }
        }

        // RVA: 0x2EE1114
        private void ProcessHeartSend()
        {
            foreach (HeartSendInfo info in heartSendInfos)
            {
                if (!info.IsReached())
                {
                    continue;
                }

                // 需要登录的协议仅在 gRPC 连接且 playerId 已设置时发送
                if (info.NeedLogin && (!(m_ctn_gate is GrpcConnector grpc) || grpc.m_playerId == 0))
                {
                    continue;
                }

                m_ctn_gate.Send(info.ProtocolName, 0, null, false, true, false);

                if (info.IsBidiCallSupport)
                {
                    ((GrpcConnector)m_ctn_gate).SendBidiPing(info.ProtocolName);
                }
            }
        }

        // RVA: 0x2EE13C0
        private void OnDestroy()
        {
            Dispatcher.m_inst = null;

            m_ctn_gate.Disconnect();
            m_ctn_gate = null;

            if (Instance != null)
            {
                Instance = null;
            }
        }

        // RVA: 0x2EE1560
        public static void SetResVersion(string ver)
        {
            if (m_ctn_gate is GrpcConnector grpc)
            {
                grpc.resVersion = ver;
            }
        }

        // RVA: 0x2EE1664
        public static void RequestHttpOne(string msg, int group, byte[] data, bool needAuth = true)
        {
            Instance.StartCoroutine(RequestHttpOneInternal(msg, group, data, needAuth));
        }

        // RVA: 0x2EE1750
        private static IEnumerator RequestHttpOneInternal(string msg, int group, byte[] data, bool needAuth)
        {
            if (m_ctn_gate is GrpcConnector grpc)
            {
                yield return grpc.RequestHttpOne(msg, group, data, needAuth);
            }
        }

        /// <summary>消息号是否属于节点 <paramref name="st"/> 的号段（每段 1000 万）。</summary>
        // RVA: 0x2EE1818
        public static bool IsServerMsg(NetNodeType st, int msg)
        {
            return 10000000 * (int)st <= msg && 10000000 * (int)st + 10000000 > msg;
        }

        // RVA: 0x2EE1840
        public static void GetWebViewNotice(string url, Action<List<WebNoticeDetail>> action)
        {
            Instance.StartCoroutine(Instance.GetWebNotice(url, action));
        }

        // RVA: 0x2EE1970
        private IEnumerator GetWebNotice(string url, Action<List<WebNoticeDetail>> callback)
        {
            Uri uri = new UriBuilder(url).Uri;

            using (UnityWebRequest request = UnityWebRequest.Get(uri))
            {
                yield return request.SendWebRequest();

                if (request.isNetworkError || request.isHttpError || !string.IsNullOrEmpty(request.error))
                {
                    callback?.Invoke(new List<WebNoticeDetail>());
                }
                else
                {
                    WebNoticeInfo info = JsonUtility.FromJson<WebNoticeInfo>(request.downloadHandler.text);
                    callback?.Invoke(info.data);
                }
            }
        }

        // RVA: 0x2EE1A18
        public static void GetServerNotice(string domin, Action<SerNotice> actionResult)
        {
            string url = AppConst.BootInfoUri[m_RetryCount++ % AppConst.BootInfoUri.Count];
            Instance.StartCoroutine(Instance.DownloadNotice(url, actionResult));
        }

        // RVA: 0x2EE1BA4
        private IEnumerator DownloadNotice(string URL, Action<SerNotice> actionResult)
        {
            Uri uri = new UriBuilder(URL).Uri;
            SerNotice serInfo = new SerNotice();

            using (UnityWebRequest request = UnityWebRequest.Get(uri))
            {
                yield return request.SendWebRequest();

                if (!request.isNetworkError && !request.isHttpError && string.IsNullOrEmpty(request.error))
                {
                    using (MemoryStream stream = new MemoryStream(request.downloadHandler.data))
                    {
                        BootInfo bootInfo = BootInfo.ReadFromStream(stream);
                        if (bootInfo != null
                            && bootInfo.TryGetNotice(VersionControl.NoticeKey, out NoticeInfo noticeInfo))
                        {
                            serInfo.code = 0;
                            serInfo.news = noticeInfo.news;
                            serInfo.black = noticeInfo.black;
                            serInfo.black_start_ts = noticeInfo.black_start_ts;
                            serInfo.black_end_ts = noticeInfo.black_end_ts;
                            actionResult?.Invoke(serInfo);
                            yield break;
                        }
                    }
                }
            }

            serInfo.code = 1;
            serInfo.desc = "暂时无法连接";
            actionResult?.Invoke(serInfo);
        }

        // RVA: 0x2EE1C4C
        public static void GetServerList(
            string domin,
            string pf,
            string param,
            string ts,
            string cid,
            string sub_cid,
            string ptoken,
            Action<SerInfo> actionResult)
        {
            string url = VersionControl.ServerListURLs[m_RetryCount2++ % VersionControl.ServerListURLs.Count];

            Dictionary<string, string> formFields = new Dictionary<string, string>
            {
                { "cid", cid },
                { "sub_cid", sub_cid },
                { "pid", pf },
                { "puid", param },
                { "ptoken", ptoken },
                { "ts", ts },
            };

            string sign = CryptoUtility.GetMD5(pf + param + ts, 0).Substring(4, 24).ToUpper();
            formFields.Add("sign", CryptoUtility.GetMD5(sign, 0).ToLower());

            Instance.StartCoroutine(Instance.DownloadDistrict(url, formFields, actionResult));
        }

        // RVA: 0x2EE2028
        private IEnumerator DownloadDistrict(
            string URL, Dictionary<string, string> formFields, Action<SerInfo> actionResult)
        {
            using (UnityWebRequest request = UnityWebRequest.Post(new UriBuilder(URL).Uri, formFields))
            {
                request.timeout = TIMEOUT_DURATION;
                yield return request.SendWebRequest();

                if (request.isNetworkError || request.isHttpError || !string.IsNullOrEmpty(request.error))
                {
                    RequestHttpError(request.error, actionResult);
                }
                else
                {
                    RequestHttpOk(request.downloadHandler.text, actionResult);
                }
            }
        }

        // RVA: 0x2EE20D8
        private static void RequestHttpOk(string json, Action<SerInfo> actionResult)
        {
            if (!string.IsNullOrEmpty(json))
            {
                SerInfo info = JsonUtility.FromJson<SerInfo>(json);
                actionResult?.Invoke(info);
            }
        }

        // RVA: 0x2EE2170
        private static void RequestHttpError(string strMsg, Action<SerInfo> actionResult)
        {
            SerInfo info = new SerInfo { code = 1, desc = "暂时无法连接" };
            actionResult?.Invoke(info);
        }

        // RVA: 0x2EE2218
        private void OnConnect(bool is_succ, string brief, Connector cnt)
        {
            if (is_succ)
            {
                isHeartSend = true;
            }
        }

        // RVA: 0x2EE2228
        private void OnDisconnect(bool is_succ, string brief, int chl)
        {
            if (m_ctn_gate != null && m_ctn_gate.GetHashCode() == chl)
            {
                m_ctn_gate.Disconnect();
            }

            isHeartSend = false;
        }

        // RVA: 0x2EE22F4
        private void OnServerError(string reason)
        {
            Debug.LogWarning("[Server Error] Reason is:" + reason);

            if (reason == ERROR_MAINTAIN || reason == ERROR_FORCE_UPDATE)
            {
                StartCoroutine(GetMaintainMsg(reason));
            }
        }

        // RVA: 0x2EE2424
        private IEnumerator GetMaintainMsg(string reason)
        {
            using (UnityWebRequest request = new UnityWebRequest(KcAppSetting.MaintainUrl, "GET"))
            {
                request.downloadHandler = new DownloadHandlerBuffer();
                yield return request.SendWebRequest();

                if (!request.isNetworkError)
                {
                    Debug.LogWarning("on res : " + request.downloadHandler.text);

                    Dictionary<string, object> json =
                        (Dictionary<string, object>)Json.Deserialize(request.downloadHandler.text);
                    mainDic = json;

                    string message = json[KcAppSetting.CurrentLang].ToString();

                    if (reason == ERROR_MAINTAIN)
                    {
                        string title = json["TITLE_JP"].ToString();
                        ShowMaintainView(title, message, OnClickOk);
                    }
                    else if (reason == ERROR_FORCE_UPDATE)
                    {
                        ShowMaintainView(
                            LocalizeDic.GetLocalizeByKey("FORCE_UPDATE_TITLE"),
                            LocalizeDic.GetLocalizeByKey("FORCE_UPDATE_CONFIRM"),
                            OnClickForceUpdate);
                    }
                }
            }
        }

        // RVA: 0x2EE24CC
        private void ShowMaintainView(string title, string reason, UnityAction callback)
        {
            if (isBlock)
            {
                return;
            }

            GameObject panel;
            if (Launcher.isUpdateComplete)
            {
                AssetRef prefab = ResourceManager.LoadSync(
                    "UIVersionControl/PanelMaintain", typeof(GameObject));
                panel = Object.Instantiate(prefab.Asset as GameObject);

                AssetRef fontAsset = ResourceManager.LoadSync("Font/OzST", typeof(Font));
                Font font = fontAsset.Asset as Font;
                foreach (Text text in panel.GetComponentsInChildren<Text>())
                {
                    text.font = font;
                }
                panel.GetComponentInChildren<TextView>().Font = font;
            }
            else
            {
                panel = Object.Instantiate(
                    Resources.Load("UIVersionControl/PanelMaintain", typeof(GameObject)));
            }

            UIManager.AttachToLayer(panel, "LOADING");

            Transform layout = panel.transform.Find("ChoiceRoot").gameObject.transform;
            Button button = layout.Find("Btn_Ok").GetComponent<Button>();
            Text titleText = layout.Find("Image/Txt_Title").GetComponent<Text>();
            ScrollRect scrollRect = layout.Find("Img_Background/ScrollView").GetComponent<ScrollRect>();
            TextView prompt = layout
                .Find("Img_Background/ScrollView/Viewport/Txt_Prompt")
                .GetComponent<TextView>();

            titleText.text = title;
            prompt.Text = reason;
            CoroutineManager.StartCoroutine(UpdateTextHeight(prompt, scrollRect));
            button.onClick.AddListener(callback);

            isBlock = true;
        }

        // RVA: 0x2EE2AB0
        private IEnumerator UpdateTextHeight(TextView text, ScrollRect sRect)
        {
            yield return new WaitForEndOfFrame();

            float width = text.rectTransform.rect.size.x;
            float height = text.GetPreferredHeight(0) + 50f;
            RectTransformUtils.SetSize(text.rectTransform, new Vector2(width, height), true);
            sRect.verticalNormalizedPosition = 1f;
        }

        // RVA: 0x2EE2B58
        private void OnClickOk()
        {
            Launcher.Instance.Restart();
        }

        /// <summary>跳转商店：Android 用 STORE_URL_A，其余用 STORE_URL_I。</summary>
        // RVA: 0x2EE2C08
        private void OnClickForceUpdate()
        {
            string key = Application.platform == RuntimePlatform.Android ? "STORE_URL_A" : "STORE_URL_I";
            if (mainDic != null)
            {
                Application.OpenURL(mainDic[key].ToString());
            }
        }

        // RVA: 0x2EE2CA4
        public NetworkManager()
        {
            useGRPC = true;
            heartSendInfos = new List<HeartSendInfo>
            {
                new HeartSendInfo { ProtocolName = "P9000_Request", Delay = 60, NeedLogin = false },
                new HeartSendInfo { ProtocolName = "P1021_Request", Delay = 60, NeedLogin = true },
            };
        }

        // RVA: 0x2EE2DD8
        static NetworkManager()
        {
            COMMON_KEY = "COMMON_KEY";
            ERROR_SIGN = "ERROR_SIGN";
            ERROR_KICKOFF = "ERROR_KICKOFF";
            ERROR_CAUTION = "ERROR_CAUTION";
            ERROR_SERVER_ERROR = "ERROR_SERVER_ERROR";
            ERROR_HTTP1_ERROR = "ERROR_HTTP1_ERROR";
            ERROR_RECIEVE_SEND = "ERROR_RECIEVE_SEND";
            ERROR_RES_VER = "ERROR_RES_VER";
            ERROR_MAINTAIN = "ERROR_MAINTAIN";
            ERROR_FORCE_UPDATE = "ERROR_FORCE_UPDATE";
            CONNECT_MSGID = 999;
            LOGIN_MSGID = 1001;
            GET_PLAYER_MSGID = 11;
            HEART_MSGID = 9000;
            TIMEOUT_DURATION = 5;
            m_RetryCount = 0;
            m_RetryCount2 = 0;
        }
    }
}
