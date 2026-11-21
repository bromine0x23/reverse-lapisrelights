// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.IScheduler
//  来源：Il2CppDumper 元数据（签名精确）
// =============================================================================

using System;

namespace Jackpot
{
    public interface IScheduler
    {
        SchedulerState State { get; }
        string Name { get; }
        bool IsFollowTimeScale { get; }
        Action<Exception> ExceptionCallback { set; }
        void Pause();
        void Resume();
        void Restart();
        void Finish();
        void FinishWithAction();
    }
}
