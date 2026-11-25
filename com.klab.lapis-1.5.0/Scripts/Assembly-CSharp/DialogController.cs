// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  DialogController
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  对话推进、语音口型、历史记录与检查点处理。
//  说明：主体逻辑按反汇编还原；历史行/检查点的字段名来自同类数据结构推断。
// =============================================================================

using Oz.ActorModule;
using Oz.Timeline;
using UnityEngine;

public class DialogController : UIController
{
    public DialogBehaviour currentDialog;
    public TimeLine.Behaviour awatingBehaviour;
    public string DialogText;
    public string ClickSound;

    // RVA: 0x1742F28
    public override void RegistEvent()
    {
        base.RegistEvent();
        ScenarioKit.Instance.Events.OnAwait.AddEventListener(OnTimelineAwating);
        ScenarioKit.Instance.Events.OnClickDialog.AddEventListener(ToNextDialog);
    }

    // RVA: 0x1743058
    public override void UnRegistEvent()
    {
        ScenarioKit.Instance.Events.OnAwait.RemoveEventListener(OnTimelineAwating);
        ScenarioKit.Instance.Events.OnClickDialog.RemoveEventListener(ToNextDialog);
    }

    // RVA: 0x174317C
    private void OnTimelineAwating(TimeLine.Behaviour.Context obj)
    {
        awatingBehaviour = obj.behaviour;
    }

    // RVA: 0x1743198
    public virtual void OnDialogStart(DialogBehaviour Behaviour)
    {
        if (Behaviour == null || Behaviour.dialogData == null)
        {
            return;
        }

        Debug.Log("OnDialogStart:" + Behaviour.dialogData.Textkey);

        Dialog data = Behaviour.dialogData;
        Kit.Events.OnRefreshDialogData.Dispatch(data, -1f);

        if (!Application.isPlaying)
        {
            return;
        }

        if (ScenarioKit.Instance != null)
        {
            foreach (GameObject actor in ScenarioKit.Instance.Actors.Actors)
            {
                ExpressionAnimator animator = actor.GetComponentInChildren<ExpressionAnimator>();
                if (animator.LipSyncVoice != null)
                {
                    animator.LipSyncVoice.OnEnd();
                }
            }

            string text = Kit.Language.Get(data.Textkey);
            if (ScenarioKit.Instance.UI.DialogPanel != null)
            {
                ScenarioKit.Instance.UI.DialogPanel.gameObject.SetActive(true);
                ScenarioKit.Instance.UI.DialogPanel.DialogView.Text = string.Empty;
                if (text.Length == 0)
                {
                    ScenarioKit.Instance.UI.DialogPanel.gameObject.SetActive(false);
                    Behaviour.RuntimeAwait = false;
                }
            }

            if (ScenarioKit.Instance.UI.History != null)
            {
                string body = Kit.Language.Get(data.Textkey).Trim();
                string name = Kit.Language.Get(data.NameKey).Trim();
                if (body.Length > 0 || name.Length > 0)
                {
                    HistoryLine.Data line = new HistoryLine.Data();
                    line.actorId = data.ActorId;
                    line.actorName = data.NameKey;
                    line.Txt = data.Textkey;
                    line.vol = data.PlayVoice;
                    line.strIcon = data.StrHeadIcon;
                    ScenarioKit.Instance.UI.History.AddData(line);
                }
            }
        }

        if (!string.IsNullOrEmpty(data.CallStart))
        {
            ScenarioKit.Instance.Lua.Call(data.CallStart);
        }
    }

    // RVA: 0x17436C4
    public virtual void OnDialogPlay(DialogBehaviour Behaviour)
    {
        currentDialog = Behaviour;
        if (Behaviour == null)
        {
            return;
        }

        Dialog data = Behaviour.dialogData;
        Kit.Events.OnRefreshDialogData.Dispatch(data, 0f);

        if (!string.IsNullOrEmpty(data.PlayVoice) && !string.IsNullOrEmpty(data.Textkey))
        {
            GameObject actor = ScenarioKit.Instance.Actors.GetActor(data.NameKey);
            if (actor != null)
            {
                ExpressionAnimator animator = actor.GetComponentInChildren<ExpressionAnimator>();
                if (animator.LipSyncVoice != null)
                {
                    animator.LipSyncVoice.SetData(data.PlayVoice);
                }
            }
            ScenarioKit.Instance.Sounds.PlayVoice(data.PlayVoice);
        }

        if (data.Flag == flag.input)
        {
            return;
        }

        ScenarioSaveLoadData.CheckPoint checkPoint = new ScenarioSaveLoadData.CheckPoint();
        checkPoint.Line = Behaviour.context.director.gameObject.name;
        checkPoint.DialogID = data.clipInfo.displayName;
        checkPoint.flag = (int)data.Flag;
        checkPoint.TextKey = data.Textkey;
        checkPoint.Actorid = data.ActorId;
        Kit.Events.NewCheckPoint.Dispatch(checkPoint);

        if (!Behaviour.video0Played && data.video0 != null)
        {
            Behaviour.video0Played = true;
            TimeLine.Event.Instace.OnAwait.Dispatch(Behaviour.context);
        }
        if (!Behaviour.videoPlayed && data.video != null)
        {
            Behaviour.videoPlayed = true;
        }
    }

    // RVA: 0x1743A14
    public virtual void OnDialogEnd(DialogBehaviour Behaviour)
    {
        if (Behaviour == null || Behaviour.dialogData == null)
        {
            return;
        }

        Dialog data = Behaviour.dialogData;
        if (data.Flag.HasFlag(flag.end))
        {
            ScenarioKit.Instance.Events.OnComplete.Dispatch(null);
        }
        if (!string.IsNullOrEmpty(data.CallEnd))
        {
            ScenarioKit.Instance.Lua.Call(data.CallEnd);
        }
    }

    // RVA: 0x1743B24
    protected virtual void ToNextDialog(object arg)
    {
        if (currentDialog == null)
        {
            return;
        }
        if (!currentDialog.Await && currentDialog.dialogData.IgnoreSkip)
        {
            return;
        }
        if (currentDialog.Time01 < 0.1f)
        {
            return;
        }

        Kit.Sounds.Play(ClickSound);

        if (currentDialog.Await)
        {
            if (awatingBehaviour != null)
            {
                TimeLine.Event.Instace.ResumeAwaiting(awatingBehaviour.context);
            }
        }
        else
        {
            TimeLine.Behaviour.Context context = currentDialog.context;
            context.director.time = context.clip.clipInfo.end - 0.1;
            Kit.Events.OnRefreshDialogData.Dispatch(currentDialog.dialogData, 1f);
        }
    }

    // RVA: 0x1743CCC
    public void Next()
    {
        TimeLine.Behaviour.Context context = currentDialog.context;
        context.director.time = context.clip.clipInfo.end - 0.1;
    }

    // RVA: 0x1743D2C
    public override void Dispose()
    {
        base.Dispose();
        currentDialog = null;
        awatingBehaviour = null;
    }

    // RVA: 0x1743D54
    public DialogController()
    {
        DialogText = string.Empty;
        ClickSound = "PLAY_SE_110_0001";
    }
}
