// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.VowelPlayableBehaviour
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码（0x13DE9A0 为纯空实现）
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;

namespace Oz.Timeline
{
    public class VowelPlayableBehaviour : PlayableBehaviour
    {
        public VowelScriptObject sobj;

        // RVA: 0x13DE9A0
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            // 空实现：数据由 VowelTrackBehaviour 统一处理
        }

        // RVA: 0x13DE9A4
        public VowelPlayableBehaviour()
        {
        }
    }
}
