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
        private FacialSettings m_FacialSettings;
        [SerializeField]
        private EyeSettings m_EyeSetting;
        [SerializeField]
        private VowelSetting m_VowelSetting;
        [SerializeField]
        private ExpressionEffectSettings m_ExpressionEffectSetting;
        [SerializeField]
        private EyeDirection m_EyeDirection;
        [SerializeField]
        private ExpressionAnimator m_ExpressionAnimator;
        [SerializeField]
        private ExpressionEffector m_ExpressionEffector;
        public FacialSettings FacialSettings { get; }
        public EyeSettings EyeSetting { get; }
        public VowelSetting VowelSetting { get; }
        public ExpressionEffectSettings ExpressionEffectSetting { get; }
        public ExpressionAnimator ExpressionAnimator { get; set; }
        public ExpressionEffector ExpressionEffector { get; set; }

        // RVA: 0x13EF938
        public FacialSettings get_FacialSettings()
        {
            return m_FacialSettings;
        }

        // RVA: 0x13EF940
        public EyeSettings get_EyeSetting()
        {
            return m_EyeSetting;
        }

        // RVA: 0x13EF948
        public VowelSetting get_VowelSetting()
        {
            return m_VowelSetting;
        }

        // RVA: 0x13EF950
        public ExpressionEffectSettings get_ExpressionEffectSetting()
        {
            return m_ExpressionEffectSetting;
        }

        // RVA: 0x13EF958
        public ExpressionAnimator get_ExpressionAnimator()
        {
            return ExpressionAnimator;
        }

        // RVA: 0x13EF960
        public void set_ExpressionAnimator(ExpressionAnimator value)
        {
            ExpressionAnimator = value;
        }

        // RVA: 0x13EF968
        public ExpressionEffector get_ExpressionEffector()
        {
            return ExpressionEffector;
        }

        // RVA: 0x13EF970
        public void set_ExpressionEffector(ExpressionEffector value)
        {
            ExpressionEffector = value;
        }

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
            m_FacialSettings = facialSettings;
            m_EyeSetting = eyeSettingAsset;
            m_VowelSetting = vowelSettings;
            m_ExpressionEffectSetting = expressionEffectSettings;
        }

        // RVA: 0x13EF9D8
        public void Create()
        {
            m_EyeDirection = m_SkeletonSystem.AddMissingComponent<EyeDirection>();
            m_EyeDirection.Init(m_SkeletonSystem, m_AvatarSystem, m_EyeSetting);

            m_ExpressionAnimator = m_SkeletonSystem.AddMissingComponent<ExpressionAnimator>();
            m_ExpressionAnimator.Init(m_AvatarSystem, m_FacialSettings, m_VowelSetting, m_EyeDirection);

            m_ExpressionEffector = m_SkeletonSystem.AddMissingComponent<ExpressionEffector>();
            m_ExpressionEffector.Init(m_SkeletonSystem, m_ExpressionEffectSetting);
        }

        // RVA: 0x13EFAA8
        public void Destroy()
        {
            if (m_ExpressionEffector != null)
            {
                Object.Destroy(m_ExpressionEffector);
                m_ExpressionEffector = null;
            }
            if (m_ExpressionAnimator != null)
            {
                Object.Destroy(m_ExpressionAnimator);
                m_ExpressionAnimator = null;
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
            if (m_ExpressionAnimator != null && m_ExpressionAnimator.Voice != null)
            {
                m_ExpressionAnimator.Voice.ResetVowelInfo();
            }
        }

        // RVA: 0x13EFD50
        public void Play(eFaceExpression expression, bool mouthOpen = false)
        {
            if (m_ExpressionAnimator != null)
            {
                m_ExpressionAnimator.Play(expression, mouthOpen);
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
            if (m_ExpressionAnimator != null)
            {
                m_ExpressionAnimator.CrossFade(expression, mouthOpen, duration);
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
            if (m_ExpressionEffector != null)
            {
                m_ExpressionEffector.Play(name);
            }
        }

        // RVA: 0x13EFED4
        public void StopEffect()
        {
            if (m_ExpressionEffector != null)
            {
                m_ExpressionEffector.Stop();
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
