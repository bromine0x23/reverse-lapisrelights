// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.SoundModule.SoundManager
//  来源：Il2CppDumper 元数据（签名精确）；方法体待逐个还原，见 TODO.md
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using Oz.GameFramework.Runtime.Resource;
using Oz.GameFramework.Runtime;
using Oz.Utility;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Oz.Framework.SoundModule
{
    public class SoundManager : MonoBehaviour
    {
        private static AssetRef s_WwiseGlobalPrefab;
        private static GameObject s_WwiseGlobal;
        public static SoundManager Instance { get; set; }

        // RVA: 0x2EE5D40
        public static SoundManager get_Instance()
        {
            return Instance;
        }

        // RVA: 0x2EE5D90
        private static void set_Instance(SoundManager value)
        {
            Instance = value;
        }

        // RVA: 0x2EE5DE4
        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
            }
        }

        // RVA: 0x2EE5EC8
        private void OnDestroy()
        {
            AkCallbackManager.SetMonitoringCallback(AkMonitorErrorLevel.ErrorLevel_All, null);

            if (s_WwiseGlobalPrefab != null && s_WwiseGlobalPrefab.IsVaild)
            {
                ResourceManager.Unload(s_WwiseGlobalPrefab);
            }
            s_WwiseGlobalPrefab = null;

            if (s_WwiseGlobal != null)
            {
                Object.Destroy(s_WwiseGlobal);
                s_WwiseGlobal = null;
            }

            if (Instance != null)
            {
                Instance = null;
            }
        }

        // RVA: 0x2EE60A8
        private static void MonitoringCallback(
            AkMonitorErrorCode in_errorCode,
            AkMonitorErrorLevel in_errorLevel,
            uint in_playingID,
            ulong in_gameObjID,
            string in_msg)
        {
        }

        // RVA: 0x2EE60AC
        public static void Initialize(GameObject listenerRoot)
        {
            if (s_WwiseGlobalPrefab == null)
            {
                s_WwiseGlobalPrefab = ResourceManager.LoadSync(
                    "WwiseInitializer/WwiseGlobal", typeof(GameObject));
                s_WwiseGlobalPrefab.DontDisposeOnUnloadAll = true;
            }

            if (s_WwiseGlobal == null)
            {
                s_WwiseGlobal = GameObjectUtil.InstantiatePrefab(s_WwiseGlobalPrefab);
                AkCallbackManager.SetMonitoringCallback(
                    AkMonitorErrorLevel.ErrorLevel_All, MonitoringCallback);
            }

            if (listenerRoot != null)
            {
                listenerRoot.AddMissingComponent<AkGameObj>().isEnvironmentAware = false;
                listenerRoot.AddMissingComponent<AkAudioListener>();
            }
        }

        // RVA: 0x2EE6304
        public static void LoadBank(string name, bool decodeBank, bool saveDecodedBank)
        {
            if (!string.IsNullOrEmpty(name))
            {
                AkBankManager.LoadBank(name, decodeBank, saveDecodedBank);
            }
        }

        // RVA: 0x2EE63A4
        public static void LoadBankAsync(string name, AkCallbackManager.BankCallback callback)
        {
            if (!string.IsNullOrEmpty(name))
            {
                AkBankManager.LoadBankAsync(name, callback);
            }
        }

        // RVA: 0x2EE643C
        public static void UnloadBank(string name)
        {
            if (!string.IsNullOrEmpty(name))
            {
                AkBankManager.UnloadBank(name);
            }

            AkBankManager.DoUnloadBanks();
        }

        // RVA: 0x2EE64C8
        public static void DelayUnloadBank(string name, float delay)
        {
            if (Instance != null)
            {
                Instance.StartCoroutine(DelayUnloadBankInternal(name, delay));
            }
        }

        // RVA: 0x2EE65E8
        private static IEnumerator DelayUnloadBankInternal(string name, float delay)
        {
            yield return new WaitForSeconds(delay);
            AkBankManager.UnloadBank(name);
        }

        // RVA: 0x2EE6694
        public static void SetBGMVolume(float volume)
        {
            AKRESULT result = SetRTPCValue("VOL_BGM_MASTER", volume);
            AudioListener.volume = volume / 100f;

            if (result == AKRESULT.AK_Success)
            {
                PlayerPrefs.SetFloat("VOL_BGM_MASTER", volume);
            }
        }

        // RVA: 0x2EE67C8
        public static void SetMusicVolume(float volume)
        {
            AKRESULT result = SetRTPCValue("VOL_MUSIC_MASTER", volume);

            if (result == AKRESULT.AK_Success)
            {
                PlayerPrefs.SetFloat("VOL_MUSIC_MASTER", volume);
            }
        }

        // RVA: 0x2EE6860
        public static void SetSoundVolume(float volume)
        {
            AKRESULT result = SetRTPCValue("VOL_SE_MASTER", volume);

            if (result == AKRESULT.AK_Success)
            {
                PlayerPrefs.SetFloat("VOL_SE_MASTER", volume);
            }
        }

        // RVA: 0x2EE68E0
        public static void SetVoiceVolume(float volume)
        {
            AKRESULT result = SetRTPCValue("VOL_VOX_MASTER", volume);

            if (result == AKRESULT.AK_Success)
            {
                PlayerPrefs.SetFloat("VOL_VOX_MASTER", volume);
            }
        }

        // RVA: 0x2EE6960
        public static float GetBGMVolume()
        {
            return PlayerPrefs.GetFloat("VOL_BGM_MASTER", 100f);
        }

        // RVA: 0x2EE69B4
        public static float GetMusicVolume()
        {
            return PlayerPrefs.GetFloat("VOL_MUSIC_MASTER", 100f);
        }

        // RVA: 0x2EE6A08
        public static float GetSoundVolume()
        {
            return PlayerPrefs.GetFloat("VOL_SE_MASTER", 100f);
        }

        // RVA: 0x2EE6A5C
        public static float GetVoiceVolume()
        {
            return PlayerPrefs.GetFloat("VOL_VOX_MASTER", 100f);
        }

        // RVA: 0x2EE6AB0
        public static uint PostEvent(string eventName, GameObject gameObjectID)
        {
            if (string.IsNullOrEmpty(eventName))
            {
                return 0;
            }

            if (gameObjectID != null)
            {
                return AkSoundEngine.PostEvent(eventName, gameObjectID);
            }

            return AkSoundEngine.PostEvent(eventName, Instance.gameObject);
        }

        // RVA: 0x2EE6BF0
        public static uint PostEvent(uint eventID, GameObject gameObjectID)
        {
            if (gameObjectID != null)
            {
                return AkSoundEngine.PostEvent(eventID, gameObjectID);
            }

            return AkSoundEngine.PostEvent(eventID, Instance.gameObject);
        }

        // RVA: 0x2EE6D0C
        public static uint PostEvent(
            string eventName,
            GameObject gameObjectID,
            uint flags,
            AkCallbackManager.EventCallback callback,
            object cookie)
        {
            if (string.IsNullOrEmpty(eventName))
            {
                return 0;
            }

            if (gameObjectID != null)
            {
                return AkSoundEngine.PostEvent(eventName, gameObjectID, flags, callback, cookie);
            }

            return AkSoundEngine.PostEvent(
                eventName, Instance.gameObject, flags, callback, cookie);
        }

        // RVA: 0x2EE6E70
        public static uint PostEvent(
            uint eventID,
            GameObject gameObjectID,
            uint flags,
            AkCallbackManager.EventCallback callback,
            object cookie)
        {
            if (gameObjectID != null)
            {
                return AkSoundEngine.PostEvent(eventID, gameObjectID, flags, callback, cookie);
            }

            return AkSoundEngine.PostEvent(eventID, Instance.gameObject, flags, callback, cookie);
        }

        // RVA: 0x2EE6FAC
        public static int ExecuteActionOnEvent(string eventName, int actionType)
        {
            if (string.IsNullOrEmpty(eventName))
            {
                return (int)AKRESULT.AK_Fail;
            }

            return (int)AkSoundEngine.ExecuteActionOnEvent(eventName, (AkActionOnEventType)actionType);
        }

        // RVA: 0x2EE7048
        public static int ExecuteActionOnEvent(uint eventID, int actionType)
        {
            return (int)AkSoundEngine.ExecuteActionOnEvent(eventID, (AkActionOnEventType)actionType);
        }

        // RVA: 0x2EE70C0
        public static AKRESULT ExecuteActionOnEvent(string eventName, AkActionOnEventType actionType)
        {
            if (string.IsNullOrEmpty(eventName))
            {
                return AKRESULT.AK_Fail;
            }

            return AkSoundEngine.ExecuteActionOnEvent(eventName, actionType);
        }

        // RVA: 0x2EE715C
        public static AKRESULT ExecuteActionOnEvent(uint eventID, AkActionOnEventType actionType)
        {
            return AkSoundEngine.ExecuteActionOnEvent(eventID, actionType);
        }

        // RVA: 0x2EE71D4
        public static AKRESULT GetSourcePlayPosition(uint playingID, out int position)
        {
            return AkSoundEngine.GetSourcePlayPosition(playingID, out position);
        }

        // RVA: 0x2EE672C
        public static AKRESULT SetRTPCValue(string rtpcName, float value)
        {
            return AkSoundEngine.SetRTPCValue(rtpcName, value);
        }

        // RVA: 0x2EE724C
        public static AKRESULT SetRTPCValue(uint rtpcID, float value)
        {
            return AkSoundEngine.SetRTPCValue(rtpcID, value);
        }

        // RVA: 0x2EE72C4
        public static AKRESULT SetSwitch(
            uint in_switchGroup, uint in_switchState, GameObject in_gameObjectID)
        {
            return AkSoundEngine.SetSwitch(in_switchGroup, in_switchState, in_gameObjectID);
        }

        // RVA: 0x2EE7344
        public static AKRESULT SetSwitch(
            string in_pszSwitchGroup, string in_pszSwitchState, GameObject in_gameObjectID)
        {
            if (string.IsNullOrEmpty(in_pszSwitchGroup))
            {
                return AKRESULT.AK_Fail;
            }

            return AkSoundEngine.SetSwitch(in_pszSwitchGroup, in_pszSwitchState, in_gameObjectID);
        }

        // RVA: 0x2EE73E8
        public static AKRESULT SeekOnEvent(string eventName, float in_fPercent, GameObject gameObjectID)
        {
            if (string.IsNullOrEmpty(eventName))
            {
                return AKRESULT.AK_Fail;
            }

            if (gameObjectID != null)
            {
                return AkSoundEngine.SeekOnEvent(eventName, gameObjectID, in_fPercent);
            }

            return AkSoundEngine.SeekOnEvent(eventName, Instance.gameObject, in_fPercent);
        }

        // RVA: 0x2EE753C
        public static void StopAll()
        {
            AkSoundEngine.StopAll();
        }

        // RVA: 0x2EE759C
        public void .ctor()
        {
        }
    }
}
