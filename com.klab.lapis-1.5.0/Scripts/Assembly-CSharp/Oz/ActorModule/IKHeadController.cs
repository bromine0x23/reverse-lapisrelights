// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.IKHeadController
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        OnAnimatorIK 优先消费 Timeline 输入（一次性），否则按目标插值 +
//        SmoothDamp 平滑；无目标时回落到 ForwardTarget 并衰减权重。
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class IKHeadController : MonoBehaviour
    {
        private Animator m_Animator;
        private Transform m_Head;
        public Transform m_Target;
        public float m_TargetWeight;
        public Vector4 WeightParts;
        public float m_Weight;
        public float m_WeightVelocity;
        public Vector3 m_Position;
        public Vector3 m_PositionVelocity;
        private float m_SmoothTime;
        private float w;
        private Vector3 m_TimelineInputPosition;
        private float m_TimelineInputWeight;

        // RVA: 0x13F168C
        public Vector3 get_ForwardTarget()
        {
            if (m_Head == null)
            {
                return Vector3.zero;
            }
            return m_Head.position + m_Head.up;
        }

        // RVA: 0x13F17D0
        public Vector3 get_TargetPos()
        {
            if (m_Head == null || m_Target == null)
            {
                return Vector3.zero;
            }
            return m_Head.position + Vector3.Normalize(m_Target.position - m_Head.position);
        }

        // RVA: 0x13F1998
        private void Awake()
        {
            m_WeightVelocity = 0f;
            m_SmoothTime = 0.15f;
            m_PositionVelocity = Vector3.zero;
        }

        // RVA: 0x13F1A18
        public void Init(Animator animator)
        {
            m_Animator = animator;
            if (animator != null)
            {
                m_Head = animator.GetBoneTransform(HumanBodyBones.Head);
                if (m_Head != null)
                {
                    m_Position = get_ForwardTarget();
                }
            }
        }

        // RVA: 0x13F1AF8
        public void ApplyTimelineLookAtTarget(Vector3 position, float weight = 1f)
        {
            m_TimelineInputPosition = position;
            m_TimelineInputWeight = weight;
        }

        // RVA: 0x13F1B04
        public void ReleaseTimelineControl()
        {
            m_TimelineInputWeight = 0f;
        }

        // RVA: 0x13F1B0C
        public void SetLookAtTarget(Transform target, float weight = 1f)
        {
            if (m_Target != target)
            {
                m_PositionVelocity = Vector3.zero;
                m_WeightVelocity = 0f;
            }
            m_Target = target;
            w = 1f;
            m_TargetWeight = weight;
        }

        // RVA: 0x13F1BE0
        public void SetLookAtTargetImmediate(Transform target, float weight = 1f)
        {
            SetLookAtTarget(target, weight);
            w = 0f;

            if (target != null)
            {
                m_Weight = -1f;
                m_Position = Vector3.Lerp(get_ForwardTarget(), get_TargetPos(), m_Weight);
            }
            else
            {
                m_Weight = 0f;
                m_Position = get_ForwardTarget();
            }
        }

        // RVA: 0x13F1D28
        private void OnDrawGizmos()
        {
            if (m_Head != null)
            {
                Gizmos.color = Color.blue;
                Gizmos.DrawLine(m_Head.position, m_Position);

                if (m_Head != null)
                {
                    Gizmos.DrawCube(m_Head.position + m_Head.up, Vector3.one * 0.1f);
                }
            }
        }

        // RVA: 0x13F1EF8
        private void OnAnimatorIK(int index)
        {
            if (m_TimelineInputWeight > 0f)
            {
                m_Animator.SetLookAtPosition(m_TimelineInputPosition);
                m_Animator.SetLookAtWeight(m_TimelineInputWeight);
                m_TimelineInputWeight = 0f;
                return;
            }

            if (m_Target != null)
            {
                float prevWeight = m_Weight;
                m_Weight = m_TargetWeight;

                Vector3 blended = Vector3.Lerp(get_ForwardTarget(), get_TargetPos(), m_Weight);
                if (prevWeight >= 0f)
                {
                    m_Position = Vector3.SmoothDamp(m_Position, blended, ref m_PositionVelocity, m_SmoothTime);
                }
                else
                {
                    m_Position = blended;
                }

                m_Animator.SetLookAtPosition(m_Position);
                m_Animator.SetLookAtWeight(1f, WeightParts.x, WeightParts.y, WeightParts.z, WeightParts.w);
            }
            else
            {
                m_Position = Vector3.SmoothDamp(m_Position, get_ForwardTarget(), ref m_PositionVelocity, m_SmoothTime);
                m_Animator.SetLookAtPosition(m_Position);
                m_Weight = Mathf.SmoothDamp(m_Weight, 0f, ref m_WeightVelocity, m_SmoothTime);
                m_Animator.SetLookAtWeight(w, WeightParts.x, WeightParts.y, WeightParts.z, WeightParts.w);
            }
        }

        // RVA: 0x13F2204
        public IKHeadController()
        {
        }
    }
}
