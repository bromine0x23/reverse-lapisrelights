// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  TimelineController
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情时间线推进：跳过、自动播放、等待动画/语音/对话结束。
//  说明：Lua 表只还原了实际使用的 summary 键；其余键未在反汇编中出现。
// =============================================================================

using LuaInterface;
using Oz.Timeline;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class TimelineController : UIController
{
    public string summaryKey;
    public bool AutoPlaying;
    public bool AnimEnd;
    public bool SoundEnd;
    public bool DialogEnd;

    // RVA: 0x144E47C
    public override void RegistEvent()
    {
        base.RegistEvent();
        Kit.Events.OnClickSkip.AddEventListener(skip);
        Kit.Events.OnClickSkipAll.AddEventListener(skipAll);
        Kit.Events.OnCheckAuto.AddEventListener(auto);
        Kit.Events.VoiceChange.AddEventListener(voiceChange);
        Kit.Events.OnAwait.AddEventListener(dialogEnd);
        Kit.Events.AnimIdle.AddEventListener(animIdle);
        Kit.Events.OnRefreshDialogData.AddEventListener(dialogNext);
        Kit.Events.ToEnd.AddEventListener(toEnd);
    }

    // RVA: 0x144E80C
    public override void UnRegistEvent()
    {
        base.UnRegistEvent();
        Kit.Events.OnClickSkip.RemoveEventListener(skip);
        Kit.Events.OnClickSkipAll.RemoveEventListener(skipAll);
        Kit.Events.OnCheckAuto.RemoveEventListener(auto);
        Kit.Events.VoiceChange.RemoveEventListener(voiceChange);
        Kit.Events.OnAwait.RemoveEventListener(dialogEnd);
        Kit.Events.AnimIdle.RemoveEventListener(animIdle);
        Kit.Events.OnRefreshDialogData.RemoveEventListener(dialogNext);
        Kit.Events.ToEnd.RemoveEventListener(toEnd);
    }

    // RVA: 0x144EB9C
    public void toEnd(object obj)
    {
        if (Kit.Timelines.ToEnd())
        {
            return;
        }

        DialogController controller = Kit.UI.GetController<DialogController>();
        if (controller.currentDialog != null)
        {
            controller.currentDialog.RuntimeAwait = false;
        }

        controller = Kit.UI.GetController<DialogController>();
        Dialog data = controller.currentDialog.dialogData;
        if (data.behaviour == null || data.behaviour.context == null || data.behaviour.context.director == null)
        {
            return;
        }

        PlayableDirector director = data.behaviour.context.director;
        director.time = (director.playableAsset as TimelineAsset).duration - 0.5;
        director.Resume();
    }

    // RVA: 0x144EE0C
    private void skip(object obj)
    {
        if (Kit != null && Kit.Timelines.Skip())
        {
            return;
        }

        LuaTable table = Kit.Lua.GetEmptyTable();
        table.set_Item("summary", Kit.Language.Get(summaryKey));
        Kit.Lua.Call("ToEnd", table);
    }

    // RVA: 0x144EF94
    private void skipAll(object obj)
    {
        if (Kit != null && Kit.Timelines.IsReady())
        {
            return;
        }

        LuaTable table = Kit.Lua.GetEmptyTable();
        table.set_Item("summary", Kit.Language.Get(summaryKey));
        Kit.Lua.Call("ToEnd", table);
    }

    // RVA: 0x144F0EC
    private void auto(bool obj)
    {
        AutoPlaying = obj;
        if (!obj)
        {
            return;
        }

        if (AnimEnd && SoundEnd && DialogEnd)
        {
            Kit.Events.OnClickDialog.Dispatch(null);
            AnimEnd = false;
            SoundEnd = false;
            DialogEnd = false;
        }
        else
        {
            DialogController controller = Kit.UI.GetController<DialogController>();
            if (controller.currentDialog != null)
            {
                controller.currentDialog.RuntimeAwait = true;
            }
        }
    }

    // RVA: 0x144F208
    public void CheckAndContinue()
    {
        if (AutoPlaying && AnimEnd && SoundEnd && DialogEnd)
        {
            Kit.Events.OnClickDialog.Dispatch(null);
            AnimEnd = false;
            SoundEnd = false;
            DialogEnd = false;
        }
    }

    // RVA: 0x144F2A8
    private void voiceChange(bool plying)
    {
        DialogEnd = !plying;
        CheckAndContinue();
    }

    // RVA: 0x144F2B8
    private void animIdle(Animator obj)
    {
        foreach (GameObject actor in Kit.Actors.Actors)
        {
            Animator animator = actor.GetComponentInChildren<Animator>();
            if (animator != null && animator.gameObject.activeInHierarchy && !animator.GetBool("IdleState"))
            {
                AnimEnd = false;
                return;
            }
        }

        AnimEnd = true;
        CheckAndContinue();
    }

    // RVA: 0x144F4AC
    private void dialogEnd(TimeLine.Behaviour.Context obj)
    {
        if (obj == null)
        {
            return;
        }

        DialogBehaviour behaviour = obj.behaviour as DialogBehaviour;
        if (behaviour == null)
        {
            return;
        }

        Dialog data = behaviour.dialogData;
        if (data.video == null && !behaviour.videoPlayed)
        {
            DialogEnd = true;
        }
        if (string.IsNullOrEmpty(data.PlayVoice))
        {
            SoundEnd = true;
        }

        animIdle(null);
        CheckAndContinue();
    }

    // RVA: 0x144F5E4
    private void dialogNext(Dialog obj, float Percent = 0)
    {
        if (Percent < 1f)
        {
            DialogEnd = false;
        }
    }

    // RVA: 0x144F5F8
    public TimelineController()
    {
        summaryKey = string.Empty;
    }
}
