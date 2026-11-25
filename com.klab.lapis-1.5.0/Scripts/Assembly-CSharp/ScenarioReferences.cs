// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  ScenarioReferences
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
//  普通/Loli 两套缩放配置，并把自己注册到 ScenarioKit 的模块表。
// =============================================================================

public class ScenarioReferences : Module
{
    public ScaleSettings Scale_Normal;
    public ScaleSettings Scale_Loli;

    // RVA: 0x1B86B28
    private void Awake()
    {
        ScenarioReferences references = Kit.GetModule<ScenarioReferences>();
        if (references)
        {
            return;
        }

        Kit._modules.Add(this);
    }

    // RVA: 0x1B86BF8
    public ScenarioReferences()
    {
    }
}
