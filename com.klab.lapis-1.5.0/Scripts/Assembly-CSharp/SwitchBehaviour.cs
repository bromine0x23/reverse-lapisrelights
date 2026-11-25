// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  SwitchBehaviour
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  分支片段的运行时行为：无选中分支时停止语音、结束口型、派发 OnSwitch
//  并暂停时间线；无论是否选中都恢复优先相机。
// =============================================================================

using System.Collections.Generic;
using Cinemachine;
using Oz.ActorModule;
using Oz.Timeline;
using UnityEngine;
using UnityEngine.Playables;

public class SwitchBehaviour : ScenarioBehaviour
{
    public CinemachineVirtualCamera PriortyCamera;
    public List<Switch.Case> cases;

    public override bool Await
    {
        // RVA: 0x1ACD0A4
        get { return false; }
    }

    // RVA: 0x1ACD0AC
    public override void OnPlayableDestroy(Playable playable)
    {
        base.OnPlayableDestroy(playable);
        PriortyCamera = null;
        cases = null;
    }

    // RVA: 0x1ACD0D4
    public override void OnSecoundFrame(Playable playable, FrameData info, object playerData)
    {
        if (context.state != TimeLine.Behaviour.InternalState.Play)
        {
            return;
        }

        if (!context.director)
        {
            return;
        }

        bool selected = false;
        foreach (Switch.Case item in cases)
        {
            selected |= item.Selected;
        }

        if (!selected)
        {
            if (!Application.isPlaying)
            {
                return;
            }

            ScenarioKit.Instance.Sounds.StopVoice();

            foreach (Actor actor in ScenarioKit.Instance.Actors.Actors)
            {
                ExpressionAnimator expressionAnimator = actor.GetComponentInChildren<ExpressionAnimator>();
                if (expressionAnimator && expressionAnimator.LipSyncVoice)
                {
                    expressionAnimator.LipSyncVoice.OnEnd();
                }
            }

            ScenarioKit.Instance.Events.OnSwitch.Dispatch(context.clip as Switch, cases);
            context.director.Pause();
        }

        if (PriortyCamera)
        {
            ScenarioKit.Instance.Cameras.Priority(PriortyCamera);
        }
    }

    // RVA: 0x1ACD48C
    public SwitchBehaviour()
    {
    }
}
