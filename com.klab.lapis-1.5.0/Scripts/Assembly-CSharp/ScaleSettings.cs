// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScaleSettings
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class ScaleSettings : ScriptableObject
{
    [field: SerializeField]
    public bool IsLoli { get; set; }
    [field: SerializeField]
    public float ScaleRatio { get; set; }
    [field: SerializeField]
    public List<ScaleData> ListScaleData { get; private set; }
    [field: SerializeField]
    public int BreastUp { get; set; }
    [field: SerializeField]
    public int BreastDown { get; set; }
    [field: SerializeField]
    public int BreastLarger { get; set; }
    [field: SerializeField]
    public int BreastSmall { get; set; }

    // RVA: 0x1B77300
    public ScaleSettings()
    {
        ListScaleData = new List<ScaleData>();
        ScaleRatio = 1f;
    }
}
