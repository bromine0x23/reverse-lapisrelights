// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.Launcher
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections;
using Backtrace.Unity;
using CodeStage.AntiCheat.Detectors;
using Oz.Framework.LuaModule;
using Oz.Framework.NetworkModule;
using Oz.Framework.SoundModule;
using Oz.Framework.UIModule;
using Oz.Framework.Utility;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Resource;
using Oz.GameKit.Version;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace Oz.Framework
{
    /// <summary>
    /// 游戏启动器（常驻对象）。负责单例、日志过滤、管理器组件装配，
    /// 版本检查面板的加载与初始化，以及重启/退出流程。
    /// </summary>
    public class Launcher : MonoBehaviour
    {
        [SerializeField]
        private eLaunchMode _mode;
        [HideInInspector]
        public LuaManager LuaMgr;
        [HideInInspector]
        public BacktraceClient BKClient;
        [HideInInspector]
        public BackKeyListener BackKeyProcess;
        public ClickEffect ClickEffect;

        public static bool hasVerUpdate;
        public static bool isUpdateComplete;

        public static Launcher Instance { get; set; }

        // RVA: 0x13FF774
        public void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
            }

            // 只保留异常级别的日志
            Debug.unityLogger.filterLogType = LogType.Exception;
            LuaInterface.Debugger.useLog = false;
            isUpdateComplete = false;

            Object.DontDestroyOnLoad(gameObject);
            Jackpot.Platform.RequestAtt();
            Screen.sleepTimeout = -1; // SleepTimeout.NeverSleep
            Time.timeScale = 1f;
            SystemInfoUtil.GDeviceU3DInterfaceInit();

            // 反汇编确认（0x13FFA58/0x13FFA6C 两次 box，0x13FFA80 调 Enum.HasFlag(object)）：
            // 即 _mode 与 eLaunchMode.Auto 均装箱后调用 HasFlag
            if (_mode.HasFlag(eLaunchMode.Auto))
            {
                // 依次补齐运行时管理组件
                gameObject.AddComponent<ResourceManager>();
                gameObject.AddComponent<EffectManager>();
                gameObject.AddComponent<EventListenerManager>();
                gameObject.AddComponent<TimerManager>();
                gameObject.AddComponent<SceneManager>();
                gameObject.AddComponent<SoundManager>();
                gameObject.AddComponent<UIManager>();
                gameObject.AddComponent<NetworkManager>();
                gameObject.AddComponent<OzSDKManager>();
                BackKeyProcess = gameObject.AddComponent<BackKeyListener>();
                gameObject.AddComponent<OptionalDownload>();
                ClickEffect = gameObject.AddComponent<ClickEffect>();
                LuaMgr = gameObject.AddComponent<LuaManager>();
            }

            BKClient = BackTraceKcSupport.Create();
        }

        // RVA: 0x13FFC70
        private void OnDestroy()
        {
            if (Instance != null)
            {
                Instance = null;
            }
            SqlLiteSupport.CloseAll();
        }

        // RVA: 0x13FFDD0（状态机 MoveNext: 0x1400B0C）
        private IEnumerator Start()
        {
            OzBillingJackPot.Initialize();
            AppsFlyerService.InilializeInstance();

            gameObject.AddComponent<NofiticationInit>();

            ResourceRequest request = Resources.LoadAsync<GameObject>("UIVersionControl/PanelVersionControl");
            yield return request;

            GameObject panel = Object.Instantiate((GameObject)request.asset);
            UIManager.AttachToLayer(panel, "POPUP");

            UIVersionControl ui = panel.AddComponent<UIVersionControl>();
            VersionControl vc = new VersionControl();
            ui.Init(vc, OnComplete);

            SpeedHackDetector.StartDetection(OnSpeedHackDetected);
        }

        /// <summary>
        /// 检测到加速器时弹出警告面板，点击按钮后重启游戏。
        /// </summary>
        // RVA: 0x13FFE6C（回调 lambda: 0x140092C）
        private void OnSpeedHackDetected()
        {
            AssetRef assetRef = ResourceManager.LoadSync("UIVersionControl/PanelWarning", typeof(GameObject));
            GameObject prefab = assetRef.Asset as GameObject;
            GameObject panel = Object.Instantiate(prefab);
            UIManager.AttachToLayer(panel, "LOADING");

            Button button = panel.transform.Find("ChoiceRoot").gameObject.transform
                .Find("Btn_Ok").GetComponent<Button>();
            button.onClick.AddListener(Instance.Restart);
        }

        // RVA: 0x14000B8
        private void HandleLogPrivate(string condition, string stackTrace, LogType type)
        {
        }

        /// <summary>版本检查完成后的初始化回调。</summary>
        // RVA: 0x14000BC
        private void OnComplete()
        {
            if (!AppConst.AssetBundleMode)
            {
                GrpcConnector grpcGate = NetworkManager.GrpcGate;
                grpcGate.LuaVersion = "";
            }

            Application.logMessageReceivedThreaded += HandleLogPrivate;

            NetworkManager.SetResVersion(VersionControl.StrVersion);

            KcAssetBundlesManifest manifest = VersionControl.Manifest != null
                ? new KcAssetBundlesManifest(VersionControl.Manifest)
                : null;

            hasVerUpdate = VersionControl.hasVerUpdate;
            isUpdateComplete = true;

            ResourceManager.Initialize(manifest);
            SoundManager.Initialize(UIManager.UICamera.gameObject);
            ClickEffect.Initialize();
            SqliteUtil.LoadSqlite();

            if (LuaMgr != null)
            {
                StartCoroutine(LuaMgr.StartMain());
            }
        }

        // RVA: 0x1400440
        public string GetVer()
        {
            if (!AppConst.AssetBundleMode)
            {
                return "0";
            }
            return "App" + Application.version + "\nRes" + VersionControl.StrVersion;
        }

        /// <summary>资源版本号（取自清单的 ResVersion）。</summary>
        // RVA: 0x1400504
        public string GetResVer()
        {
            if (!AppConst.AssetBundleMode)
            {
                return "0";
            }
            return VersionControl.Manifest.ResVersion.ToString();
        }

        // RVA: 0x1400658
        public string GetAppVer()
        {
            return Application.version;
        }

        /// <summary>
        /// 重启游戏：销毁自身、解绑日志、终止音频、重置音频配置、GC，
        /// 最后在主线程调度器中加载 0 号场景。
        /// </summary>
        // RVA: 0x1400660
        public void Restart()
        {
            Object.Destroy(gameObject);
            Application.logMessageReceivedThreaded -= HandleLogPrivate;
            AkSoundEngine.Term();
            AudioSettings.Reset(AudioSettings.GetConfiguration());
            System.GC.Collect();
            RedDotManager.Clear();
            Jackpot.MainThreadDispatcher.Send(RestartScene());
        }

        // RVA: 0x14007D8（状态机 MoveNext: 0x14009DC）
        private IEnumerator RestartScene()
        {
            yield return new WaitForEndOfFrame();
            SceneManager.LoadScene(0);
        }

        // RVA: 0x1400864
        public void DataRepair()
        {
            StoreUtil.DataRepair();
            Restart();
        }

        // RVA: 0x140088C
        public void DataRepairLight()
        {
            StoreUtil.DataRepairLight();
            Restart();
        }

        // RVA: 0x13F8B88
        public void Quit()
        {
            if (OzSDKManager.Instance != null)
            {
                OzSDKManager.Instance.Quit();
            }
        }

        // RVA: 0x14008B4
        public Launcher()
        {
        }

        // RVA: 0x14008BC
        static Launcher()
        {
        }
    }
}
