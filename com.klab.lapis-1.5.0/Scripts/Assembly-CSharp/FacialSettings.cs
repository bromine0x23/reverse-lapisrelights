// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  FacialSettings
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class FacialSettings : ScriptableObject
{
    public string ActorName;
    public float BlinkDuration;
    public float BlinkInterval;
    public float BlinkThreshold;
    public AnimationCurve BlinkCurve;
    [field: SerializeField]
    public List<FacialData> FacialData { get; set; }

    // RVA: 0x17547B8
    public FacialSettings()
    {
        BlinkDuration = 0.3f;
        BlinkInterval = 3f;
        BlinkThreshold = 0.5f;
    }
}
