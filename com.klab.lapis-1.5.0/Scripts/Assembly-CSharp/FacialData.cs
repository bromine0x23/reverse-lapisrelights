// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  FacialData
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;

[Serializable]
public class FacialData
{
    public eFaceExpression Expression { get; set; }
    public bool Blink { get; set; }
    public List<BlendData> BlendData { get; set; }
    public float CheekPower { get; set; }
    public float ForeheadShade { get; set; }
    public float EyeHighlight { get; set; }
    public float EyeScale { get; set; }

    // RVA: 0x17547A0
    public FacialData()
    {
    }
}
