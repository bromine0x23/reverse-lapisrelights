// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EventData
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        ResolveEventArgs: ResolvedObjectValue 为空时用 resolver 解析 ExposedReference
// =============================================================================

using UnityEngine;

namespace Oz.Timeline
{
    public class EventData
    {
        public string StringValue;
        public float FloatValue;
        public int IntValue;
        [SerializeField]
        private ExposedReference<Object> ObjectValue;
        public Object ResolvedObjectValue;

        // RVA: 0x13D750C
        public void ResolveEventArgs(IExposedPropertyTable resolver)
        {
            if (ResolvedObjectValue == null)
            {
                ResolvedObjectValue = ObjectValue.Resolve(resolver);
            }
        }

        // RVA: 0x13D75AC
        public EventData()
        {
        }
    }
}
