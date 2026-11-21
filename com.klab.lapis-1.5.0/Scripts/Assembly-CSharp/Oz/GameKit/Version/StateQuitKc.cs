// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.GameKit.Version.StateQuitKc
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using Oz.GameFramework.Runtime;
using UnityEngine;

namespace Oz.GameKit.Version
{
    /// <summary>KC 渠道退出：直接结束进程。</summary>
    public class StateQuitKc : State<eProcedure>
    {
        private VersionControl m_VersionControl;

        // RVA: 0x1887E00
        public StateQuitKc(VersionControl versionControl) : base(eProcedure.Quit)
        {
            m_VersionControl = versionControl;
        }

        // RVA: 0x1887E68
        public override void Enter(eProcedure previousState)
        {
            Debug.LogWarning("kc quit!");
            Application.Quit();
        }
    }
}
