// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.ScenarioClip
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CreatePlayable: ScriptPlayable<ScenarioBehaviour>.Create(graph, 0) + SetContext
//        get_clipCaps = 8 (ClipCaps.ClipIn)
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class ScenarioClip : Clip
    {
        // RVA: 0x13DBEF0
        public ClipCaps get_clipCaps()
        {
            return ClipCaps.ClipIn;
        }

        // RVA: 0x13DBEF8
        public override Playable CreatePlayable(PlayableGraph graph, GameObject go)
        {
            ScriptPlayable<ScenarioBehaviour> playable = ScriptPlayable<ScenarioBehaviour>.Create(graph, 0);
            ScenarioBehaviour behaviour = playable.GetBehaviour();
            SetContext(behaviour);
            return playable;
        }

        // RVA: 0x13D6DDC
        public ScenarioClip()
        {
        }
    }
}
