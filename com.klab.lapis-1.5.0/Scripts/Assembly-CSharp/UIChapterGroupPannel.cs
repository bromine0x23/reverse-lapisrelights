// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  UIChapterGroupPannel
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：数字位图索引按反汇编的 /10、%10 逻辑还原。
// =============================================================================

using System.Collections.Generic;
using Oz.Framework.SoundModule;
using Spine;
using Spine.Unity;
using UnityEngine;
using UnityEngine.UI;

public class UIChapterGroupPannel : UIView
{
    public GameObject Number0;
    public GameObject Number1;
    public List<Sprite> numbers;
    public Text ChapterTitle;
    public string TitleKey;
    public int numberGroup;
    public SkeletonGraphic skeletonGraphic;
    public List<GameObject> listGo;

    // RVA: 0x19CCB30
    public override void Init()
    {
        base.Init();
        Number0.SetActive(true);
        Number1.SetActive(true);
        RefreshView();

        if (numberGroup >= 1 && skeletonGraphic != null)
        {
            skeletonGraphic.AnimationState.Complete += OnComplete;
        }
    }

    private void OnComplete(TrackEntry entry)
    {
        StartPlay();
    }

    // RVA: 0x19CCDD4
    private void StartPlay()
    {
        if (ScenarioKit.Instance.Blueprint != null && ScenarioKit.Instance.Blueprint.LoadComplate)
        {
            ScenarioKit.Instance.Blueprint.Play(null);
        }
        else
        {
            Invoke("StartPlay", 1f);
        }
    }

    // RVA: 0x19CCC60
    public void RefreshView()
    {
        if (numberGroup <= 9)
        {
            Number0.SetActive(false);
        }
        Number0.GetComponent<Image>().sprite = numbers[numberGroup / 10];
        Number1.GetComponent<Image>().sprite = numbers[numberGroup % 10];
        ChapterTitle.text = Kit.Language.Get(TitleKey);
    }

    // RVA: 0x19CCE74
    public void AnimatorEnd()
    {
        if (numberGroup >= 1 && skeletonGraphic != null)
        {
            skeletonGraphic.freeze = false;
        }

        foreach (GameObject item in listGo)
        {
            item.SetActive(false);
        }
        SoundManager.PostEvent("Play_SE_020_0053", gameObject);
    }

    // RVA: 0x19CCFE8
    public UIChapterGroupPannel()
    {
    }
}
