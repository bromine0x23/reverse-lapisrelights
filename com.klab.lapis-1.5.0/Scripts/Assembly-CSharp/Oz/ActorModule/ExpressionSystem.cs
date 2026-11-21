// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.ExpressionSystem
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Create 在 SkeletonSystem 上补挂 EyeDirection / ExpressionAnimator /
//        ExpressionEffector；Play/CrossFade/PlayEffect 均转发子组件。
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class ExpressionSystem
    {
        [SerializeField]
        private SkeletonSystem m_SkeletonSystem;
        [SerializeField]
        private AvatarSystem m_AvatarSystem;
        [SerializeField]
        private EyeDirection m_EyeDirection;
        [field: SerializeField]
        public FacialSettings FacialSettings { get; private set; }
        [field: SerializeField]
        public EyeSettings EyeSetting { get; private set; }
        [field: SerializeField]
        public VowelSetting VowelSetting { get; private set; }
        [field: SerializeField]
        public ExpressionEffectSettings ExpressionEffectSetting { get; private set; }
        [field: SerializeField]
        public ExpressionAnimator ExpressionAnimator { get; set; }
        [field: SerializeField]
        public ExpressionEffector ExpressionEffector { get; set; }

        // RVA: 0x13EF978
        public ExpressionSystem(
            SkeletonSystem skeletonSystem,
            AvatarSystem avatarSystem,
            FacialSettings facialSettings,
            EyeSettings eyeSettingAsset,
            VowelSetting vowelSettings,
            ExpressionEffectSettings expressionEffectSettings)
        {
            m_SkeletonSystem = skeletonSystem;
            m_AvatarSystem = avatarSystem;
            FacialSettings = facialSettings;
            EyeSetting = eyeSettingAsset;
            VowelSetting = vowelSettings;
            ExpressionEffectSetting = expressionEffectSettings;
        }

        // RVA: 0x13EF9D8
        public void Create()
        {
            m_EyeDirection = m_SkeletonSystem.AddMissingComponent<EyeDirection>();
            m_EyeDirection.Init(m_SkeletonSystem, m_AvatarSystem, EyeSetting);

            ExpressionAnimator = m_SkeletonSystem.AddMissingComponent<ExpressionAnimator>();
            ExpressionAnimator.Init(m_AvatarSystem, FacialSettings, VowelSetting, m_EyeDirection);

            ExpressionEffector = m_SkeletonSystem.AddMissingComponent<ExpressionEffector>();
            ExpressionEffector.Init(m_SkeletonSystem, ExpressionEffectSetting);
        }

        // RVA: 0x13EFAA8
        public void Destroy()
        {
            if (ExpressionEffector != null)
            {
                Object.Destroy(ExpressionEffector);
                ExpressionEffector = null;
            }
            if (ExpressionAnimator != null)
            {
                Object.Destroy(ExpressionAnimator);
                ExpressionAnimator = null;
            }
            if (m_EyeDirection != null)
            {
                Object.Destroy(m_EyeDirection);
                m_EyeDirection = null;
            }
        }

        // RVA: 0x13EFC0C
        public void LateUpdate()
        {
            if (m_EyeDirection != null && m_EyeDirection.isActiveAndEnabled)
            {
                m_EyeDirection.CustomLateUpdate();
            }
        }

        // RVA: 0x13EFCB4
        public void ResetVowelInfo()
        {
            if (ExpressionAnimator != null && ExpressionAnimator.Voice != null)
            {
                ExpressionAnimator.Voice.ResetVowelInfo();
            }
        }

        // RVA: 0x13EFD50
        public void Play(eFaceExpression expression, bool mouthOpen = false)
        {
            if (ExpressionAnimator != null)
            {
                ExpressionAnimator.Play(expression, mouthOpen);
            }
        }

        // RVA: 0x13EFE00
        public void Play(int expression, bool mouthOpen = false)
        {
            Play((eFaceExpression)expression, mouthOpen);
        }

        // RVA: 0x13EFE08
        public void CrossFade(eFaceExpression expression, bool mouthOpen = false, float duration = 0.02f)
        {
            if (ExpressionAnimator != null)
            {
                ExpressionAnimator.CrossFade(expression, mouthOpen, duration);
            }
        }

        // RVA: 0x13EFECC
        public void CrossFade(int expression, bool mouthOpen = false, float duration = 0.02f)
        {
            CrossFade((eFaceExpression)expression, mouthOpen, duration);
        }

        // RVA: 0x13EEE3C
        public void PlayEffect(string name)
        {
            if (ExpressionEffector != null)
            {
                ExpressionEffector.Play(name);
            }
        }

        // RVA: 0x13EFED4
        public void StopEffect()
        {
            if (ExpressionEffector != null)
            {
                ExpressionEffector.Stop();
            }
        }

        // RVA: 0x13EFF64
        public void GazeAt(Transform target)
        {
            if (m_EyeDirection != null)
            {
                m_EyeDirection.SetTarget(target != null ? target.gameObject : null);
            }
        }

        // RVA: 0x13F005C
        public void FocusAt(Transform target)
        {
            if (m_EyeDirection != null)
            {
                m_EyeDirection.highlightTargetObject = target != null ? target.gameObject : null;
            }
        }
    }
}
