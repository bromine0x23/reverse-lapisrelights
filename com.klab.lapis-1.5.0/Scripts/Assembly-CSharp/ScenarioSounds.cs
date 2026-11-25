// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioSounds
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情音效/语音/BGM 管理，底层转发到 SoundManager 与 Wwise。
// =============================================================================

using System.Collections.Generic;
using Oz.ActorModule;
using Oz.Framework.SoundModule;
using UnityEngine;

public class ScenarioSounds : Module
{
    public List<string> Banks;
    private string Voice;
    private string BGM;
    private Dictionary<string, uint> playingIDs;

    // RVA: 0x193E364
    public override void Init()
    {
        base.Init();
        LoadBanks();
    }

    // RVA: 0x193E38C
    public void LoadBanks()
    {
        foreach (string bank in Banks)
        {
            SoundManager.LoadBank(bank, false, false);
        }
    }

    // RVA: 0x193E480
    public override void Dispose()
    {
        base.Dispose();
        foreach (string bank in Banks)
        {
            SoundManager.UnloadBank(bank);
        }
    }

    // RVA: 0x193E578
    public override void RegistEvent()
    {
        base.RegistEvent();
        AkCallbackManager.SetMonitoringCallback((AkMonitorErrorLevel)2, scenarioSoundCB);
    }

    // RVA: 0x193E61C
    public override void UnRegistEvent()
    {
        base.UnRegistEvent();
        AkCallbackManager.SetMonitoringCallback((AkMonitorErrorLevel)2, null);
    }

    // RVA: 0x193E694
    private void scenarioSoundCB(
        AkMonitorErrorCode in_errorCode,
        AkMonitorErrorLevel in_errorLevel,
        uint in_playingID,
        ulong in_gameObjID,
        string in_msg)
    {
        Voice = string.Empty;
        VoiceChange();
    }

    // RVA: 0x193E778
    public void StopAll()
    {
        AkSoundEngine.StopAll();
        playingIDs.Clear();
        Voice = string.Empty;
        VoiceChange();
    }

    // RVA: 0x193E818
    public void Pause(string EventName)
    {
        SoundManager.ExecuteActionOnEvent(EventName, 1);
    }

    // RVA: 0x193E828
    public void Resume(string EventName)
    {
        SoundManager.ExecuteActionOnEvent(EventName, 2);
    }

    // RVA: 0x193E838
    public void Play(string EventName)
    {
        SoundManager.PostEvent(EventName, gameObject);
    }

    // RVA: 0x193E868
    public void Play(string EventName, AkCallbackManager.EventCallback callback, object cookie)
    {
        uint playingID = SoundManager.PostEvent(EventName, gameObject, 0x100005, callback, cookie);
        playingIDs.Add(EventName, playingID);
    }

    // RVA: 0x193E914
    public void Stop(string EventName)
    {
        if (string.IsNullOrEmpty(EventName))
        {
            return;
        }

        SoundManager.ExecuteActionOnEvent(EventName, 0);
        if (playingIDs.ContainsKey(EventName))
        {
            playingIDs.Remove(EventName);
        }
    }

    // RVA: 0x193E9CC
    public void PostEvent(string EventName)
    {
        SoundManager.PostEvent(EventName, gameObject);
    }

    // RVA: 0x193E9FC
    public void PlayBGM(string EventName)
    {
        if (BGM == EventName)
        {
            return;
        }

        BGM = EventName;
        SoundManager.PostEvent(EventName, gameObject);
        BGM = EventName;
    }

    // RVA: 0x193EA50
    public void GetPosition(string EventName, out int position)
    {
        position = 0;
        if (playingIDs.ContainsKey(EventName))
        {
            SoundManager.GetSourcePlayPosition(playingIDs[EventName], out position);
        }
    }

    // RVA: 0x193EAFC
    public void PlayVoice(string EventName)
    {
        if (Voice == EventName)
        {
            return;
        }
        if (!string.IsNullOrEmpty(Voice))
        {
            StopVoice();
        }

        SoundManager.PostEvent(EventName, gameObject, 1, voiceend, EventName);
        Voice = EventName;
        VoiceChange();
    }

    // RVA: 0x193EDBC
    private void voiceend(object in_cookie, AkCallbackType in_type, AkCallbackInfo in_info)
    {
        if (Kit != null)
        {
            if (Voice == in_cookie as string)
            {
                Voice = string.Empty;
            }
            VoiceChange();
        }
    }

    // RVA: 0x193EBE8
    public void StopVoice()
    {
        Stop(Voice);
        Voice = string.Empty;
        VoiceChange();

        if (Kit != null && Kit.Actors != null)
        {
            foreach (Actor actor in Kit.Actors.Actors)
            {
                ExpressionAnimator animator = actor.GetComponentInChildren<ExpressionAnimator>();
                if (animator != null && animator.Voice != null)
                {
                    animator.Voice.ResetVowelInfo();
                    animator.Voice.ResetVowel();
                }
            }
        }
    }

    // RVA: 0x193E6F0
    public void VoiceChange()
    {
        Kit.Events.VoiceChange.Dispatch(!string.IsNullOrEmpty(Voice));
    }

    // RVA: 0x193EEA8
    public ScenarioSounds()
    {
        Banks = new List<string>();
        Voice = string.Empty;
        BGM = string.Empty;
        playingIDs = new Dictionary<string, uint>();
    }
}
