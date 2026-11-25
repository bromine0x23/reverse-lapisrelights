// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  UIHistory
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

public class UIHistory : UIView
{
    public HistoryDisplay display;
    public List<HistoryLine.Data> Datas;

    // RVA: 0x1720C40
    public void AddData(HistoryLine.Data data)
    {
        if (Datas.Exists(x => x.Txt == data.Txt))
        {
            return;
        }
        if (string.IsNullOrEmpty(ScenarioKit.Instance.Language.Get(data.Txt)))
        {
            return;
        }
        Datas.Add(data);
    }

    // RVA: 0x1720D70
    public void Refresh()
    {
        display.RefreshView(Datas);
    }

    // RVA: 0x1720D94
    public void Show(bool show)
    {
        if (show)
        {
            Refresh();
        }
        gameObject.SetActive(show);
    }

    // RVA: 0x1720DDC
    public UIHistory()
    {
        Datas = new List<HistoryLine.Data>();
    }
}
