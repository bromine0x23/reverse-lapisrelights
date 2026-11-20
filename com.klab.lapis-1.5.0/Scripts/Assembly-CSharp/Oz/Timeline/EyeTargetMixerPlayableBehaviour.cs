// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EyeTargetMixerPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        OnGraphStop: expressionSystem.GazeAt(null) 复位视线
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class EyeTargetMixerPlayableBehaviour : PlayableBehaviour
    {
        public ExpressionSystem expressionSystem;

        // RVA: 0x13D85F0
        public override void OnGraphStop(Playable playable)
        {
            if (expressionSystem != null)
            {
                expressionSystem.GazeAt(null);
            }
        }

        // RVA: 0x13D8608
        public EyeTargetMixerPlayableBehaviour()
        {
        }
    }
}
