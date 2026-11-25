// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  UISection
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine.UI;

public class UISection : UIView
{
    public Text text;

    // RVA: 0x1DF2940
    public void RefreshView(string txt)
    {
        text.text = Kit.Language.Get(txt);
    }

    // RVA: 0x1DF299C
    public UISection()
    {
    }
}
