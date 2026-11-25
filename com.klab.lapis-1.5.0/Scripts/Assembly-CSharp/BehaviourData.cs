// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  BehaviourData
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  构造中：CrossFadeTime = 0.1f，数组字段初始化为空数组。
// =============================================================================

using UnityEngine;

public class BehaviourData
{
    public bool ShowInVoiceList { get; private set; }
    public string VoiceName { get; private set; }
    public int Level { get; private set; }
    public int WordsID { get; private set; }
    public string EmojiID { get; private set; }
    public AnimationClip AnimClip { get; private set; }
    public float CrossFadeTime { get; private set; }
    public bool UseFixedTime { get; private set; }
    public string SoundEvent { get; private set; }
    public bool ShowExtraAvatar { get; private set; }
    public ExpressionEvent[] ExpressionEvents { get; private set; }
    public ExpressionEffectEvent[] ExpressionEffectEvents { get; private set; }

    // RVA: 0x19967E0
    public BehaviourData()
    {
        ShowInVoiceList = true;
        VoiceName = string.Empty;
        EmojiID = string.Empty;
        CrossFadeTime = 0.1f;
        SoundEvent = string.Empty;
        ExpressionEvents = new ExpressionEvent[0];
        ExpressionEffectEvents = new ExpressionEffectEvent[0];
    }
}
