// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateQuit
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using Oz.GameFramework.Runtime;

namespace Oz.GameKit.Version
{
    /// <summary>退出流程：交由 SDK 收尾。</summary>
    public class StateQuit : State<eProcedure>
    {
        private VersionControl m_VersionControl;

        // RVA: 0x1887CE8
        public StateQuit(VersionControl versionControl) : base(eProcedure.Quit)
        {
            m_VersionControl = versionControl;
        }

        // RVA: 0x1887D50
        public override void Enter(eProcedure previousState)
        {
            if (OzSDKManager.Instance != null)
            {
                OzSDKManager.Instance.Quit();
            }
        }
    }
}
