// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateComplete
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using Oz.GameFramework.Runtime;

namespace Oz.GameKit.Version
{{
    /// <summary>流程终点：把控制权交回 <see cref="VersionControl.OnComplete"/>。</summary>
    public class StateComplete : State<eProcedure>
    {
        private VersionControl m_VersionControl;

        // RVA: 0x1886430
        public StateComplete(VersionControl versionControl) : base(eProcedure.Complete)
        {
            m_VersionControl = versionControl;
        }

        // RVA: 0x1886498
        public override void Enter(eProcedure previousState)
        {
            m_VersionControl.OnComplete();
        }
    }
}}
