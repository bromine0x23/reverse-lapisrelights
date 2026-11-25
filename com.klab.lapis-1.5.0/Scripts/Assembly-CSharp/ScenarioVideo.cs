// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioVideo
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情视频：等待时间线到点后播放，结束后恢复时间线。
// =============================================================================

using Oz.Timeline;
using TimeLine;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;

public class ScenarioVideo : UIView
{
    public VideoPlayer player;
    public RenderTexture rt;

    // RVA: 0x1947054
    public override void Init()
    {
        base.Init();
        Event.Instace.OnAwait.AddEventListener(OnAwait);
    }

    // RVA: 0x1947108
    private void OnAwait(Behaviour.Context obj)
    {
        if (obj == null)
        {
            return;
        }

        Dialog data = obj.clip as Dialog;
        if (data == null || data.behaviour == null)
        {
            return;
        }

        if (data.behaviour.Time01 > 0.5f)
        {
            if (data.video != null)
            {
                Kit.Sounds.StopAll();
                Play(data.video);
            }
        }
        else if (data.video0 != null)
        {
            Kit.Sounds.StopAll();
            Play(data.video0);
        }
    }

    // RVA: 0x1947404
    public override void Dispose()
    {
        Event.Instace.OnAwait.RemoveEventListener(OnAwait);
        base.Dispose();
    }

    // RVA: 0x1947298
    public void Play(VideoClip clip)
    {
        if (rt == null)
        {
            rt = new RenderTexture(1280, 720, 0);
        }

        RawImage image = GetComponentInChildren<RawImage>();
        image.texture = rt;
        player.targetTexture = rt;
        player.clip = clip;
        player.loopPointReached += loopReached;
        gameObject.SetActive(true);
        player.Play();
    }

    // RVA: 0x19474B8
    private void loopReached(VideoPlayer source)
    {
        Event.Instace.ResumeAll();
        gameObject.SetActive(false);
        if (rt != null)
        {
            Object.Destroy(rt);
        }
    }

    // RVA: 0x19475A0
    public void Stop()
    {
        player.Stop();
        loopReached(player);
    }

    // RVA: 0x19475D4
    public ScenarioVideo()
    {
    }
}
