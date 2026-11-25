// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioEvents
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情流程事件信号集合；OnAwait/OnResume 转发 TimeLine.Event。
// =============================================================================

using System.Collections.Generic;
using Oz.Timeline;
using SeanLib.Core.Event;
using UnityEngine;

public class ScenarioEvents : Module
{
    public Signal<object> OnClickDialog;
    public Signal<Dialog, float> OnRefreshDialogData;
    public Signal<object> OnClickSkip;
    public Signal<object> OnClickSkipAll;
    public Signal<bool> OnCheckAuto;
    public Signal<bool> OnExit;
    public Signal<object> OnComplete;
    public Signal<Switch, List<Switch.Case>> OnSwitch;
    public Signal<Switch, List<Switch.Case>> OnShowSwitch;
    public Signal<Switch, Switch.Case> OnSelect;
    public Signal<Phone_SwitchController.LuaCase> OnSelectLua;
    public Signal<ScenarioSaveLoadData.CheckPoint> NewCheckPoint;
    public Signal<object> LoadAssetsComplate;
    public Signal<object> ToEnd;
    public Signal<bool> VoiceChange;
    public Signal<Animator> AnimIdle;

    public Signal<TimeLine.Behaviour.Context> OnAwait
    {
        // RVA: 0x1B79DA8
        get { return TimeLine.Event.Instace.OnAwait; }
    }

    public Signal<TimeLine.Behaviour.Context> OnResume
    {
        // RVA: 0x1B79DCC
        get { return TimeLine.Event.Instace.OnResume; }
    }

    // RVA: 0x1B7B194
    public ScenarioEvents()
    {
        OnClickDialog = new Signal<object>();
        OnRefreshDialogData = new Signal<Dialog, float>();
        OnClickSkip = new Signal<object>();
        OnClickSkipAll = new Signal<object>();
        OnCheckAuto = new Signal<bool>();
        OnExit = new Signal<bool>();
        OnComplete = new Signal<object>();
        OnSwitch = new Signal<Switch, List<Switch.Case>>();
        OnShowSwitch = new Signal<Switch, List<Switch.Case>>();
        OnSelect = new Signal<Switch, Switch.Case>();
        OnSelectLua = new Signal<Phone_SwitchController.LuaCase>();
        NewCheckPoint = new Signal<ScenarioSaveLoadData.CheckPoint>();
        LoadAssetsComplate = new Signal<object>();
        ToEnd = new Signal<object>();
        VoiceChange = new Signal<bool>();
        AnimIdle = new Signal<Animator>();
    }

    // RVA: 0x1B7B190
    public void ShowEvents()
    {
    }
}
