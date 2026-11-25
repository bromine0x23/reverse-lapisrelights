// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioTrackRef
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  单条剧情时间线的轨道引用与对话缓存。
// =============================================================================

using System.Collections.Generic;
using Cinemachine;
using Oz.Timeline;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using TimeLine;

public class ScenarioTrackRef
{
    public PlayableDirector director;
    public DialogTack DialogLine;
    public ScenarioTack ControlLine;
    public ScenarioTack SoundTrack;
    public RefControlTrack EffectTrack;
    public CinemachineTrack CameraTrack;
    private List<ScenarioClip> _dialogs;

    public List<ScenarioClip> Dialogs
    {
        // RVA: 0x19422AC
        get
        {
            if (_dialogs.Count == 0)
            {
                foreach (TimelineClip clip in DialogLine.GetClips())
                {
                    ScenarioClip dialog = clip.asset as ScenarioClip;
                    if (dialog != null)
                    {
                        _dialogs.Add(dialog);
                    }
                }
            }
            return _dialogs;
        }
    }

    // RVA: 0x1941D2C
    public Dialog GetDialog(string dialogId)
    {
        return Dialogs.Find(x => x.name == dialogId) as Dialog;
    }

    // RVA: 0x1942594
    public void PlayOrResume()
    {
        if (director.time > 0.0)
        {
            director.Resume();
        }
        else
        {
            director.Play();
        }
    }

    // RVA: 0x1943E18
    public ScenarioTrackRef()
    {
        _dialogs = new List<ScenarioClip>();
    }
}
