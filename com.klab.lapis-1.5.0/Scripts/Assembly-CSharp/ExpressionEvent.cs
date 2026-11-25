// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ExpressionEvent
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  构造中：Expression = eFaceExpression.USUALLY，TransitionDuration = 0.1f。
// =============================================================================

public class ExpressionEvent
{
    public float Time { get; private set; }
    public eFaceExpression Expression { get; private set; }
    public bool MouthOpen { get; private set; }
    public float TransitionDuration { get; private set; }

    // RVA: 0x174F478
    public ExpressionEvent()
    {
        Expression = eFaceExpression.USUALLY;
        TransitionDuration = 0.1f;
    }
}
