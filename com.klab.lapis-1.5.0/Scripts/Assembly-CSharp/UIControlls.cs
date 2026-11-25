// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  UIControlls
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

public class UIControlls : UIView
{
    // RVA: 0x19CFF60
    public void AutoPlay(bool auto)
    {
        Kit.Events.OnCheckAuto.Dispatch(auto);
    }

    // RVA: 0x19CFFE0
    public void Skip()
    {
        Kit.Events.OnClickSkip.Dispatch(null);
    }

    // RVA: 0x19D0054
    public void SkipAll()
    {
        Kit.Events.OnClickSkipAll.Dispatch(null);
    }

    // RVA: 0x19D00C8
    public void ToEnd()
    {
        Kit.Events.ToEnd.Dispatch(null);
    }

    // RVA: 0x19D013C
    public UIControlls()
    {
    }
}
