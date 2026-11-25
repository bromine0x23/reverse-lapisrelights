// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  UISwitchPannel
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

public class UISwitchPannel : UIView
{
    public List<UICase> Cases;
    public UICase Prefab;

    // RVA: 0x1E0567C
    public override void RegistEvent()
    {
        base.RegistEvent();
        Kit.Events.OnShowSwitch.AddEventListener(RefreshView);
    }

    // RVA: 0x1E0573C
    public override void UnRegistEvent()
    {
        base.UnRegistEvent();
        Kit.Events.OnShowSwitch.RemoveEventListener(RefreshView);
    }

    // RVA: 0x1E057FC
    public void RefreshView(Switch option, List<Switch.Case> datas)
    {
        gameObject.SetActive(true);
        ScenarioKit.Instance.UI.DialogPanel.gameObject.SetActive(false);

        int count = datas.Count - Cases.Count;
        for (int i = 0; i < count; i++)
        {
            UICase item = Object.Instantiate(Prefab);
            item.transform.SetParent(Prefab.transform.parent);
            item.transform.localScale = Prefab.transform.localScale;
            Cases.Add(item);
        }

        for (int i = 0; i < Cases.Count; i++)
        {
            Cases[i].gameObject.SetActive(false);
        }

        for (int i = 0; i < datas.Count; i++)
        {
            Cases[i].RefreshView(option, datas[i]);
            Cases[i].gameObject.SetActive(true);
        }
    }

    // RVA: 0x1E05BEC
    public UISwitchPannel()
    {
        Cases = new List<UICase>();
    }
}
