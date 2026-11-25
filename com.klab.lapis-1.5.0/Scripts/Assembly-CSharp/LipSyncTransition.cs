// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LipSyncTransition
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

internal class LipSyncTransition
{
    public readonly LipState State;
    public readonly LipCommand Command;

    // RVA: 0x1338180
    public LipSyncTransition(LipState state, LipCommand command)
    {
        State = state;
        Command = command;
    }

    // RVA: 0x133988C
    public override int GetHashCode()
    {
        return (int)State ^ ((int)Command << 2);
    }

    // RVA: 0x13398D4
    public override bool Equals(object obj)
    {
        LipSyncTransition other = obj as LipSyncTransition;
        return other != null && other.State == State && other.Command == Command;
    }
}
