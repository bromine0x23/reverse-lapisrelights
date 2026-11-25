// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  UIChapterPannel
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  说明：数字位图索引按反汇编的 /10、%10 逻辑还原。
// =============================================================================

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIChapterPannel : UIView
{
    public GameObject Number0;
    public GameObject Number1;
    public List<Sprite> numbers;
    public Text ChapterTitle;
    public string TitleKey;
    public int number0;
    public int number1;
    public List<GameObject> listTitleNum;

    // RVA: 0x19CD088
    public override void Init()
    {
        base.Init();
        RefreshView();
    }

    // RVA: 0x19CD490
    public void HideTitleNum()
    {
        foreach (GameObject item in listTitleNum)
        {
            item.SetActive(false);
        }

        RectTransform rect = ChapterTitle.rectTransform;
        rect.anchoredPosition = new Vector2(rect.anchoredPosition.x, 20f);
    }

    // RVA: 0x19CD0B0
    public void RefreshView()
    {
        if (number0 <= 9)
        {
            Number0.transform.GetChild(0).gameObject.SetActive(false);
        }
        Number0.GetComponent<Renderer>().enabled = false;
        Number0.transform.GetChild(0).GetComponent<Image>().sprite = numbers[number0 / 10];
        Number0.transform.GetChild(1).GetComponent<Image>().sprite = numbers[number0 % 10];

        if (number1 <= 9)
        {
            Number1.transform.GetChild(0).gameObject.SetActive(false);
        }
        Number1.transform.GetChild(0).GetComponent<Image>().sprite = numbers[number1 / 10];
        Number1.transform.GetChild(1).GetComponent<Image>().sprite = numbers[number1 % 10];

        ChapterTitle.text = Kit.Language.Get(TitleKey);
    }

    // RVA: 0x19CD5F4
    public UIChapterPannel()
    {
    }
}
