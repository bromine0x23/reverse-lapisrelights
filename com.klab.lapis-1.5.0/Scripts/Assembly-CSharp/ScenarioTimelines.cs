// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioTimelines
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：GoTo/IsReady/PauseAll/GetDialog 按反汇编还原；
//        Skip/ToEnd/ToNextSwitch 的分支结构按反汇编重建。
// =============================================================================

using System.Collections.Generic;
using Oz.Timeline;
using UnityEngine.Playables;

public class ScenarioTimelines : Module
{
    public List<ScenarioTrackRef> ScenarioLines;
    private DialogController _dialogControl;

    public DialogController dialogControl
    {
        // RVA: 0x1941F0C
        get
        {
            if (_dialogControl == null)
            {
                _dialogControl = Kit.UI.GetController<DialogController>();
            }
            return _dialogControl;
        }
    }

    // RVA: 0x1941B68
    public void RefreshCache()
    {
        foreach (ScenarioTrackRef line in ScenarioLines)
        {
            List<ScenarioClip> dialogs = line.Dialogs;
        }
    }

    // RVA: 0x1941C40
    public Dialog GetDialog(PlayableDirector director, string dialogId)
    {
        ScenarioTrackRef line = ScenarioLines.Find(x => x.director == director);
        if (line != null)
        {
            return line.GetDialog(dialogId);
        }
        return null;
    }

    // RVA: 0x1941E40
    public ScenarioTrackRef GetTimeline(string TimelineName)
    {
        return ScenarioLines.Find(x => x.director.name == TimelineName);
    }

    // RVA: 0x1941FBC
    public void PauseAll()
    {
        foreach (ScenarioTrackRef line in ScenarioLines)
        {
            if (line.director.time > 0.0)
            {
                line.director.Pause();
            }
        }
    }

    // RVA: 0x19420E8
    public void GoTo(string TimelineName, string ClipId, bool toEnd = false)
    {
        ScenarioTrackRef line = GetTimeline(TimelineName);
        if (line == null)
        {
            return;
        }

        PauseAll();
        if (line.director.time == 0.0)
        {
            line.director.Play();
        }

        Dialog dialog = line.Dialogs.Find(x => x.name == ClipId) as Dialog;
        if (dialog == null)
        {
            return;
        }

        line.PlayOrResume();
        if (dialog.clipInfo != null)
        {
            line.director.time = toEnd ? dialog.clipInfo.end + 0.01 : dialog.clipInfo.start;
        }
    }

    // RVA: 0x19425E4
    public bool IsReady()
    {
        DialogController control = dialogControl;
        if (control == null || control.currentDialog == null || control.currentDialog.dialogData == null)
        {
            return false;
        }

        Dialog data = control.currentDialog.dialogData;
        if (data.behaviour == null || data.behaviour.context == null)
        {
            return false;
        }

        PlayableDirector director = data.behaviour.context.director;
        return ScenarioLines.Find(x => x.director == director) != null;
    }

    // RVA: 0x19427C0
    public bool Skip()
    {
        DialogController control = dialogControl;
        if (control == null || control.currentDialog == null || !IsReady())
        {
            return false;
        }

        Dialog current = control.currentDialog.dialogData;
        Dialog next = ToNextSwitch(current, new List<Dialog>());
        if (next == null)
        {
            return false;
        }

        control.currentDialog.RuntimeAwait = false;
        PlayableDirector director = control.currentDialog.context.director;
        director.time = next.clipInfo.start;
        if (director.time > 0.0)
        {
            director.Resume();
        }
        else
        {
            director.Play();
        }
        Kit.Sounds.StopVoice();
        return true;
    }

    // RVA: 0x194356C
    public bool ToEnd()
    {
        DialogController control = dialogControl;
        if (control == null || control.currentDialog == null || control.currentDialog.dialogData == null)
        {
            return false;
        }

        Dialog data = control.currentDialog.dialogData;
        if (data.behaviour == null || data.behaviour.context == null || data.behaviour.context.director == null)
        {
            return false;
        }

        PlayableDirector director = data.behaviour.context.director;
        List<Dialog> dialogs = new List<Dialog>();
        Dialog next = ToNextSwitch(data, dialogs);
        if (next == null)
        {
            return false;
        }

        if (next.clipInfo.end <= director.time)
        {
            director.time = next.clipInfo.end - 0.25;
        }
        if (director.time > 0.0)
        {
            director.Resume();
        }
        else
        {
            director.Play();
        }
        return true;
    }

    // RVA: 0x1942D44
    private Dialog ToNextSwitch(Dialog current, List<Dialog> dialogs)
    {
        if (current == null)
        {
            return null;
        }

        bool found = false;
        foreach (ScenarioTrackRef line in ScenarioLines)
        {
            foreach (ScenarioClip clip in line.Dialogs)
            {
                Dialog dialog = clip as Dialog;
                if (dialog == null)
                {
                    continue;
                }

                if (!found)
                {
                    if (dialog == current)
                    {
                        found = true;
                    }
                    continue;
                }

                if (dialog.Flag.HasFlag(flag.end) || dialog.Flag.HasFlag(flag.noSkip))
                {
                    dialogs.Add(dialog);
                    return dialog;
                }
                dialogs.Add(dialog);
            }
        }
        return null;
    }

    // RVA: 0x1943A7C
    public override void Dispose()
    {
        base.Dispose();
        _dialogControl = null;
    }

    // RVA: 0x1943B08
    public ScenarioTimelines()
    {
        ScenarioLines = new List<ScenarioTrackRef>();
    }
}
