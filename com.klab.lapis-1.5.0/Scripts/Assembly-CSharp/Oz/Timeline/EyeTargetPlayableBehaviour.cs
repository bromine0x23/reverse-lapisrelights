// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EyeTargetPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ProcessFrame: if (expressionSystem != null) expressionSystem.GazeAt(lookAtTarget)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class EyeTargetPlayableBehaviour : PlayableBehaviour
    {
        public ExpressionSystem expressionSystem;
        public Transform lookAtTarget;

        // RVA: 0x13D873C
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (expressionSystem != null)
            {
                expressionSystem.GazeAt(lookAtTarget);
            }
        }

        // RVA: 0x13D8758
        public EyeTargetPlayableBehaviour()
        {
        }
    }
}
