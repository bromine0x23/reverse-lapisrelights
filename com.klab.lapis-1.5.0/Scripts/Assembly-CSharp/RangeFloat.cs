// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  RangeFloat
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

public struct RangeFloat
{
    public float start;
    public float length;

    public float end
    {
        // RVA: 0x153FC8C
        get { return start + length; }
    }

    // RVA: 0x153FC84
    public RangeFloat(float start, float length)
    {
        this.start = start;
        this.length = length;
    }
}
