// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Switch
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情分支片段：为每个分支克隆 Case，并构建 SwitchBehaviour。
// =============================================================================

using System;
using System.Collections.Generic;
using Cinemachine;
using Oz.Timeline;
using UnityEngine;
using UnityEngine.Playables;

[Serializable]
public class Switch : ScenarioClip
{
    public string NameKey;
    public List<Switch.Case> Cases;
    public SceneReference PriorityCamera;

    // RVA: 0x1ACCD54
    public override Playable CreatePlayable(PlayableGraph graph, GameObject go)
    {
        ScriptPlayable<SwitchBehaviour> playable = ScriptPlayable<SwitchBehaviour>.Create(graph, go, 0);
        SwitchBehaviour behaviour = playable.GetBehaviour();

        behaviour.cases = new List<Switch.Case>(Cases.Count);
        for (int i = 0; i < Cases.Count; i++)
        {
            Switch.Case caseData = Cases[i].Clone();
            caseData.behaviour = behaviour;
            caseData._timeline = caseData.timeline.Resolve<PlayableDirector>();
            behaviour.cases.Add(caseData);
        }

        if (PriorityCamera != null)
        {
            behaviour.PriortyCamera = PriorityCamera.Resolve<CinemachineVirtualCamera>();
        }

        SetContext(behaviour);
        return playable;
    }

    // RVA: 0x1ACD01C
    public Switch()
    {
        NameKey = "[USER_NAME]";
        Cases = new List<Switch.Case>();
    }

    [Serializable]
    public class Case
    {
        public string CaseKey;
        public SceneReference timeline;
        [HideInInspector]
        public PlayableDirector _timeline;
        [HideInInspector]
        public SwitchBehaviour behaviour;
        public string GotoDialogID;
        public bool Selected;
        public string PrizeId;

        // RVA: 0x1ACCF90
        public Case Clone()
        {
            return MemberwiseClone() as Switch.Case;
        }

        // RVA: 0x1ACD09C
        public Case()
        {
        }
    }
}
