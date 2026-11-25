// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  UIDialogPannel
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  对话面板：刷新文本、逐字显示与点击推进。
// =============================================================================

using Jigbox.Components;
using Oz.Timeline;
using UnityEngine;
using UnityEngine.UI;

public class UIDialogPannel : UIView
{
    public GameObject LeftRoot;
    public GameObject MarkLeft;
    public Text NameLeft;
    public Text DialogLeft;
    public TextView DialogView;
    public string DialogText;
    private float CurrentPercent;

    // RVA: 0x19D0E0C
    public override void RegistEvent()
    {
        base.RegistEvent();
        Kit.Events.OnRefreshDialogData.AddEventListener(RefreshData);
    }

    // RVA: 0x19D0ECC
    public override void UnRegistEvent()
    {
        base.UnRegistEvent();
        Kit.Events.OnRefreshDialogData.RemoveEventListener(RefreshData);
    }

    // RVA: 0x19D0F8C
    private void RefreshData(Dialog obj, float Percent = 0)
    {
        DialogText = Kit.Language.Get(obj.Textkey);
        NameLeft.text = Kit.Language.Get(obj.NameKey);
        CurrentPercent = Percent;

        if (CurrentPercent >= 1f)
        {
            RefreshView();
        }
    }

    // RVA: 0x19D12D0
    private void Update()
    {
        if (CurrentPercent < 1f)
        {
            RefreshView();
        }
    }

    // RVA: 0x19D1058
    private void RefreshView()
    {
        if (CurrentPercent < 0f)
        {
            if (DialogView != null)
            {
                DialogView.Text = DialogText;
                DialogView.VisibleLength = 0;
            }
            return;
        }

        CurrentPercent += Time.deltaTime * 0.5f;
        int length = Mathf.Clamp((int)(CurrentPercent * DialogText.Length), 0, DialogText.Length);

        if (DialogLeft != null)
        {
            DialogLeft.text = DialogText.Substring(0, length);
        }
        if (DialogView != null)
        {
            DialogView.Text = DialogText;
            DialogView.VisibleLength = length;
        }
        if (MarkLeft != null)
        {
            MarkLeft.SetActive(CurrentPercent >= 0.98f);
        }
    }

    // RVA: 0x19D12E8
    public virtual void OnClickDialog()
    {
        ScenarioKit.Instance.Events.OnClickDialog.Dispatch(this);
    }

    // RVA: 0x19D1358
    public UIDialogPannel()
    {
        DialogText = string.Empty;
    }
}
