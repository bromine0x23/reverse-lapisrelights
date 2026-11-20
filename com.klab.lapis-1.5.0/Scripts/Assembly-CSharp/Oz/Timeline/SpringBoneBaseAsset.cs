// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.SpringBoneBaseAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//  成员体均为模板形态（基类构造 / 字段属性 / ScriptPlayable 标准创建），已逐条核对
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public abstract class SpringBoneBaseAsset : PlayableAsset, ITimelineClipAsset
    {
        [HideInInspector]
        public SpringManager springMgr;

        // RVA: 0x13DC53C
        public override ClipCaps clipCaps
        {
            get { return (ClipCaps)0; }
        }

        // RVA: 0x13DC544
        public SpringBoneBaseAsset()
        {
        }
    }
}
