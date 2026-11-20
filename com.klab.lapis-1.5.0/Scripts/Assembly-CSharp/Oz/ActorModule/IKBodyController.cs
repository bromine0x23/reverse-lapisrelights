// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.IKBodyController
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Apply* 把请求入队；OnAnimatorIK 逐条出队写入 Animator，
//        三个队列皆空时把 4 个 goal / 4 个 hint 的权重清零。
// =============================================================================

using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Oz.ActorModule
{
    public class IKBodyController : MonoBehaviour
    {
        private Animator m_Animator;
        private List<IKParam> m_IKParams;
        private List<IKHintParam> m_IKHintParams;
        private List<IKBodyPositionParam> m_IKBodyPositionParams;

        // RVA: 0x13F1014
        private void Awake()
        {
            m_IKParams = new List<IKParam>();
            m_IKHintParams = new List<IKHintParam>();
            m_IKBodyPositionParams = new List<IKBodyPositionParam>();
        }

        // RVA: 0x13F10CC
        public void Init(Animator animator)
        {
            m_Animator = animator;
        }

        // RVA: 0x13F10D4
        private void OnAnimatorIK(int index)
        {
            if (m_IKParams.Count <= 0 && m_IKBodyPositionParams.Count <= 0 && m_IKHintParams.Count <= 0)
            {
                for (int goalIndex = 0; goalIndex < 4; goalIndex++)
                {
                    if (m_Animator.GetIKPositionWeight((AvatarIKGoal)goalIndex) > 0f)
                    {
                        m_Animator.SetIKPositionWeight((AvatarIKGoal)goalIndex, 0f);
                    }
                }

                for (int hintIndex = 0; hintIndex < 4; hintIndex++)
                {
                    if (m_Animator.GetIKHintPositionWeight((AvatarIKHint)hintIndex) > 0f)
                    {
                        m_Animator.SetIKHintPositionWeight((AvatarIKHint)hintIndex, 0f);
                    }
                }
            }

            while (m_IKParams.Count >= 1)
            {
                IKParam goal = m_IKParams.First();
                m_Animator.SetIKPosition(goal.goal, goal.position);
                m_Animator.SetIKPositionWeight(goal.goal, goal.positionWeight);
                m_Animator.SetIKRotation(goal.goal, goal.rotation);
                m_Animator.SetIKRotationWeight(goal.goal, goal.rotationWeight);
                m_IKParams.RemoveAt(0);
            }

            while (m_IKHintParams.Count > 0)
            {
                IKHintParam hint = m_IKHintParams.First();
                m_Animator.SetIKHintPosition(hint.iKHint, hint.position);
                m_Animator.SetIKHintPositionWeight(hint.iKHint, hint.weight);
                m_IKHintParams.RemoveAt(0);
            }

            while (m_IKBodyPositionParams.Count >= 1)
            {
                IKBodyPositionParam param = m_IKBodyPositionParams.First();
                m_Animator.bodyPosition += param.bodyPositonOffset * param.weight;
                m_IKBodyPositionParams.RemoveAt(0);
            }
        }

        // RVA: 0x13F1450
        public void ApplyIKGoal(
            AvatarIKGoal ikGoal,
            Vector3 ikPosition,
            float ikPositionWeight,
            Quaternion ikRotation,
            float ikRotationWeight)
        {
            m_IKParams.Add(new IKParam(ikGoal, ikPosition, ikPositionWeight, ikRotation, ikRotationWeight));
        }

        // RVA: 0x13F1540
        public void ApplyIKHint(AvatarIKHint ikHint, Vector3 ikPosition, float ikWeight)
        {
            m_IKHintParams.Add(new IKHintParam(ikHint, ikPosition, ikWeight));
        }

        // RVA: 0x13F15F0
        public void ApplyBodyPositionOffset(Vector3 bodyPostionOffset, float weight)
        {
            m_IKBodyPositionParams.Add(new IKBodyPositionParam(bodyPostionOffset, weight));
        }

        // RVA: 0x13F1684
        public IKBodyController()
        {
        }
    }
}
