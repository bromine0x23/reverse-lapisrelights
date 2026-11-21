// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.AsyncFallbackDelegate
//  来源：Il2CppDumper 元数据（签名精确）
// =============================================================================

using System;

namespace Jackpot
{
    public delegate void AsyncFallbackDelegate<TValue>(Action<TValue> onSuccess, Action<object> onFailure);
}
