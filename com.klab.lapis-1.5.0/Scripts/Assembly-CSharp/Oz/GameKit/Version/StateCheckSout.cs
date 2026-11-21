// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateCheckSout
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using Oz.GameFramework.Runtime;
using UnityEngine;

namespace Oz.GameKit.Version
{
    /// <summary>Sout（客户端日志/验证）流程占位状态，当前版本无逻辑。</summary>
    public class StateCheckSout : State<eProcedure>
    {
        protected Coroutine m_Coroutine;
        private VersionControl m_VersionControl;

        // RVA: 0x18835E0
        public StateCheckSout(VersionControl versionControl) : base(eProcedure.Sout)
        {
            m_VersionControl = versionControl;
        }

        // RVA: 0x1883648
        public override void Enter(eProcedure previousState)
        {
        }

        // RVA: 0x188364C
        public override void Exit(eProcedure nextState)
        {
        }
    }
}
