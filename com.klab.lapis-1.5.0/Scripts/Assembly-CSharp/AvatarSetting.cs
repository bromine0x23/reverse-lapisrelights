// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  AvatarSetting
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  构造中：Dummy = string.Empty。
// =============================================================================

using UnityEngine;

public class AvatarSetting : ScriptableObject
{
    public eAvatarType Type { get; private set; }
    public GameObject Prefab { get; private set; }
    public int Slot { get; private set; }
    public string Dummy { get; private set; }
    public HeelSetting HeelSetting { get; private set; }
    public SpringSetting SpringSetting { get; private set; }
    public bool RebindAnimator { get; private set; }

    // RVA: 0x198DB40
    public AvatarSetting()
    {
        Dummy = string.Empty;
    }
}
