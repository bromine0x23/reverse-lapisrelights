// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  UICase
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  剧情选项列表项：显示选项文本，点击时派发 OnSelect。
// =============================================================================

using Jigbox.Components;
using UnityEngine.UI;

public class UICase : UIView
{
    public Text text;
    public TextView textView;
    private Switch.Case cache;
    private Switch option;

    // RVA: 0x19CC950
    public void RefreshView(Switch option, Switch.Case caseData)
    {
        cache = caseData;
        this.option = option;

        if (text)
        {
            text.text = ScenarioKit.Instance.Language.Get(cache.CaseKey);
        }

        if (textView)
        {
            textView.Text = ScenarioKit.Instance.Language.Get(cache.CaseKey);
        }
    }

    // RVA: 0x19CCA9C
    public void OnClick()
    {
        if (cache == null)
        {
            return;
        }

        ScenarioKit.Instance.Events.OnSelect.Dispatch(option, cache);
    }

    // RVA: 0x19CCB20
    private void OnDestroy()
    {
        cache = null;
        option = null;
    }

    // RVA: 0x19CCB28
    public UICase()
    {
    }
}
