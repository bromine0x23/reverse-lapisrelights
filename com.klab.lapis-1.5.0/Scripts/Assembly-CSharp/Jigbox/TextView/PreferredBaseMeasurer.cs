// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.PreferredBaseMeasurer
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

namespace Jigbox.TextView
{
    public abstract class PreferredBaseMeasurer
    {
        protected PreferredSizeMeasurer.PreferredSizeMeasurerProperty property;

        public float Value { get; protected set; }
        public bool IsCacheInvalid { get; set; }

        public virtual bool HasCache
        {
            // RVA: 0x1682F30
            get { return !IsCacheInvalid; }
        }

        // RVA: 0x1682F40
        protected PreferredBaseMeasurer()
        {
        }
    }
}
