// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.HeelUpdate
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        CustomLateUpdate 在 Animator 播放 Playable 时调整双脚角度与髋部高度
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class HeelUpdate : MonoBehaviour
    {
        private float m_TweakFootAngle;
        private float m_TweakFootHeight;
        private Transform m_LeftFoot;
        private Transform m_RightFoot;
        private Transform m_Hips;
        private Animator m_Animtor;
        private bool noHeel;

        // RVA: 0x13F09E8
        private void Start()
        {
            m_Animtor = GetComponent<Animator>();
            noHeel = false;

            Transform parent = transform.parent;
            if (parent != null && parent.parent != null)
            {
                if (parent.parent.GetComponent<NoHeel>() != null)
                {
                    noHeel = true;
                }
            }
        }

        // RVA: 0x13F0B70
        public void Init(SkeletonSystem skeletonSystem)
        {
            if (skeletonSystem != null)
            {
                m_LeftFoot = skeletonSystem.GetBone(HumanBodyBones.LeftFoot);
                m_RightFoot = skeletonSystem.GetBone(HumanBodyBones.RightFoot);
                m_Hips = skeletonSystem.GetBone(HumanBodyBones.Hips);
            }
        }

        // RVA: 0x13F0C70
        public void Apply(float tweakFootAngle, float tweakFootHeight)
        {
            m_TweakFootAngle = tweakFootAngle;
            m_TweakFootHeight = tweakFootHeight;
        }

        // RVA: 0x13F0C78
        public void ApplyFootAngle(float tweakFootAngle)
        {
            m_TweakFootAngle = tweakFootAngle;
        }

        // RVA: 0x13F0C80
        public void ApplyFootHeight(float tweakFootHeight)
        {
            m_TweakFootHeight = tweakFootHeight;
        }

        // RVA: 0x13F0C88
        public void CustomLateUpdate()
        {
            if (m_Animtor == null)
            {
                return;
            }
            if (!m_Animtor.enabled)
            {
                return;
            }
            if (!m_Animtor.hasBoundPlayables || noHeel)
            {
                return;
            }

            if (m_LeftFoot != null)
            {
                m_LeftFoot.localRotation *= Quaternion.AngleAxis(m_TweakFootAngle, Vector3.back);
            }

            if (m_RightFoot != null)
            {
                m_RightFoot.localRotation *= Quaternion.AngleAxis(m_TweakFootAngle, Vector3.back);
            }

            if (m_Hips != null)
            {
                Vector3 position = m_Hips.position;
                position.y += m_TweakFootHeight * m_Hips.lossyScale.x;
                m_Hips.position = position;
            }
        }

        // RVA: 0x13F100C
        public HeelUpdate()
        {
        }
    }
}
