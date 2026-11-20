// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.MaterialPropertyBlockPlayableAsset
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//  成员体均为模板形态（基类构造 / 字段属性 / ScriptPlayable 标准创建），已逐条核对
// =============================================================================

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public abstract class MaterialPropertyBlockPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public IMaterialPropertyBlockModifier modifier;
        public string propertyName;

        // RVA: 0x13DB3BC
        public override ClipCaps clipCaps
        {
            get { return (ClipCaps)0; }
        }

        // RVA: 0x13DAE8C
        public MaterialPropertyBlockPlayableAsset()
        {
        }
    }
}
