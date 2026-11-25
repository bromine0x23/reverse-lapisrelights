// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  EyeSettings
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using UnityEngine;

[CreateAssetMenu]
public class EyeSettings : ScriptableObject
{
    [field: SerializeField]
    public Vector3 MaxIn { get; set; }
    [field: SerializeField]
    public Vector3 MaxOut { get; set; }
    [field: SerializeField]
    public Vector3 MaxUp { get; set; }
    [field: SerializeField]
    public Vector3 MaxDown { get; set; }
    [field: SerializeField]
    public float MoveRatio { get; set; }

    // RVA: 0x1753188
    public EyeSettings()
    {
        MaxIn = Vector3.zero;
        MaxOut = Vector3.zero;
        MaxUp = Vector3.zero;
        MaxDown = Vector3.zero;
    }
}
