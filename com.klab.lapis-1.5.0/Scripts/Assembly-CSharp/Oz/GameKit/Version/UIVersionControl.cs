// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.UIVersionControl
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

namespace Oz.GameKit.Version
{
    public class UIVersionControl : MonoBehaviour
    {
        private List<string> m_BackgroundUIPath;
        private string m_ClickAudioPath;
        private GameObject m_BackgroundUI;
        private Transform m_BackgroundRoot;
        private VersionControl m_VersionControl;
        private GameObject m_ProgressRoot;
        private Image m_ProgressBar;
        private Text m_ProgressPrompt;
        private Text m_ProgressDownloadSize;
        private Text m_ProgressDownloadSpeed;
        private Text m_txtVer;
        private Text m_txtId;
        private GameObject m_ChoiceRoot;
        private Text m_ChoicePrompt;
        private Button m_ChoiceOk;
        private Button m_ChoiceCancel;
        private Button m_ChoiceRetry;
        private Action<bool> m_SelectCallback;
        private Action m_RetryCallback;
        private ulong m_ReceivedBytesPerSecond;
        private float m_LastUpdateSpeedTime;
        private AudioSource m_audioSource;
        private AudioClip m_audioClickClip;

        // RVA: 0x188B978（迭代器 MoveNext 0x1891550）
        private IEnumerator SwitchBackgrounds()
        {
            while (true)
            {
                if (m_BackgroundUIPath == null || m_BackgroundUIPath.Count <= 0)
                {
                    yield break;
                }

                int index = Random.Range(0, m_BackgroundUIPath.Count);
                ResourceRequest request = Resources.LoadAsync<GameObject>(
                    "UIVersionControl/" + m_BackgroundUIPath[index]);
                yield return request;

                m_BackgroundUI = Object.Instantiate(request.asset) as GameObject;
                m_BackgroundUI.transform.SetParent(m_BackgroundRoot, false);

                yield return new WaitForSeconds(10f);

                Object.Destroy(m_BackgroundUI);
                m_BackgroundUI = null;
            }
        }

        // RVA: 0x188BA14
        public void Init(VersionControl _vc, Action onComplete)
        {
            m_VersionControl = _vc;
            _vc.onComplete += onComplete;
        }
        // RVA: 0x188BAD8
        private void Awake()
        {
            m_BackgroundRoot = transform.Find("BGRoot");
            m_ProgressRoot = transform.Find("ProgressRoot").gameObject;

            m_ProgressPrompt = m_ProgressRoot.transform.Find("Txt_Prompt").GetComponent<Text>();
            m_ProgressDownloadSize = m_ProgressRoot.transform.Find("Txt_DownloadSize").GetComponent<Text>();
            m_ProgressBar = m_ProgressRoot.transform.Find("Img_Background/Img_Progress").GetComponent<Image>();
            m_ProgressDownloadSpeed = m_ProgressRoot.transform.Find("Txt_DownloadSpeed").GetComponent<Text>();

            m_ChoiceRoot = transform.Find("ChoiceRoot").gameObject;
            m_ChoicePrompt = m_ChoiceRoot.transform.Find("Img_Background/Txt_Prompt").GetComponent<Text>();
            m_ChoiceOk = m_ChoiceRoot.transform.Find("Layout/Btn_Ok").GetComponent<Button>();
            m_ChoiceCancel = m_ChoiceRoot.transform.Find("Layout/Btn_Cancel").GetComponent<Button>();
            m_ChoiceRetry = m_ChoiceRoot.transform.Find("Layout/Btn_Retry").GetComponent<Button>();

            m_ChoiceRoot.transform.Find("Layout/Btn_Ok/Txt_Ok").GetComponent<Text>().text =
                LocalizeDic.GetLocalizeByKey("PROMPT_SURE");
            m_ChoiceRoot.transform.Find("Layout/Btn_Cancel/Txt_Cancel").GetComponent<Text>().text =
                LocalizeDic.GetLocalizeByKey("PROMPT_CANCEL");
            m_ChoiceRoot.transform.Find("Layout/Btn_Retry/Txt_Retry").GetComponent<Text>().text =
                LocalizeDic.GetLocalizeByKey("PROMPT_RETRY");

            m_txtVer = transform.Find("Txt_Version").GetComponent<Text>();
            m_txtVer.text = Application.version;

            m_txtId = transform.Find("Txt_ID").GetComponent<Text>();
            string userId = PlayerPrefs.GetString("PRE_USER_ID", string.Empty);
            if (!string.IsNullOrEmpty(userId))
            {
                m_txtId.text = "Id:" + userId;
            }

            gameObject.AddComponent<AudioListener>();
            m_audioSource = gameObject.AddComponent<AudioSource>();
            m_audioSource.playOnAwake = false;
            m_audioClickClip = Resources.Load<AudioClip>("UIVersionControl/" + m_ClickAudioPath);
            m_audioSource.clip = m_audioClickClip;

            BackTraceKcSupport.SetUserIdAndVer(userId);
        }
        // RVA: 0x188C090
        private void Start()
        {
            AddListener(m_ChoiceOk.gameObject, EventTriggerType.PointerClick, OnClickOk);
            AddListener(m_ChoiceCancel.gameObject, EventTriggerType.PointerClick, OnClickCancel);
            AddListener(m_ChoiceRetry.gameObject, EventTriggerType.PointerClick, OnClickRetry);

            m_VersionControl.onFetchVersionBegin += OnFetchVersionBegin;
            m_VersionControl.onFetchVersionSuccess += OnFetchVersionSuccess;
            m_VersionControl.onFetchVersionFailed += OnFetchVersionFailed;
            m_VersionControl.onUpdateApplication += OnUpdateApplication;
            m_VersionControl.onSelectVersion += OnSelectVersion;
            m_VersionControl.onCheckExtractBegin += OnCheckExtractBegin;
            m_VersionControl.onCheckExtractSuccess += OnCheckExtractSuccess;
            m_VersionControl.onCheckExtractSkip += OnCheckExtractSkip;
            m_VersionControl.onCheckExtractFailed += OnCheckExtractFailed;
            m_VersionControl.onExtractBegin += OnExtractBegin;
            m_VersionControl.onExtractSuccess += OnExtractSuccess;
            m_VersionControl.onExtractError += OnExtractError;
            m_VersionControl.onExtractProgress += OnExtractProgress;
            m_VersionControl.onCheckUpdateBegin += OnCheckUpdateBegin;
            m_VersionControl.onCheckUpdateSuccess += OnCheckUpdateSuccess;
            m_VersionControl.onCheckUpdateSkip += OnCheckUpdateSkip;
            m_VersionControl.onCheckUpdateFailed += OnCheckUpdateFailed;
            m_VersionControl.onUpdateBegin += OnUpdateBegin;
            m_VersionControl.onUpdateSuccess += OnUpdateSuccess;
            m_VersionControl.onUpdateError += OnUpdateError;
            m_VersionControl.onUpdateFailed += OnUpdateFailed;
            m_VersionControl.onUpdateProgress += OnUpdateProgress;
            m_VersionControl.onUpdateSpeed += OnUpdateSpeed;
            m_VersionControl.onUpdateChangeCarrierDataNetwork += OnUpdateChangeCarrierDataNetwork;
            m_VersionControl.onCleanResourceBegin += OnCleanResourceBegin;
            m_VersionControl.onCleanSuccess += OnCleanSuccess;

            m_VersionControl.Begin();
            m_LastUpdateSpeedTime = Time.realtimeSinceStartup;
            StartCoroutine(SwitchBackgrounds());
        }

        // RVA: 0x188E104
        private void Update()
        {
            if (m_VersionControl == null)
            {
                return;
            }

            m_VersionControl.Update();

            if (m_ProgressDownloadSpeed != null
                && m_ProgressDownloadSpeed.gameObject.activeSelf
                && Time.realtimeSinceStartup - m_LastUpdateSpeedTime > 1f)
            {
                m_ProgressDownloadSpeed.text = string.Format(
                    LocalizeDic.GetLocalizeByKey("DOWNLOAD_SPEED"),
                    ByteSizeToString(m_ReceivedBytesPerSecond));
                m_ReceivedBytesPerSecond = 0;
                m_LastUpdateSpeedTime = Time.realtimeSinceStartup;
            }
        }
        // RVA: 0x188E3A4
        private void OnDestroy()
        {
            m_VersionControl.onFetchVersionBegin -= OnFetchVersionBegin;
            m_VersionControl.onFetchVersionSuccess -= OnFetchVersionSuccess;
            m_VersionControl.onFetchVersionFailed -= OnFetchVersionFailed;
            m_VersionControl.onSelectVersion -= OnSelectVersion;
            m_VersionControl.onCheckExtractBegin -= OnCheckExtractBegin;
            m_VersionControl.onCheckExtractSuccess -= OnCheckExtractSuccess;
            m_VersionControl.onCheckExtractFailed -= OnCheckExtractFailed;
            m_VersionControl.onExtractBegin -= OnExtractBegin;
            m_VersionControl.onExtractSuccess -= OnExtractSuccess;
            m_VersionControl.onExtractError -= OnExtractError;
            m_VersionControl.onExtractProgress -= OnExtractProgress;
            m_VersionControl.onCheckUpdateBegin -= OnCheckUpdateBegin;
            m_VersionControl.onCheckUpdateSuccess -= OnCheckUpdateSuccess;
            m_VersionControl.onCheckUpdateSkip -= OnCheckUpdateSkip;
            m_VersionControl.onCheckUpdateFailed -= OnCheckUpdateFailed;
            m_VersionControl.onUpdateBegin -= OnUpdateBegin;
            m_VersionControl.onUpdateSuccess -= OnUpdateSuccess;
            m_VersionControl.onUpdateError -= OnUpdateError;
            m_VersionControl.onUpdateFailed -= OnUpdateFailed;
            m_VersionControl.onUpdateProgress -= OnUpdateProgress;
            m_VersionControl.onUpdateSpeed -= OnUpdateSpeed;

            RemoveListener(m_ChoiceOk.gameObject, EventTriggerType.PointerClick, OnClickOk);
            RemoveListener(m_ChoiceCancel.gameObject, EventTriggerType.PointerClick, OnClickCancel);
            RemoveListener(m_ChoiceRetry.gameObject, EventTriggerType.PointerClick, OnClickRetry);
        }

        // RVA: 0x188C864
        protected void AddListener(GameObject gameObject, EventTriggerType eventID, UnityAction<BaseEventData> callback)
        {
            if (gameObject == null)
            {
                return;
            }

            EventTrigger.Entry entry = new EventTrigger.Entry();
            entry.eventID = eventID;
            entry.callback.AddListener(callback);
            gameObject.AddMissingComponent<EventTrigger>().triggers.Add(entry);
        }

        // RVA: 0x188F794
        protected void RemoveListener(GameObject gameObject, EventTriggerType eventID, UnityAction<BaseEventData> callback)
        {
            if (gameObject == null)
            {
                return;
            }

            EventTrigger trigger = gameObject.GetComponent<EventTrigger>();
            if (trigger == null)
            {
                return;
            }

            List<EventTrigger.Entry> triggers = trigger.triggers;
            for (int i = 0; i < triggers.Count; i++)
            {
                if (triggers[i] != null && triggers[i].eventID == eventID)
                {
                    triggers[i].callback.RemoveListener(callback);
                }
            }
        }

        // RVA: 0x188F8F0
        public void OnCleanResourceBegin()
        {
            if (m_ProgressPrompt != null)
            {
                m_ProgressPrompt.text = LocalizeDic.GetLocalizeByKey("RESOURCE_CLEAN");
            }
        }

        // RVA: 0x188F9C4
        public void OnCleanSuccess()
        {
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(eCommand.Success);
            }
        }

        // RVA: 0x188FA4C
        private void OnFetchVersionBegin()
        {
            if (m_ProgressPrompt != null)
            {
                m_ProgressPrompt.text = LocalizeDic.GetLocalizeByKey("BOOT_INFO_GET");
            }
        }

        // RVA: 0x188FB20
        private void OnFetchVersionSuccess()
        {
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(eCommand.Success);
            }
        }

        // RVA: 0x188FB3C
        private void OnFetchVersionSkip()
        {
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(eCommand.Skip);
            }
        }

        // RVA: 0x188FB58
        public void OnUpdateApplication(Action<bool> onSelectVersion)
        {
            m_SelectCallback = onSelectVersion;
            ShowOkCancelDlg(LocalizeDic.GetLocalizeByKey("FORCE_UPDATE_CONFIRM"));
        }

        // RVA: 0x188FCBC
        private void OnFetchVersionFailed()
        {
            ShowRetryCancelDlg(LocalizeDic.GetLocalizeByKey("BOOT_INFO_GET_FAILED"));
        }

        // RVA: 0x188FE10
        private void OnSelectVersion(ulong version, Action<bool> onSelectVersion)
        {
            m_SelectCallback = onSelectVersion;
            ShowOkCancelDlg(string.Format(
                LocalizeDic.GetLocalizeByKey("UPDATE_VERSION_TIPS"), version));
        }

        // RVA: 0x188FED4
        private void OnCheckExtractBegin()
        {
            if (m_ProgressPrompt != null)
            {
                m_ProgressPrompt.text = LocalizeDic.GetLocalizeByKey("EXTRA_CHECK");
            }
        }

        // RVA: 0x188FFA8
        private void OnCheckExtractFailed(StateCheckExtract.FailedReason error)
        {
            string key;
            if (error == StateCheckExtract.FailedReason.ParseError)
            {
                key = "PARSE_INNER_VERSION_ERROR";
            }
            else if (error == StateCheckExtract.FailedReason.NotFound)
            {
                key = "FIND_INNER_VERSION_ERROR";
            }
            else
            {
                key = "UNKOWN_ERROR";
            }
            ShowRetryCancelDlg(LocalizeDic.GetLocalizeByKey(key));
        }

        // RVA: 0x1890078
        private void OnCheckExtractSuccess(bool hasExtractContent)
        {
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(hasExtractContent ? eCommand.Success : eCommand.Skip);
            }
        }

        // RVA: 0x18900A0
        private void OnCheckExtractSkip()
        {
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(eCommand.Skip);
            }
        }

        // RVA: 0x18900BC
        private void OnExtractBegin()
        {
            if (m_ProgressPrompt != null)
            {
                m_ProgressPrompt.text = LocalizeDic.GetLocalizeByKey("EXTRA_NOW_TIPS");
            }
        }

        // RVA: 0x1890190
        private void OnExtractSuccess()
        {
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(eCommand.Success);
            }
        }

        // RVA: 0x18901AC
        private void OnExtractError(string error)
        {
            ShowRetryCancelDlg(error);
        }

        // RVA: 0x18901B0
        private void OnExtractProgress(float value)
        {
            if (m_ProgressBar != null)
            {
                m_ProgressBar.fillAmount = value;
            }
        }

        // RVA: 0x1890258
        private void OnCheckUpdateBegin()
        {
            if (m_ProgressPrompt != null)
            {
                m_ProgressPrompt.text = LocalizeDic.GetLocalizeByKey("UPDATE_CHECK");
            }
        }

        // RVA: 0x189032C
        private void OnCheckUpdateSuccess(long downloadSize)
        {
            if (Application.internetReachability == NetworkReachability.ReachableViaCarrierDataNetwork)
            {
                m_RetryCallback = () => OnCheckUpdateSuccess(downloadSize);
                ShowOkRetryDlg(string.Format(
                    LocalizeDic.GetLocalizeByKey("DOWNLOAD_SIZE_PROT"),
                    ByteSizeToString((ulong)downloadSize)));
                return;
            }

            if (Application.internetReachability != NetworkReachability.ReachableViaLocalAreaNetwork)
            {
                if (m_VersionControl != null)
                {
                    m_VersionControl.Trigger(eCommand.Success);
                }
                return;
            }

            m_RetryCallback = null;
            ShowOkDlg(string.Format(
                LocalizeDic.GetLocalizeByKey("DOWNLOAD_CONFRIM"),
                ByteSizeToString((ulong)downloadSize)));
        }

        // RVA: 0x1890688
        private void OnCheckUpdateSkip(bool hasDeleAssets)
        {
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(hasDeleAssets ? eCommand.SkipToDelete : eCommand.Skip);
            }
        }

        // RVA: 0x18906B0
        private void OnCheckUpdateFailed(StateCheckUpdate.FailedReason error)
        {
            string key;
            switch (error)
            {
                case StateCheckUpdate.FailedReason.ParseError:
                    key = "VERSION_FILE_ERROR";
                    break;
                case StateCheckUpdate.FailedReason.AppVersionError:
                    key = "APP_VERSION_NOT_VALID";
                    break;
                case StateCheckUpdate.FailedReason.DownloadError:
                    key = "DOWNLOAD_COMMON_ERROR";
                    break;
                case StateCheckUpdate.FailedReason.VersionError:
                    key = "VERSION_HIGHER_THAN_SERVER";
                    break;
                default:
                    key = "UNKOWN_ERROR";
                    break;
            }
            ShowRetryCancelDlg(LocalizeDic.GetLocalizeByKey(key));
        }

        // RVA: 0x1890804
        private void OnUpdateBegin()
        {
            if (m_ProgressPrompt != null)
            {
                m_ProgressPrompt.text = LocalizeDic.GetLocalizeByKey("DOWNLOAD_TIPS");
            }
            if (m_ProgressDownloadSpeed != null)
            {
                m_ProgressDownloadSpeed.gameObject.SetActive(true);
            }
            m_ReceivedBytesPerSecond = 0;
        }

        // RVA: 0x189092C
        private void OnUpdateSuccess()
        {
            if (m_ProgressDownloadSpeed != null)
            {
                m_ProgressDownloadSpeed.gameObject.SetActive(false);
            }
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(eCommand.Success);
            }
        }

        // RVA: 0x18909D4
        private void OnUpdateError(string error)
        {
            if (m_ProgressDownloadSpeed != null)
            {
                m_ProgressDownloadSpeed.gameObject.SetActive(false);
            }
            if (m_ProgressPrompt != null)
            {
                m_ProgressPrompt.text =
                    LocalizeDic.GetLocalizeByKey("ERROR_PREFIX") +
                    LocalizeDic.GetLocalizeByKey("DOWNLOAD_COMMON_ERROR");
            }
        }

        // RVA: 0x1890B2C
        private void OnUpdateFailed()
        {
            ShowRetryCancelDlg(LocalizeDic.GetLocalizeByKey("DOWNLOAD_ERROR"));
        }

        // RVA: 0x1890BA4
        private void OnUpdateChangeCarrierDataNetwork(ulong size)
        {
            m_RetryCallback = OnRetryDataNetwork;
            m_SelectCallback = b =>
            {
                if (m_VersionControl != null)
                {
                    m_VersionControl.Trigger(eCommand.Retry);
                }
                m_RetryCallback = null;
            };
            ShowOkRetryDlg(string.Format(
                LocalizeDic.GetLocalizeByKey("DOWNLOAD_CHANGE_NETWORK"), ByteSizeToString(size)));
        }

        // RVA: 0x1890CAC
        private void OnRetryDataNetwork()
        {
            if (Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork)
            {
                if (m_VersionControl != null)
                {
                    m_VersionControl.Trigger(eCommand.Retry);
                    m_SelectCallback = null;
                    return;
                }
            }

            m_RetryCallback = OnRetryDataNetwork;
            m_SelectCallback = b =>
            {
                if (m_VersionControl != null)
                {
                    m_VersionControl.Trigger(eCommand.Retry);
                }
                m_RetryCallback = null;
            };

            if (m_ChoiceRoot != null)
            {
                m_ChoiceRoot.SetActive(true);
            }
        }

        // RVA: 0x1890DA4
        private void OnUpdateProgress(ulong receivedBytes, ulong totalBytes)
        {
            if (receivedBytes > totalBytes)
            {
                receivedBytes = totalBytes;
            }

            if (m_ProgressDownloadSize != null)
            {
                string format = LocalizeDic.GetLocalizeByKey("DOWNLOAD_PROGRESS");
                m_ProgressDownloadSize.text = string.Format(
                    format, ByteSizeToString(receivedBytes), ByteSizeToString(totalBytes));
            }

            if (m_ProgressBar != null)
            {
                m_ProgressBar.fillAmount = totalBytes != 0
                    ? (float)receivedBytes / (float)totalBytes
                    : 0f;
            }
        }

        // RVA: 0x1890F38
        private void OnUpdateSpeed(ulong receivedBytes)
        {
            m_ReceivedBytesPerSecond += receivedBytes;
        }

        // RVA: 0x1890F48
        private void PlayClickAudio()
        {
            if (m_audioSource != null)
            {
                m_audioSource.Stop();
                m_audioSource.Play();
            }
        }

        // RVA: 0x1890F84
        private void OnClickOk(BaseEventData eventData)
        {
            PlayClickAudio();

            if (m_ChoiceRoot != null)
            {
                m_ChoiceRoot.SetActive(false);
            }
            if (m_ProgressRoot != null)
            {
                m_ProgressRoot.SetActive(true);
            }

            System.Action<bool> select = m_SelectCallback;
            m_RetryCallback = null;
            if (select != null)
            {
                select(true);
                m_SelectCallback = null;
                return;
            }
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(eCommand.Success);
            }
        }

        // RVA: 0x189104C
        private void OnClickCancel(BaseEventData eventData)
        {
            PlayClickAudio();

            if (m_ChoiceRoot != null)
            {
                m_ChoiceRoot.SetActive(false);
            }
            if (m_ProgressRoot != null)
            {
                m_ProgressRoot.SetActive(true);
            }

            System.Action<bool> select = m_SelectCallback;
            if (select != null)
            {
                select(false);
                m_SelectCallback = null;
                return;
            }
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(eCommand.Cancel);
            }
        }

        // RVA: 0x1891110
        private void OnClickRetry(BaseEventData eventData)
        {
            PlayClickAudio();

            if (m_ChoiceRoot != null)
            {
                m_ChoiceRoot.SetActive(false);
            }
            if (m_ProgressRoot != null)
            {
                m_ProgressRoot.SetActive(true);
            }

            if (m_RetryCallback != null)
            {
                m_RetryCallback();
                m_RetryCallback = null;
                return;
            }
            if (m_VersionControl != null)
            {
                m_VersionControl.Trigger(eCommand.Retry);
            }
        }

        // RVA: 0x188FD34
        private void ShowRetryCancelDlg(string prompt)
        {
            if (m_ProgressRoot != null)
            {
                m_ProgressRoot.SetActive(false);
            }
            if (m_ChoicePrompt != null)
            {
                m_ChoicePrompt.text = prompt;
            }
            if (m_ChoiceRoot != null)
            {
                m_ChoiceRoot.SetActive(true);
            }
            if (m_ChoiceCancel != null)
            {
                m_ChoiceCancel.SetActive(true);
            }
            if (m_ChoiceOk != null)
            {
                m_ChoiceOk.SetActive(false);
            }
            if (m_ChoiceRetry != null)
            {
                m_ChoiceRetry.SetActive(true);
            }
        }

        // RVA: 0x188FBE0
        private void ShowOkCancelDlg(string prompt)
        {
            if (m_ProgressRoot != null)
            {
                m_ProgressRoot.SetActive(false);
            }
            if (m_ChoicePrompt != null)
            {
                m_ChoicePrompt.text = prompt;
            }
            if (m_ChoiceRoot != null)
            {
                m_ChoiceRoot.SetActive(true);
            }
            if (m_ChoiceCancel != null)
            {
                m_ChoiceCancel.SetActive(true);
            }
            if (m_ChoiceOk != null)
            {
                m_ChoiceOk.SetActive(true);
            }
            if (m_ChoiceRetry != null)
            {
                m_ChoiceRetry.SetActive(false);
            }
        }

        // RVA: 0x18905AC
        private void ShowOkDlg(string prompt)
        {
            if (m_ProgressRoot != null)
            {
                m_ProgressRoot.SetActive(false);
            }
            if (m_ChoicePrompt != null)
            {
                m_ChoicePrompt.text = prompt;
            }
            if (m_ChoiceRoot != null)
            {
                m_ChoiceRoot.SetActive(true);
            }
            if (m_ChoiceCancel != null)
            {
                m_ChoiceCancel.SetActive(false);
            }
            if (m_ChoiceOk != null)
            {
                m_ChoiceOk.SetActive(true);
            }
            if (m_ChoiceRetry != null)
            {
                m_ChoiceRetry.SetActive(false);
            }
        }

        // RVA: 0x18904D0
        private void ShowOkRetryDlg(string prompt)
        {
            if (m_ProgressRoot != null)
            {
                m_ProgressRoot.SetActive(false);
            }
            if (m_ChoicePrompt != null)
            {
                m_ChoicePrompt.text = prompt;
            }
            if (m_ChoiceRoot != null)
            {
                m_ChoiceRoot.SetActive(true);
            }
            if (m_ChoiceCancel != null)
            {
                m_ChoiceCancel.SetActive(false);
            }
            if (m_ChoiceOk != null)
            {
                m_ChoiceOk.SetActive(true);
            }
            if (m_ChoiceRetry != null)
            {
                m_ChoiceRetry.SetActive(true);
            }
        }

        // RVA: 0x188E2AC
        private string ByteSizeToString(ulong size)
        {
            if (size > 1023)
            {
                float value = size;
                if ((size >> 20) != 0)
                {
                    return string.Format("{0:F2}(MB)", value * 0.00000095367f);
                }
                return string.Format("{0:F1}(KB)", value * 0.00097656f);
            }
            return string.Format("{0}(B)", size);
        }

        // RVA: 0x18911A0
        public bool IsChooiceUiShow()
        {
            return m_ChoiceRoot != null && m_ChoiceRoot.gameObject.activeSelf;
        }

        // RVA: 0x18911CC
        public void CallClickOk()
        {
            if (m_ChoiceOk != null && m_ChoiceOk.gameObject.activeSelf)
            {
                OnClickOk(null);
                return;
            }
            if (m_ChoiceRetry != null && m_ChoiceRetry.gameObject.activeSelf)
            {
                OnClickRetry(null);
            }
        }
        // RVA: 0x189124C
        public UIVersionControl()
        {
            m_BackgroundUIPath = new List<string>
            {
                "BG 101",
                "BG 102",
                "BG 103",
                "BG 104",
                "BG 105",
                "BG 201",
                "BG 202",
                "BG 203",
                "BG 301",
                "BG 302",
                "BG 303",
                "BG 304",
                "BG 401",
                "BG 402",
                "BG 403",
                "BG 501",
                "BG 502",
                "BG 503",
                "BG 601",
                "BG 602",
            };
            m_ClickAudioPath = "Audio/ClickClip";
        }

    }
}
