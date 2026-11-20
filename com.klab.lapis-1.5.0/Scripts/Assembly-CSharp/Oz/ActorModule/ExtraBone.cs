// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.ExtraBone
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        引用计数包装：ctor 置 m_RefCount = 1
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class ExtraBone
    {
        private Transform m_Bone;
        private int m_RefCount;

        // RVA: 0x13F01E0
        public Transform get_Bone()
        {
            return m_Bone;
        }

        // RVA: 0x13F01E8
        public ExtraBone(Transform bone)
        {
            m_RefCount = 1;
            m_Bone = bone;
        }

        // RVA: 0x13F021C
        public void AddRef()
        {
            ++m_RefCount;
        }

        // RVA: 0x13F022C
        public void DecRef()
        {
            --m_RefCount;
        }

        // RVA: 0x13F023C
        public int GetRefCount()
        {
            return m_RefCount;
        }
    }
}
