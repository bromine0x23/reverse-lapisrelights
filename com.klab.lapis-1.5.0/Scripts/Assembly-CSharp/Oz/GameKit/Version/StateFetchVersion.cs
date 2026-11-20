// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateFetchVersion
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System.Collections;
using Oz.GameFramework.Runtime;
using Oz.GameFramework.Runtime.Coroutines;
using UnityEngine;

namespace Oz.GameKit.Version
{
    /// <summary>拉取远端清单（版本流程起点，重试计数从 -1 开始累加）。</summary>
    public class StateFetchVersion : State<eProcedure>
    {
        private VersionControl m_VersionControl;
        private Coroutine m_Coroutine;
        private int m_RetryCount;

        // RVA: 0x1887504
        public StateFetchVersion(VersionControl versionControl) : base(eProcedure.FetchVersion)
        {
            m_RetryCount = -1;
            m_VersionControl = versionControl;
        }

        // RVA: 0x1887574
        public override void Enter(eProcedure previousState)
        {
            m_RetryCount++;
            if (m_VersionControl.onFetchVersionBegin != null)
            {
                m_VersionControl.onFetchVersionBegin();
            }
            m_Coroutine = CoroutineManager.StartCoroutine(Procedure());
        }

        // RVA: 0x1887650
        public override void Exit(eProcedure nextState)
        {
            if (m_Coroutine != null)
            {
                CoroutineManager.StopCoroutine(m_Coroutine);
            }
        }

        /// <summary>检查是否首次安装（GL 版新装判定）。</summary>
        // RVA: 0x1887664
        private void CheckGlNewInstall()
        {
            string savedVersion = PlayerPrefs.GetString("app_version");
            if (Application.version == savedVersion)
            {
                return;
            }

            KcAppSetting.Language[] languages = new KcAppSetting.Language[1];
            languages[0] = KcAppSetting.Language.JP;

            string soundBankPath = PathUtility.GetPersistentDataPath() + "SoundBank";
            if (Directory.Exists(soundBankPath))
            {
                Directory.Delete(soundBankPath, true);
            }

            for (int i = 0; i < languages.Length; i++)
            {
                string languagePath = PathUtility.GetPersistentDataPath() + languages[i].ToString();
                if (Directory.Exists(languagePath))
                {
                    Directory.Delete(languagePath, true);
                }
            }

            PlayerPrefs.SetString("app_version", Application.version);
            PlayerPrefs.Save();
        }
        // RVA: 0x18875E0（迭代器 MoveNext 0x1887B64）
        public IEnumerator Procedure()
        {
            Dispatcher.Instance.AddCSharpObserver(
                Dispatcher.EventType.OnFetchVersion,
                new Dispatcher.CshapreMessage(this, OnFetchVersionResponse));
            NetworkManager.GrpcGate.FetchVersion();
            yield break;
        }
        // RVA: 0x1887870
        private void OnFetchVersionResponse(bool success, object obj)
        {
            Dispatcher.Instance.RemoveCSharpObserver(Dispatcher.EventType.OnFetchVersion);

            if (success && obj is Game.VerManifestResponse response)
            {
                Debug.LogWarning(response.ResVer);

                VersionManifestKc manifest = VersionManifestKc.ReadFromString(response.ResVer);
                NetworkManager.GrpcGate.LuaVersion = response.MainResVer;

                if (manifest != null)
                {
                    KcAppSetting.SqliteKey1 = manifest.sqliteKey1;
                    KcAppSetting.SqliteKey2 = manifest.sqliteKey2;
                    KcAppSetting.SqliteKey3 = manifest.sqliteKey3;

                    if (m_VersionControl != null)
                    {
                        m_VersionControl.OnFetchVersionSuccess(manifest.resVersion);
                        return;
                    }
                }
            }

            if (m_VersionControl != null && m_VersionControl.onFetchVersionFailed != null)
            {
                m_VersionControl.onFetchVersionFailed();
            }
        }
    }
}
